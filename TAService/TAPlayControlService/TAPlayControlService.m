//
//  TAPlayControlService.m
//  TAPlayControlService
//
//  Created by Lam Yick Hong on 23/4/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPlayControlService.h"

@interface TAService(Private)

@property (nonatomic, strong) id<TAProtocolAdaptor> protocolProxy;
@property (nonatomic, strong) NSMutableDictionary* observers;


- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block;
- (void)subscribe:(TAPropertyType)targetType system:(id)system;
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system;

@end

@implementation TAPlayControlService

- (void)system:(id)system volume:(void (^)(NSString*))volume
{
    [self read:TAPropertyTypeVolume system:system handler:^(NSDictionary* data, NSError* error){
        
        NSData* value = [data objectForKey:@"value"];
        
        if(value)
        {
            volume([self volumeDisplayFromSignal:value]);
            
        }else{
            
            volume(nil);
        }
        
    }];
}

- (void)system:(id)system writeVolume:(NSInteger)volume completion:(void (^)(id))complete
{
    switch ([self.protocolProxy dataFormat]) {
        case TADataFormatStandard:
        {
            //Nothing need to be done
        }
            break;
        case TADataFormatTPSignal:
        {
            
            //e.g. -5 should be sent as -50, which represent -5.0 in TP Signal convention
            volume *= 10;
        }
            break;
            
        default:
            break;
    }
    
    
    NSData* data = [NSData dataWithBytes:&volume length:sizeof(volume)];
    
    [self write:TAPropertyTypeVolume data:data system:system handler:^(id result, NSError* error){
        
        //TODO: notify write complete
        complete(result);
        
    }];
}

- (void)volumeUpSystem:(id)system completion:(void (^)(id))complete
{
    //TODO: define the optimal way
    [self write:TAPropertyTypeVolume data:[@"up" dataUsingEncoding:NSUTF8StringEncoding] system:system handler:^(id result, NSError* error){
        
        //TODO: notify write complete
        complete(result);
        
    }];
}

- (void)volumeDownSystem:(id)system completion:(void (^)(id))complete
{
    //TODO: define the optimal way
    [self write:TAPropertyTypeVolume data:[@"down" dataUsingEncoding:NSUTF8StringEncoding] system:system handler:^(id result, NSError* error){
        
        //TODO: notify write complete
        complete(result);
        
    }];
}

- (void)startMonitorVolumeOfSystem:(id)system
{
    //TODO: implementation
    [self subscribe:TAPropertyTypeVolume system:system];
}

- (void)stopMonitorVolumeOfSystem:(id)system
{
    //TODO: implementation
}

- (void)system:(id)system playStatus:(void (^)(TAPlayControlServicePlayStatus))status
{
    
    [self read:TAPropertyTypePlaybackStatus system:system handler:^(NSDictionary* data, NSError* error){
        
        NSData* value = [data objectForKey:@"value"];
        
        status([self playStatusFromData:value]);
    }];
    
}

- (void)system:(id)system audioSource:(void (^)(TAPlayControlServiceAudioSource))source
{
    [self read:TAPropertyTypePlaybackStatus system:system handler:^(NSDictionary* data, NSError* error){
        
        NSData* value = [data objectForKey:@"value"];
        
        source([self audioSourceFromData:value]);
    }];
}

- (void)system:(id)system anc:(void (^)(TAPlayControlServiceANCStatus))anc
{
    [self read:TAPropertyTypePlaybackStatus system:system handler:^(NSDictionary* data, NSError* error){
        
        NSData* value = [data objectForKey:@"value"];
        
        anc([self ancFromData:value]);
    }];
}


- (void)system:(id)system trueWireless:(void (^)(TAPlayControlServiceTrueWirelessStatus))status;
{
    [self read:TAPropertyTypeTrueWireless system:system handler:^(NSDictionary* data, NSError* error){
        
        NSData* value = [data objectForKey:@"value"];
        
        status([self trueWirelessStatusFromData:value]);
    }];
}

- (void)startMonitorPlayStatusOfSystem:(id)system
{
    //TODO: implementation
}

- (void)stopMonitorPlayStatusOfSystem:(id)system
{
    //TODO: implementation
}

- (void)system:(id)system play:(void (^)(TAPlayControlServicePlayStatus))complete
{
    int8_t value = 1;
    
    NSData* data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self write:TAPropertyTypePlaybackStatus data:data system:system handler:^(id result, NSError* error){
        
        //TODO: notify write complete
        complete(result);
        
    }];
}

- (void)system:(id)system pause:(void (^)(TAPlayControlServicePlayStatus))complete
{
    int8_t value = 0;
    
    NSData* data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self write:TAPropertyTypePlaybackStatus data:data system:system handler:^(id result, NSError* error){
        
        //TODO: notify write complete
        complete(result);
        
    }];
}

- (void)system:(id)system next:(void (^)(id))complete
{
    int8_t value = 3;
    
    NSData* data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self write:TAPropertyTypePlaybackStatus data:data system:system handler:^(id result, NSError* error){
        
        //TODO: notify write complete
        complete(result);
        
    }];
}

- (void)system:(id)system previous:(void (^)(id))complete
{
    int8_t value = 2;
    
    NSData* data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self write:TAPropertyTypePlaybackStatus data:data system:system handler:^(id result, NSError* error){
        
        //TODO: notify write complete
        complete(result);
        
    }];
}

- (void)system:(id)system turnANC:(TAPlayControlServiceANCStatus)anc completion:(void (^)(id))complete
{
    int8_t value;
    
    if(anc == TAPlayControlServiceANCStatusOn)
    {
        value = 5;
        
    }else{        
        value = 4;
    }
    
    NSData* data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self write:TAPropertyTypePlaybackStatus data:data system:system handler:^(id result, NSError* error){
        
        //TODO: notify write complete
        complete(result);
        
    }];
}

- (void)system:(id)system configTrueWireless:(TAPlayControlServiceTrueWirelessCommand)command completion:(void (^)(id))complete;
{
    int8_t value = command;
    
    NSData* data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self write:TAPropertyTypeTrueWireless data:data system:system handler:^(id result, NSError* error){
        
        complete(result);
    }];
}

- (void)startMonitorTrueWirelessConfigOfSystem:(id)system
{
    //TODO: implementation
}

- (void)stopMonitorTrueWirelessConfigOfSystem:(id)system
{
    //TODO: implementation
}

- (void)system:(id)system currentTrackInfo:(void (^)(NSDictionary*))complete
{
    //TODO: implementation
}

- (void)startMonitorCurrentTrackInfoOfSystem:(id)system
{
    //TODO: implementation
}

- (void)stopMonitorCurrentTrackInfoOfSystem:(id)system
{
    //TODO: implementation
}

- (void)system:(id)system didReceiveUpdateValue:(NSDictionary*)data type:(TAPropertyType)targetType
{
    id value = [data objectForKey:@"value"];
    
    if(targetType == TAPropertyTypeVolume)
    {
        
        [self.delegate system:system didUpdateVolume:[self volumeDisplayFromSignal:value]];
    }
}

#pragma mark - helper methods

- (NSString*)volumeDisplayFromSignal:(NSData*)data
{
    NSString* display;

    switch ([self.protocolProxy dataFormat]) {
        
        case TADataFormatStandard:
        {
            int8_t i;
            [data getBytes:&i length:sizeof(i)];
            
            display = [NSString stringWithFormat:@"%.f", (float)i];
        }
            break;
        case TADataFormatTPSignal:
        {
            int16_t i;
            [data getBytes:&i length:sizeof(i)];
            
            display = [NSString stringWithFormat:@"%.f", (float)i / 10.0];
        }
            break;
            
        default:
            break;
    }
    
    return display;
}

- (TAPlayControlServiceAudioSource)audioSourceFromData:(NSData*)data
{
    if([data length] < 1){
        
        return TAPlayControlServiceAudioSourceUnknown;
    }
    
    NSData* subData = [data subdataWithRange:NSMakeRange(0, 1)];
    
    char buff;
    [subData getBytes:&buff length:sizeof(buff)];
    int i = buff;
    
    return i;
}

- (TAPlayControlServicePlayStatus)playStatusFromData:(NSData*)data
{
    if([data length] < 2){
        
        return TAPlayControlServicePlayStatusUnknown;
    }
    
    NSData* subData = [data subdataWithRange:NSMakeRange(1, 1)];
    
    char buff;
    [subData getBytes:&buff length:sizeof(buff)];
    int i = buff;
    
    return i;
}

- (TAPlayControlServiceANCStatus)ancFromData:(NSData*)data
{
    if([data length] < 3){
        
        return TAPlayControlServiceANCStatusUnknown;
    }
    
    NSData* subData = [data subdataWithRange:NSMakeRange(2, 1)];
    
    char buff;
    [subData getBytes:&buff length:sizeof(buff)];
    int i = buff;
    
    return i;
}

- (TAPlayControlServiceTrueWirelessStatus)trueWirelessStatusFromData:(NSData*)data
{
    char buff;
    [data getBytes:&buff length:sizeof(buff)];
    int i = buff;
    
    return i;
}

@end
