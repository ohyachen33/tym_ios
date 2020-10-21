//
//  TASystemService.m
//  TASystemService
//
//  Created by Lam Yick Hong on 31/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TASystemService.h"
#import "TAProtocolAdaptor.h"

NSString * const TASystemKeyDisplay            =   @"Display";
NSString * const TASystemKeyTimeout            =   @"Timeout";
NSString * const TASystemKeyStandby            =   @"Standby";

@interface TAService(Private)

@property (nonatomic, strong) id<TAProtocolAdaptor> protocolProxy;
@property (nonatomic, strong) NSMutableDictionary* observers;

- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block;
- (void)subscribe:(TAPropertyType)targetType system:(id)system;
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system;

@end

@implementation TASystemService

#pragma mark - Service Interface

- (id)initWithType:(NSString*)type config:(NSDictionary*)config delegate:(id<TASystemServiceDelegate>)delegate
{
    if(self = [super initWithType:type config:config])
    {
        self.delegate = delegate;
        self.state = (TASystemServiceState)[self.protocolProxy state];
        
        //observe the state change
        [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        //observe the protocol state update
        [self observe:TAProtocolEventDidUpdateState handler:^(NSNotification* note){
            
            TASystemServiceState state = [[[note userInfo] objectForKey:TAProtocolKeyState] integerValue];
            
            self.state = state;
        }];
        
        //observe the discovered system
        [self observe:TAProtocolEventDidDiscoverSystem handler:^(NSNotification* note){
            
            id system = [[note userInfo] objectForKey:TAProtocolKeyTargetSystem];
            NSNumber*  rssi = [[note userInfo] objectForKey:@"RSSI"];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverSystem:RSSI:)])
            {
                [self.delegate didDiscoverSystem:system RSSI:rssi];
            }
        }];
        
        //observe connect system result
        [self observe:TAProtocolEventDidConnectSystem handler:^(NSNotification* note){
            
            id system = [[note userInfo] objectForKey:TAProtocolKeyTargetSystem];
            BOOL success = [[[note userInfo] objectForKey:TAProtocolKeySuccess] boolValue];
            NSError* error = [[note userInfo] objectForKey:TAProtocolKeyError];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(didConnectToSystem:success:error:)])
            {
                [self.delegate didConnectToSystem:system success:success error:error];
            }
        }];
        
        //observe disconnect system result
        [self observe:TAProtocolEventDidDisconnectSystem handler:^(NSNotification* note){
            
            id system = [[note userInfo] objectForKey:TAProtocolKeyTargetSystem];
            NSError* error = [[note userInfo] objectForKey:TAProtocolKeyError];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectToSystem:error:)])
            {
                [self.delegate didDisconnectToSystem:system error:error];
            }
        }];
        
        return self;
    }
    
    return nil;
}

- (void)scanForSystems
{
    [self.protocolProxy startScan];
}

- (void)stopScanForSystems
{
    [self.protocolProxy stopScan];
}

- (void)connectSystem:(id)system
{
    [self.protocolProxy connectSystem:system];
}

- (void)disconnectSystem:(id)system
{
    [self.protocolProxy disconnectSystem:system];
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
    //TODO: implementation
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
        NSString* ver = [[NSString alloc] initWithData:[data objectForKey:@"value"] encoding:NSASCIIStringEncoding];
        
        version(ver);
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

- (void)system:(id)system powerStatus:(void (^)(TASystemServicePowerStatus))status
{
    [self read:TAPropertyTypePowerStatus system:system handler:^(NSDictionary* data, NSError* error){
        
        //This convertion may be done in somewhere else? should it even do in a service layer or in protocol?
        char buff;
        [[data objectForKey:@"value"] getBytes:&buff length:sizeof(buff)];
        int i = buff;
        
        TASystemServicePowerStatus powerStatus = i;
        
        status(powerStatus);
    }];
}

- (void)system:(id)system turnPowerStatus:(TASystemServicePowerStatus)status completion:(void (^)(id))complete
{
    int8_t value = status;
    
    NSData* data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self write:TAPropertyTypePowerStatus data:data system:system handler:^(id result, NSError* error){
        complete(result);
    }];
}

- (void)startMonitorPowerStatusOfSystem:(id)system
{
    //TODO: implementation
}

- (void)stopMonitorPowerStatusOfSystem:(id)system
{
    //TODO: implementation
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

- (void)system:(TASystem*)system settings:(void (^)(NSDictionary*, NSError*))settings
{
    NSString* observerKey = [NSString stringWithFormat:@"%@ - %@", @"read", @"settings-all"];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAProtocolEventDidUpdateValue object:nil queue:nil usingBlock:^(NSNotification* note){
        
        NSDictionary* value = [[note userInfo] objectForKey:TAProtocolKeyValue];
        NSArray* values = [value objectForKey:@"value"];
        TAPropertyType type = [[[note userInfo] objectForKey:TAProtocolPropertyType] integerValue];
        NSError* error = [[note userInfo] objectForKey:TAProtocolKeyError];
        
        id targetObserver = [self.observers objectForKey:observerKey];
        
        //only return result if we have a observer, it means it's the first result
        if(targetObserver){
            
            //Because we are loading the whole settings, it should always be the first one in the table. If the table is revised, we should always come back to this. Not safe, may need to think of a new mechanism
            if([values isKindOfClass:[NSArray class]])
            {
                NSArray* keys = @[TASystemKeyDisplay,
                                  TASystemKeyStandby,
                                  TASystemKeyTimeout
                                  ];
                
                NSMutableDictionary* settingsInfo = [[NSMutableDictionary alloc] init];
                
                NSLog(@"%@", [values description]);
                
                for(int i = 0; i < [values count]; i++){
                    
                    NSData* data = [values objectAtIndex:i];
                    
                    int16_t buff;
                    [data getBytes:&buff length:sizeof(buff)];
                    
                    
                    NSLog(@"%@", @"-------------------");
                    NSLog(@"%@", [keys objectAtIndex:i]);
                    
                    NSLog(@"%d", buff);
                    
                    NSNumber* number = [NSNumber numberWithFloat:((float)buff / 10.0)];
                    
                    NSLog(@"%f", [number floatValue]);
                    
                    [settingsInfo setObject:number forKey:[keys objectAtIndex:i]];
                }
                
                //Return the value
                settings(settingsInfo, error);
                
                if(targetObserver)
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:targetObserver];
                    [self.observers removeObjectForKey:observerKey];
                }
                
            }
            
        }
        
    }];
    
    [self.observers setObject:observer forKey:observerKey];
    
    
    [self.protocolProxy perform:@{@"operation" : @"read", @"property" : @"settings-all", @"system" : system}];
}

- (void)system:(TASystem*)system writeSettingsType:(NSString*)type value:(id)value completion:(void (^)(id))complete
{
    
    TAPropertyType property = TAPropertyTypeUnknown;
    
    if([type isEqualToString:TASystemKeyDisplay])
    {
        property = TAPropertyTypeDisplay;
        
    }else if([type isEqualToString:TASystemKeyStandby])
    {
        property = TAPropertyTypeStandby;
        
    }else if([type isEqualToString:TASystemKeyTimeout])
    {
        property = TAPropertyTypeTimeout;
        
    }
    
    if(value)
    {
        NSInteger i = [value integerValue];
        i *= 10;
        
        NSData* data = [NSData dataWithBytes:&i length:sizeof(i)];
        
        [self write:property data:data system:system handler:^(id result, NSError* error){
            complete(result);
        }];
    }
}

- (void)system:(TASystem*)system preset:(NSString*)presetId name:(void (^)(NSString*))presetName;
{
    TAPropertyType type = [self presetPropertyTypeByPresetId:presetId];
    
    [self read:type system:system handler:^(NSDictionary* data, NSError* error){
        
        //already a string here
        presetName([data objectForKey:@"value"]);
        
    }];
}

- (void)system:(TASystem*)system preset:(NSString*)presetId writeName:(NSString*)name completion:(void (^)(id))complete
{
    TAPropertyType type = [self presetPropertyTypeByPresetId:presetId];
    
    [self write:type data:name system:system handler:^(id result, NSError* error){
        complete(result);
    }];
    
}

- (void)system:(TASystem*)system loadToCurrentFromPreset:(NSString*)presetId completion:(void (^)(id))complete
{
    [self write:TAPropertyTypePresetLoading data:presetId system:system handler:^(id result, NSError* error){
        complete(result);
    }];
}

- (void)system:(TASystem*)system saveCurrentToPreset:(NSString*)presetId completion:(void (^)(id))complete
{
    [self write:TAPropertyTypePresetSaving data:presetId system:system handler:^(id result, NSError* error){
        complete(result);
    }];
}

- (void)system:(id)system factoryReset:(void (^)(id))complete
{
    [self write:TAPropertyTypeFactoryReset data:nil system:system handler:^(id result, NSError* error){
        complete(result);
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"state"]) {
        
        TASystemServiceState state = [[change objectForKey:@"new"] integerValue];
        
        if(self.delegate)
        {
            [self.delegate didUpdateState:state];            
        }
    }
    
}

#pragma mark helper methods

- (void)observe:(NSString*)eventName handler:(void (^)(NSNotification*))note{
    
    [self.observers setObject:[[NSNotificationCenter defaultCenter] addObserverForName:eventName object:nil queue:nil usingBlock:note] forKey:eventName];
    
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

@end
