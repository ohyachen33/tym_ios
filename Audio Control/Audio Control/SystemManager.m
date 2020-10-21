//
//  SystemManager.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 16/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "SystemManager.h"
#import "DocumentUtils.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString * const SystemValueDidUpdate               =   @"SystemValueDidUpdate";
NSString * const SystemStateDidUpdate               =   @"SystemStateDidUpdate";
NSString * const SystemDiscoveredNewSystem          =   @"SystemDiscoveredNewSystem";
NSString * const DidConnectedToSystem               =   @"DidConnectedToSystem";
NSString * const PowerStateDidUpdate                =   @"PowerStateDidUpdate";
NSString * const PlayStateDidUpdate                 =   @"PlayStateDidUpdate";

@interface SystemManager()


@end


@implementation SystemManager

static SystemManager *sharedManager;

+ (SystemManager*)sharedManager
{
    static SystemManager* sharedManager = NULL;
 
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SystemManager alloc] init];
        
    });
    
    return sharedManager;
}

- (id)init
{
    if (sharedManager != nil)
    {
        return nil;
    }
    
    if ((self = [super init]))
    {
        self.state = SystemBLEStateStopped;
        self.discoveredSystems = [[NSMutableArray alloc] init];
        
//        [self start];
        
    }
    return self;
}

- (void)start
{
    //observe state change
    [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    //init services
    NSDictionary* serviceInfo = [DocumentUtils dictionaryFromResources:@"csr8670"];
    
    //TODO: Please revisit this type mechanism.
    self.type = @"BLE-csr8670";
    self.systemService = [[TAPSystemService alloc] initWithType:self.type config:@{@"serviceInfo" : serviceInfo, TAPSystemKeyConnectionDuration : [NSNumber numberWithInteger:10]} delegate:self];
    self.playControlService = [[TAPPlayControlService alloc] initWithType:self.type];
    self.playControlService.delegate = self;

    self.systemSettings = [[TASystemSettings alloc] init];
    self.discoveredSystems = [[NSMutableArray alloc] init];
}

- (void)subscribeServices
{
    [self.playControlService startMonitorVolumeOfSystem:self.connectedSystem];
    [self.playControlService startMonitorPlayStatusOfSystem:self.connectedSystem];
    [self.systemService startMonitorPowerStatusOfSystem:self.connectedSystem];
    [self.systemService startMonitorBatteryStatusOfSystem:self.connectedSystem];
}

- (void)unsubscribeServices
{
    [self.playControlService stopMonitorVolumeOfSystem:self.connectedSystem];
    [self.playControlService stopMonitorPlayStatusOfSystem:self.connectedSystem];
    [self.systemService stopMonitorPowerStatusOfSystem:self.connectedSystem];
    [self.systemService stopMonitorBatteryStatusOfSystem:self.connectedSystem];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"state"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SystemStateDidUpdate object:self userInfo:nil];
    }
}


#pragma mark TASystemServiceDelegate method

- (void)didUpdateState:(TAPSystemServiceState)state
{
    switch (state) {
        case TAPSystemServiceStateReady:{
            NSLog(@"System Serivce is ready to rock.");
            [self.systemService scanForSystems];
            self.state = SystemBLEStateScanning;
            
        }
            break;
        case TAPSystemServiceStateOff: {
            
            self.state = SystemBLEStateStopped;
        }
            
        default:
            break;
    }
}

- (void)system:(id)system didUpdateBatteryStatus:(NSString *)batteryLevel{
    self.systemSettings.batteryLevel = [batteryLevel integerValue];
}

- (void)system:(id)system didUpdatePowerStatus:(TAPSystemServicePowerStatus)status
{
    self.systemSettings.TAPSystemServicePowerStatus = status;
    self.systemSettings.powerStatus = status == TAPSystemServicePowerStatusStandbyLow ? 1 : 0;
    [self notifyUpdate:@"powerStatus"];
}

- (void)didDiscoverSystem:(id)system RSSI:(NSNumber *)RSSI
{    
    [self addSystem:system systems:self.discoveredSystems];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SystemDiscoveredNewSystem object:self userInfo:@{ @"system" : system }];
}

- (void)didConnectToSystem:(id)system success:(BOOL)success error:(NSError*)error {
    
    if(success)
    {
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        
        [userInfo setObject:system forKey:@"system"];
        
        if(error)
        {
            [userInfo setObject:error forKey:@"error"];
        }
        
        //persist information
        self.connectedSystem = system;
        self.state = SystemBLEStateConnected;
        self.systemSettings.connection = 0;
        
        //start monitoring
        [self subscribeServices];
        [[NSNotificationCenter defaultCenter] postNotificationName:DidConnectedToSystem object:self userInfo:@{ @"system" : system ,@"success":@"1"}];

    }else{
        NSLog(@"Failed to connect to %@", [[system instance] name]);
        [[NSNotificationCenter defaultCenter] postNotificationName:DidConnectedToSystem object:self userInfo:@{ @"system" : system ,@"success":@"0"}];

    }
    
    
    /*CBPeripheral* peripheral = [system instance];
    
    [self saveConnectedDeviceIdentifier:peripheral.identifier.UUIDString];
    
    self.currentSystem = system;
    
    if(self.systemServiceDelegate)
    {
        [self.systemServiceDelegate didConnectToSystem:system success:success error:error];
    }*/
    
}

- (void)didDisconnectToSystem:(id)system error:(NSError*)error {
    [self unsubscribeServices];
    
    self.connectedSystem = nil;
    
    [self.systemService scanForSystems];
    
    self.state = SystemBLEStateScanning;
    self.systemSettings.connection = 1;
}

#pragma mark TAPPlayControlServiceDelegate

- (void)system:(id)system didUpdateVolume:(NSString*)volume
{
    self.systemSettings.volume = volume;
    
    [self notifyUpdate:@"volume"];
}

#pragma mark - TAPPlayControlServiceDelegate method
- (void)system:(id)system didUpdatePlayStatus:(TAPPlayControlServicePlayStatus)status
{
    self.systemSettings.TAPPlayControlServicePlayStatus = status;
    self.systemSettings.playStatus = status == TAPPlayControlServicePlayStatusPlay ? 1 : 0;

    [self notifyUpdate:@"playStatus"];
}

#pragma mark helper method

- (void)notifyUpdate:(NSString*)feature
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SystemValueDidUpdate object:self userInfo:@{@"feature" : feature}];
}

- (void)addSystem:(TAPSystem*)system systems:(NSMutableArray*)systems
{
    BOOL isExist = NO;
    TAPSystem* targetSystem = nil;
    
    for(TAPSystem* discoveredSystem in systems)
    {
        CBPeripheral* discoveredPeripheral = [discoveredSystem instance];
        CBPeripheral* peripheral = [system instance];
        
        if([discoveredPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString])
        {
            isExist = YES;
            targetSystem = discoveredSystem;
        }
    }
    
    if(!isExist)
    {
        [systems addObject:system];
        
    }else{
        
        [systems replaceObjectAtIndex:[systems indexOfObject:targetSystem] withObject:system];
    }
}

@end
