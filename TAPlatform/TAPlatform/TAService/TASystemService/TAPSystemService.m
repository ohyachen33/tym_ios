//
//  TAPSystemService.m
//  TAPSystemService
//
//  Created by Lam Yick Hong on 31/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPSystemService.h"
#import "TAPProtocolAdaptor.h"
#import "TAPError.h"

NSString * const TAPSystemKeyDisplay            =   @"Display";
NSString * const TAPSystemKeyTimeout            =   @"Timeout";
NSString * const TAPSystemKeyStandby            =   @"Standby";
NSString * const TAPSystemKeyBrightness         =   @"Brightness";

NSString * const TAPSystemKeyConnectionDuration =   @"ConnectTimeout";

@interface TAPService(Private)

@property (nonatomic, strong) id<TAPProtocolAdaptor> protocolProxy;

- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block;
- (void)reset:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)subscribe:(TAPropertyType)targetType system:(id)system;
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system;
- (NSError*)unsupportedErrorWithInfo:(NSDictionary*)info;
- (void)registerReadObserver:(id)observer forKey:(id)observerKey;

@end

@interface TAPSystemService()

@property (nonatomic, strong) NSMutableDictionary* connectionObservers;
@property NSInteger connectionExpirationDuration;

@property (nonatomic, strong) NSTimer* connectionTimer;

@end

@implementation TAPSystemService

#pragma mark - Service Interface

- (id)initWithType:(NSString*)type config:(NSDictionary*)config delegate:(id<TAPSystemServiceDelegate>)delegate
{
    if(self = [super initWithType:type config:config])
    {
        self.delegate = delegate;
        self.state = (TAPSystemServiceState)[self.protocolProxy state];
        
        self.connectionObservers = [[NSMutableDictionary alloc] init];
        
        //Handle connection timeout setting from config. if not, set it to -1
        NSInteger duration = -1;
        
        NSNumber* connectionExpirationDuration = [config objectForKey:TAPSystemKeyConnectionDuration];
        if(connectionExpirationDuration)
        {
            duration = [connectionExpirationDuration integerValue];
        }
        
        self.connectionExpirationDuration = duration;
        
        //observe our own state change
        [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        //observe the protocol state update
        [self observe:TAPProtocolEventDidUpdateState handler:^(NSNotification* note){
            
            TAPSystemServiceState state;
            
            NSInteger stateValue = [[[note userInfo] objectForKey:TAPProtocolKeyState] integerValue];
            
            switch (stateValue) {
                case TAPProtocolStateReady:
                case TAPProtocolStateOn:
                {
                    state = TAPSystemServiceStateReady;
                }
                    break;
                case TAPProtocolStateOff:
                {
                    state = TAPSystemServiceStateOff;
                }
                    break;
                case TAPProtocolStateUnauthorized:
                {
                    state = TAPSystemServiceStateUnauthorized;
                }
                    break;
                case TAPProtocolStateUnsupported:
                {
                    state = TAPSystemServiceStateUnsupported;
                }
                    break;
                default:
                {
                    state = TAPSystemServiceStateUnknown;
                }
                    break;
            }

            self.state = state;
        }];
        
        //observe the discovered system
        [self observe:TAPProtocolEventDidDiscoverSystem handler:^(NSNotification* note){
            
            id system = [[note userInfo] objectForKey:TAPProtocolKeyTargetSystem];
            NSNumber*  rssi = [[note userInfo] objectForKey:@"TAPProtocolKeyRSSI"];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverSystem:RSSI:)])
            {
                [self.delegate didDiscoverSystem:system RSSI:rssi];
            }
        }];
        
        //observe connect system result
        [self observe:TAPProtocolEventDidConnectSystem handler:^(NSNotification* note){
            
            //stop the connection timer
            [self stopConnectionTimer];
            
            id system = [[note userInfo] objectForKey:TAPProtocolKeyTargetSystem];
            BOOL success = [[[note userInfo] objectForKey:TAPProtocolKeySuccess] boolValue];
            NSError* error = [[note userInfo] objectForKey:TAPProtocolKeyError];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(didConnectToSystem:success:error:)])
            {
                [self.delegate didConnectToSystem:system success:success error:error];
            }
        }];
        
        //observe disconnect system result
        [self observe:TAPProtocolEventDidDisconnectSystem handler:^(NSNotification* note){
            
            id system = [[note userInfo] objectForKey:TAPProtocolKeyTargetSystem];
            NSError* error = [[note userInfo] objectForKey:TAPProtocolKeyError];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectToSystem:error:)])
            {
                [self.delegate didDisconnectToSystem:system error:error];
            }
        }];
        
        //observe update system result
        [self observe:TAPProtocolEventDidUpdateSystem handler:^(NSNotification* note){
            
            id system = [[note userInfo] objectForKey:TAPProtocolKeyTargetSystem];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(didUpdateSystem:)])
            {
                [self.delegate didUpdateSystem:system];
            }
        }];
        
        return self;
    }
    
    return nil;
}

- (void)scanForSystems
{
    [self.protocolProxy startScanWithOptions:nil];
}

- (void)scanForSystemsWithOptions:(NSDictionary*)options
{
    [self.protocolProxy startScanWithOptions:options];
}


- (void)stopScanForSystems
{
    [self.protocolProxy stopScan];
}

- (void)connectSystem:(id)system
{
    if(self.connectionExpirationDuration > 0)
    {
        if(!self.connectionTimer)
        {
            self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:self.connectionExpirationDuration target:self selector:@selector(onConnectionTimer:) userInfo:@{TAPProtocolKeyTargetSystem : system} repeats:NO];
        }
    }
    
    [self.protocolProxy connectSystem:system];
}

- (void)disconnectSystem:(id)system
{
    [self.protocolProxy disconnectSystem:system];
}

- (void)system:(id)system enterDFUMode:(void (^)(id))complete
{
    [self read:TAPropertyTypeDFU system:system handler:^(NSDictionary* data, NSError* error){
        
        complete(data);
    }];

}

- (void)system:(id)system features:(void (^)(NSArray*))features
{
    [self read:TAPropertyTypeAvailableFeatures system:system handler:^(NSDictionary* data, NSError* error){
        
        NSArray* datas = [data objectForKey:@"value"];
        NSMutableArray* numbers = [[NSMutableArray alloc] init];
        
        for(NSData* data in datas)
        {
            int16_t buff;
            [data getBytes:&buff length:sizeof(buff)];
            NSNumber* number = [NSNumber numberWithInteger:buff];
            [numbers addObject:number];
        }
        
        features(numbers);
    }];
}

- (void)system:(id)system deviceName:(void (^)(NSString*))deviceName
{
    [self read:TAPropertyTypeDeviceName system:system handler:^(NSDictionary* data, NSError* error){
        
        NSString* name = [[NSString alloc] initWithData:[data objectForKey:@"value"] encoding:NSUTF8StringEncoding];
        
        deviceName(name);
    }];
}

- (void)system:(id)system customName:(void (^)(NSString*))customName
{
    //TODO: implementation
}

- (void)system:(id)system writeCustomName:(NSString*)customName completion:(void (^)(id))complete
{
    TAPropertyType type = TAPropertyTypeDeviceName;
    
    NSData* data = [customName dataUsingEncoding:NSUTF8StringEncoding];
    
    [self write:type data:data system:system handler:^(id result, NSError* error){
        //TODO: expand this to receive a dictionary
        complete(error);
    }];
}

- (void)system:(id)system modelNumber:(void (^)(NSString*))modelNumber
{
    [self read:TAPropertyTypeModelNumber system:system handler:^(NSDictionary* data, NSError* error){
        
        //This convertion may be done in somewhere else? should it even do in a service layer or in protocol?
        NSString* ver = [[NSString alloc] initWithData:[data objectForKey:@"value"] encoding:NSASCIIStringEncoding];
        
        modelNumber(ver);
    }];
}

- (void)system:(id)system serialNumber:(void (^)(NSString*))serialNumber
{
    [self read:TAPropertyTypeSerialNumber system:system handler:^(NSDictionary* data, NSError* error){
        
        //This convertion may be done in somewhere else? should it even do in a service layer or in protocol?
        NSString* ver = [[NSString alloc] initWithData:[data objectForKey:@"value"] encoding:NSASCIIStringEncoding];
        
        serialNumber(ver);
    }];
    
}

- (void)system:(id)system hardwareVersion:(void (^)(NSString*))version
{
    [self read:TAPropertyTypeHardwareNumber system:system handler:^(NSDictionary* data, NSError* error){
        
        //This convertion may be done in somewhere else? should it even do in a service layer or in protocol?
        NSString* ver = [[NSString alloc] initWithData:[data objectForKey:@"value"] encoding:NSASCIIStringEncoding];
        
        version(ver);
    }];
    
}

- (void)system:(id)system softwareVersion:(void (^)(NSString*))version;
{
    [self read:TAPropertyTypeSoftwareVersion system:system handler:^(NSDictionary* data, NSError* error){
        
        //This convertion may be done in somewhere else? should it even do in a service layer or in protocol?
        NSString *ver = [[NSString alloc] initWithData:[data objectForKey:@"value"] encoding:NSASCIIStringEncoding];
        
        version(ver);
    }];
}

- (void)system:(id)system productName:(void (^)(NSString*))name;
{
    //use the same package as software version
    [self read:TAPropertyTypeProductName system:system handler:^(NSDictionary* data, NSError* error){
        
        //This convertion may be done in somewhere else? should it even do in a service layer or in protocol?
        NSString *pro = [[NSString alloc] initWithData:[data objectForKey:@"value"] encoding:NSASCIIStringEncoding];
        
        name(pro);
    }];
}

- (void)system:(id)system batteryLevel:(void (^)(NSString*))batteryLevel;
{
    [self read:TAPropertyTypeBattery system:system handler:^(NSDictionary* data, NSError* error){
        
        //This convertion may be done in somewhere else? should it even do in a service layer or in protocol?
        char buff;
        [[data objectForKey:@"value"] getBytes:&buff length:sizeof(buff)];
        int i = buff;
        
        NSString* level = [NSString stringWithFormat:@"%d", i];
        
        batteryLevel(level);
    }];
}

- (void)startMonitorBatteryStatusOfSystem:(id)system
{
    [self subscribe:TAPropertyTypeBattery system:system];
}

- (void)stopMonitorBatteryStatusOfSystem:(id)system
{
    [self unsubscribe:TAPropertyTypeBattery system:system];
}

- (void)system:(id)system locationName:(void (^)(NSString*))locationName
{
    //TODO: implementation
}

- (void)system:(id)system writeLocationName:(NSString*)locationName completion:(void (^)(id))complete
{
    //TODO: implementation
}

- (void)system:(id)system color:(void (^)(UIColor*))color
{
    //TODO: implementation
}

- (void)system:(id)system customColor:(void (^)(UIColor*))customColor
{
    //TODO: implementation
}

- (void)system:(id)system writeCustomColor:(UIColor*)customColor completion:(void (^)(id))complete
{
    //TODO: implementation
}

- (void)system:(id)system powerStatus:(void (^)(TAPSystemServicePowerStatus))status
{
    [self read:TAPropertyTypePowerStatus system:system handler:^(NSDictionary* data, NSError* error){
        
        //This convertion may be done in somewhere else? should it even do in a service layer or in protocol?
        char buff;
        [[data objectForKey:@"value"] getBytes:&buff length:sizeof(buff)];
        int i = buff;
        
        TAPSystemServicePowerStatus powerStatus = i;
        
        status(powerStatus);
    }];
}

- (void)system:(id)system turnPowerStatus:(TAPSystemServicePowerStatus)status completion:(void (^)(id))complete
{
    int8_t value = status;
    
    NSData* data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self write:TAPropertyTypePowerStatus data:data system:system handler:^(id result, NSError* error){
        
        //TODO: expand this to receive a dictionary
        complete(error);
    }];
}

- (void)startMonitorPowerStatusOfSystem:(id)system
{
    [self subscribe:TAPropertyTypePowerStatus system:system];
}

- (void)stopMonitorPowerStatusOfSystem:(id)system
{
    [self unsubscribe:TAPropertyTypePowerStatus system:system];
}

- (void)system:(id)system speakerLink:(void (^)(NSDictionary*))config
{
    //TODO: implementation
}

- (void)system:(id)system configSpeakerLink:(NSDictionary*)config completion:(void (^)(id))complete
{
    //TODO: implementation
}

- (void)startMonitorSpeakerLinkConfigOfSystem:(id)system
{
    //TODO: implementation
}

- (void)stopMonitorSpeakerLinkConfigOfSystem:(id)system
{
    //TODO: implementation
}

- (void)system:(TAPSystem*)system settings:(void (^)(NSDictionary*, NSError*))settings
{
    NSString* observerKey = [NSString stringWithFormat:@"%@ - %@", @"read", @"settings-all"];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAPProtocolEventDidUpdateValue object:nil queue:nil usingBlock:^(NSNotification* note){
        
        NSDictionary* value = [[note userInfo] objectForKey:TAPProtocolKeyValue];
        NSArray* values = [value objectForKey:@"value"];
        TAPropertyType type = [[[note userInfo] objectForKey:TAPProtocolPropertyType] integerValue];
        NSError* error = [[note userInfo] objectForKey:TAPProtocolKeyError];
        
        id targetObserver = [self.connectionObservers objectForKey:observerKey];
        
        //only return result if we have a observer, it means it's the first result
        if(targetObserver && type >= 0 && type < 3 ){
            
            //Because we are loading the whole settings, it should always be the first one in the table. If the table is revised, we should always come back to this. Not safe, may need to think of a new mechanism
            if([values isKindOfClass:[NSArray class]])
            {
                NSArray* keys = @[TAPSystemKeyDisplay,
                                  TAPSystemKeyStandby,
                                  TAPSystemKeyTimeout
                                  ];
                
                NSMutableDictionary* settingsInfo = [[NSMutableDictionary alloc] init];
                
                DDLogVerbose(@"%@", [values description]);
                
                for(int i = 0; i < [values count]; i++){
                    
                    NSData* data = [values objectAtIndex:i];
                    
                    int16_t buff;
                    [data getBytes:&buff length:sizeof(buff)];
                    
                    
                    DDLogVerbose(@"%@", @"-------------------");
                    DDLogVerbose(@"%@", [keys objectAtIndex:i]);
                    
                    DDLogVerbose(@"%d", buff);
                    
                    NSNumber* number = [NSNumber numberWithFloat:((float)buff / 10.0)];
                    
                    DDLogVerbose(@"%f", [number floatValue]);
                    
                    [settingsInfo setObject:number forKey:[keys objectAtIndex:i]];
                }
                
                //Return the value
                settings(settingsInfo, error);
                
                if(targetObserver)
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:targetObserver name:TAPProtocolEventDidUpdateValue object:nil];
                    [self.connectionObservers removeObjectForKey:observerKey];
                }
                
            }
            
        }
        
    }];
    
    [self registerReadObserver:observer forKey:observerKey];
    
    
    [self.protocolProxy perform:@{@"operation" : @"read", @"property" : @"settings-all", @"system" : system}];
}

- (void)system:(TAPSystem*)system writeSettingsType:(NSString*)type value:(id)value completion:(void (^)(id))complete
{
    
    TAPropertyType property = TAPropertyTypeUnknown;
    
    if([type isEqualToString:TAPSystemKeyDisplay])
    {
        property = TAPropertyTypeDisplay;
        
    }else if([type isEqualToString:TAPSystemKeyStandby])
    {
        property = TAPropertyTypeStandby;
        
    }else if([type isEqualToString:TAPSystemKeyTimeout])
    {
        property = TAPropertyTypeTimeout;
        
    }else if([type isEqualToString:TAPSystemKeyBrightness])
    {
        property = TAPropertyTypeBrightness;
        
    }
    
    if(value)
    {
        NSInteger i = [value integerValue];
        i *= 10;
        
        NSData* data = [NSData dataWithBytes:&i length:sizeof(i)];
        
        [self write:property data:data system:system handler:^(id result, NSError* error){
            
            //TODO: expand this to receive a dictionary
            complete(error);
        }];
    }
}

- (void)system:(TAPSystem*)system preset:(NSString*)presetId name:(void (^)(NSString*))presetName;
{
    TAPropertyType type = [self presetPropertyTypeByPresetId:presetId];
    
    [self read:type system:system handler:^(NSDictionary* data, NSError* error){
        
        //already a string here
        presetName([data objectForKey:@"value"]);
        
    }];
}

- (void)system:(TAPSystem*)system preset:(NSString*)presetId writeName:(NSString*)name completion:(void (^)(id))complete
{
    TAPropertyType type = [self presetPropertyTypeByPresetId:presetId];
    
    NSData* data = [name dataUsingEncoding:NSASCIIStringEncoding];
    
    [self write:type data:data system:system handler:^(id result, NSError* error){
        //TODO: expand this to receive a dictionary
        complete(error);
    }];
    
}

- (void)revertAllPresetNamesOfSystem:(TAPSystem*)system completion:(void (^)(id))complete
{
    TAPropertyType type = TAPropertyTypePresetName1;
    
    [self reset:type system:system handler:^(NSDictionary* result, NSError* error){
        //TODO: expand this to receive a dictionary
        complete(result);
    }];
}

- (void)system:(TAPSystem*)system loadToCurrentFromPreset:(NSString*)presetId completion:(void (^)(id))complete
{
    [self write:TAPropertyTypePresetLoading data:presetId system:system handler:^(id result, NSError* error){
        //TODO: expand this to receive a dictionary
        complete(error);
    }];
}

- (void)system:(TAPSystem*)system saveCurrentToPreset:(NSString*)presetId completion:(void (^)(id))complete
{
    [self write:TAPropertyTypePresetSaving data:presetId system:system handler:^(id result, NSError* error){
        //TODO: expand this to receive a dictionary
        complete(error);
    }];
}

- (void)system:(TAPSystem*)system toggleScreen:(void (^)(id))complete
{
    [self write:TAPropertyTypeScreenOnOff data:nil system:system handler:^(id result, NSError* error){
        //TODO: expand this to receive a dictionary
        complete(error);
    }];
}

- (void)system:(id)system factoryReset:(void (^)(id))complete
{
    [self write:TAPropertyTypeFactoryReset data:nil system:system handler:^(id result, NSError* error){
        //TODO: expand this to receive a dictionary
        complete(error);
    }];
}

- (void)system:(TAPSystem*)system displayLock:(void (^)(id))complete
{
    [self write:TAPropertyTypeDisplayLock data:nil system:system handler:^(id result, NSError* error){
        //TODO: expand this to receive a dictionary
        complete(error);
    }];
}

- (void)system:(id)system didReceiveUpdateValue:(NSDictionary*)data type:(TAPropertyType)targetType
{
    
    DDLogDebug(@"type: %ld dictionary: %@", (long)targetType, [data description]);
    
    id value = [data objectForKey:@"value"];
    
    switch (targetType) {
        case TAPropertyTypePowerStatus:
        {
            //This convertion may be done in somewhere else? should it even do in a service layer or in protocol?
            char buff;
            [[data objectForKey:@"value"] getBytes:&buff length:sizeof(buff)];
            int i = buff;
            
            TAPSystemServicePowerStatus powerStatus = i;
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdatePowerStatus:)])
            {
                [self.delegate system:system didUpdatePowerStatus:powerStatus];
            }
        }
            break;
        case TAPropertyTypeBattery:
        {
            int16_t i;
            [value getBytes:&i length:sizeof(i)];
            
            NSString *display = [NSString stringWithFormat:@"%d",i];

            if(self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdateBatteryStatus:)])
            {
                [self.delegate system:system didUpdateBatteryStatus:display];
            }
        }
            break;

            
        default:
            break;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"state"]) {
        
        TAPSystemServiceState state = [[change objectForKey:@"new"] integerValue];
        
        if(self.delegate)
        {
            [self.delegate didUpdateState:state];            
        }
    }
    
}

#pragma mark helper methods

- (void)observe:(NSString*)eventName handler:(void (^)(NSNotification*))note{
    
    [self.connectionObservers setObject:[[NSNotificationCenter defaultCenter] addObserverForName:eventName object:nil queue:nil usingBlock:note] forKey:eventName];
    
}

- (TAPropertyType)presetPropertyTypeByPresetId:(NSString*)presetId
{
    TAPropertyType type = TAPropertyTypeUnknown;
    
    if([presetId isEqualToString:@"1"])
    {
        type = TAPropertyTypePresetName1;
        
    }else if([presetId isEqualToString:@"2"])
    {
        type = TAPropertyTypePresetName2;
        
    }else if([presetId isEqualToString:@"3"])
    {
        type = TAPropertyTypePresetName3;
        
    }
    
    return type;
}

- (void)onConnectionTimer:(NSTimer*)timer
{
    NSDictionary* userInfo = [self.connectionTimer userInfo];
    id system = [userInfo objectForKey:TAPProtocolKeyTargetSystem];
    BOOL success = NO;
    NSError* error = [NSError errorWithDomain:TAPServiceErrorDomain code:TAPErrorCodeTimeout userInfo:userInfo];
    
    [self stopConnectionTimer];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didConnectToSystem:success:error:)])
    {
        [self.delegate didConnectToSystem:system success:success error:error];
    }
}

- (void)stopConnectionTimer
{
    if(self.connectionTimer)
    {
        [self.connectionTimer invalidate];
        self.connectionTimer = nil;
    }
}

@end
