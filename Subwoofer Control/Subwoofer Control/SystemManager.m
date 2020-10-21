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
        self.connectedSystems = [[NSMutableArray alloc] init];
        
        //had start from AppDelegate.
//        [self start];
        
    }
    return self;
}

- (void)start
{
    //observe state change
    [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    //init services
    NSDictionary* serviceInfo = [DocumentUtils dictionaryFromResources:@"system"];
    self.systemService = [[TAPSystemService alloc] initWithType:@"BLE" config:@{@"serviceInfo" : serviceInfo, TAPSystemKeyConnectionDuration : [NSNumber numberWithInteger:10]} delegate:self];
    self.playControlService = [[TAPPlayControlService alloc] initWithType:@"BLE"];
    self.playControlService.delegate = self;
    self.dspService = [[TAPDigitalSignalProcessingService alloc] initWithType:@"BLE"];
    self.dspService.delegate = self;
    self.otaService = [[TAPFirmwareOverTheAirUpdateService alloc] initWithType:@"BLE"];
    self.otaService.delegate = self;
    
    self.systemSettings = [[TASystemSettings alloc] init];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"state"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SystemStateDidUpdate object:self userInfo:nil];
    }
}

- (void)retrieveAllSettingFromSystem:(TAPSystem *)system complete:(void (^)(NSError*))complete
{
    NSArray* keys = @[TAPDigitalSignalProcessingKeyDisplay,
                      TAPDigitalSignalProcessingKeyTimeout,
                      TAPDigitalSignalProcessingKeyStandby,
                      
                      TAPDigitalSignalProcessingKeyLowPassOnOff,
                      TAPDigitalSignalProcessingKeyLowPassFrequency,
                      TAPDigitalSignalProcessingKeyLowPassSlope,
                      
                      TAPDigitalSignalProcessingKeyPEQ1OnOff,
                      TAPDigitalSignalProcessingKeyEQ1Frequency,
                      TAPDigitalSignalProcessingKeyEQ1Boost,
                      TAPDigitalSignalProcessingKeyEQ1QFactor,
                      
                      TAPDigitalSignalProcessingKeyPEQ2OnOff,
                      TAPDigitalSignalProcessingKeyEQ2Frequency,
                      TAPDigitalSignalProcessingKeyEQ2Boost,
                      TAPDigitalSignalProcessingKeyEQ2QFactor,
                      
                      TAPDigitalSignalProcessingKeyPEQ3OnOff,
                      TAPDigitalSignalProcessingKeyEQ3Frequency,
                      TAPDigitalSignalProcessingKeyEQ3Boost,
                      TAPDigitalSignalProcessingKeyEQ3QFactor,
                      
                      TAPDigitalSignalProcessingKeyRGCOnOff,
                      TAPDigitalSignalProcessingKeyRGCFrequency,
                      TAPDigitalSignalProcessingKeyRGCSlope,
                      
                      TAPDigitalSignalProcessingKeyVolume,
                      TAPDigitalSignalProcessingKeyPhase,
                      TAPDigitalSignalProcessingKeyPolarity,
                      TAPDigitalSignalProcessingKeyTunning];
    
    [self system:system targetKeys:keys equalizer:^(NSDictionary* equalizer, NSError* error){
        
        if(error)
        {
            NSLog(@"Error on retreiving all settings and stored in system settings - %@", [error localizedDescription]);
            
        }else{
            
            NSLog(@"Retreived all settings and stored in system settings");
        }
        
        complete(error);
    }];
    
}

- (void)system:(TAPSystem*)system targetKeys:(NSArray*)keys equalizer:(void (^)(NSDictionary*, NSError*))complete
{
    [self.dspService system:system targetKeys:keys equalizer:^(NSDictionary* equalizer, NSError* error){
        
        for(NSString* key in keys)
        {
            [self saveValueFrom:equalizer type:key];
        }
        complete(equalizer, error);
        
    }];
}

#pragma mark TASystemServiceDelegate

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
        
        
            self.isDFUMode = [self.otaService checkFirmwareIsDFUMode:self.connectedSystem];

            if (!self.isDFUMode) {
                //start monitoring
                if (![self.connectedSystems containsObject:system]) {
                    [self.playControlService startMonitorVolumeOfSystem:self.connectedSystem];
                    [self.dspService startMonitorEqualizerOfSystem:self.connectedSystem];
                    [self.connectedSystems addObject:system];
                }
                
                //        start retrieve first value
                [self retrieveAllSettingFromSystem:self.connectedSystem complete:^(NSError* error){
                    
                    [self performSelector:@selector(notifyUpdate) withObject:nil afterDelay:0.2];
                }];
            }else{
                [[SystemManager sharedManager].otaService startMonitorACKOfSystem:[SystemManager sharedManager].connectedSystem];
            }
        
    }else{
        NSLog(@"Failed to connect to %@", [[system instance] name]);
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
    [self.playControlService stopMonitorVolumeOfSystem:system];
    [self.dspService stopMonitorEqualizerOfSystem:system];
    
    if (self.isDFUMode) {
        [self.otaService stopMonitorACKOfSystem:self.connectedSystem];
    }
    [self.connectedSystems removeObject:system];
    if ([system isEqual:self.connectedSystem]) {
        self.connectedSystem = nil;
    }
    
    [self.systemService scanForSystems];
    
    self.state = SystemBLEStateScanning;
}

#pragma mark TAPPlayControlServiceDelegate

- (void)system:(id)system didUpdateVolume:(NSString*)volume
{
    self.systemSettings.volume = volume;
    
    [self notifyUpdate];
}

#pragma mark TAPDigitalSignalProcessingServiceDelegate

- (void)system:(id)system didUpdateEqualizer:(NSDictionary *)equalizer
{
    NSLog(@"%@", [equalizer description]);
    if ([equalizer.allKeys containsObject:[NSNumber numberWithInteger:TAPropertyTypeDFU]]) {
        NSData *data = equalizer[[NSNumber numberWithInteger:TAPropertyTypeDFU]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OTADidUpdate" object:data];
        
    }else if ([equalizer.allKeys containsObject:[NSNumber numberWithInteger:TAPropertyTypeBootloaderCommand]]) {
        NSData *data = equalizer[[NSNumber numberWithInteger:TAPropertyTypeBootloaderCommand]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OTADidUpdate" object:data];
        
    }else{
        for(NSString* key in [equalizer allKeys])
        {
            [self saveValueFrom:equalizer type:key];
        }
        
        [self notifyUpdate];
        
    }
}

#pragma mark TAPFirmwareOverTheAirUpdateServiceDelegate

- (void)system:(id)system didUpdateStatus:(TAPFirmwareUpdateResponse)status
{
    if (status == TAPFirmwareUpdateResponseFinish) {
        self.isDFUMode = NO;
        
        NSMutableDictionary* OTADeviceDic = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"DevicesInUpdated"]];
        [OTADeviceDic removeObjectForKey:((CBPeripheral*)[self.connectedSystem instance]).identifier.UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:OTADeviceDic forKey:@"DevicesInUpdated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSLog(@"didUpdateStatus:%ld",status);
}

- (void)system:(id)system didUpdateProgress:(int)progress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"otaProgressDidUpdate" object:[NSNumber numberWithInt:progress]];
}

#pragma mark helper method

- (void)notifyUpdate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SystemValueDidUpdate object:self userInfo:@{@"SystemSettings" : self.systemSettings}];
}

- (void)saveValueFrom:(NSDictionary*)dictionary type:(NSString*)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        id value = [dictionary objectForKey:type];
        
        if([type isEqualToString:TAPDigitalSignalProcessingKeyDisplay])
        {
            self.systemSettings.display = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyTimeout])
        {
            self.systemSettings.timeout = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyStandby])
        {
            self.systemSettings.standby = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyLowPassOnOff])
        {
            self.systemSettings.lowPassOnOff = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyLowPassFrequency])
        {
            self.systemSettings.lowPassFrequency = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyLowPassSlope])
        {
            self.systemSettings.lowPassSlope = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyPEQ1OnOff])
        {
            self.systemSettings.pEq1OnOff = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ1Frequency])
        {
            self.systemSettings.pEq1Frequency = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ1Boost])
        {
            self.systemSettings.pEq1Boost = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ1QFactor])
        {
            self.systemSettings.pEq1QFactor = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyPEQ2OnOff])
        {
            self.systemSettings.pEq2OnOff = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ2Frequency])
        {
            self.systemSettings.pEq2Frequency = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ2Boost])
        {
            self.systemSettings.pEq2Boost = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ2QFactor])
        {
            self.systemSettings.pEq2QFactor = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyPEQ3OnOff])
        {
            self.systemSettings.pEq3OnOff = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ3Frequency])
        {
            self.systemSettings.pEq3Frequency = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ3Boost])
        {
            self.systemSettings.pEq3Boost = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ3QFactor])
        {
            self.systemSettings.pEq3QFactor = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyRGCOnOff])
        {
            self.systemSettings.rgcOnOff = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyRGCFrequency])
        {
            self.systemSettings.rgcFrequency = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyRGCSlope])
        {
            self.systemSettings.rgcSlope = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyVolume])
        {
            self.systemSettings.volume = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyPhase])
        {
            self.systemSettings.phase = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyPolarity])
        {
            self.systemSettings.polarity = value;
        }else if([type isEqualToString:TAPDigitalSignalProcessingKeyTunning])
        {
            self.systemSettings.tunning = value;
        }
        
    });
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
