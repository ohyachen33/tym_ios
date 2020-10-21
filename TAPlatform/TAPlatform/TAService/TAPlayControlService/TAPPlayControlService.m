//
//  TAPPlayControlService.m
//  TAPPlayControlService
//
//  Created by Lam Yick Hong on 23/4/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPPlayControlService.h"

@interface TAPService(Private)

@property (nonatomic, strong) id<TAPProtocolAdaptor> protocolProxy;
@property (nonatomic, strong) NSMutableDictionary* observers;


- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block;
- (void)subscribe:(TAPropertyType)targetType system:(id)system;
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system;
- (NSError*)unsupportedErrorWithInfo:(NSDictionary*)info;

@end

@implementation TAPPlayControlService

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
    NSData* data;
    
    switch ([self.protocolProxy dataFormat]) {
        case TAPDataFormatStandard:
        {
            int8_t value = volume;
            data = [NSData dataWithBytes:&volume length:sizeof(value)];

        }
            break;
        case TAPDataFormatTPSignal:
        {
            
            //e.g. -5 should be sent as -50, which represent -5.0 in TP Signal convention
            volume *= 10;
            data = [NSData dataWithBytes:&volume length:sizeof(volume)];
        }
            break;
            
        default:
            break;
    }
    [self write:TAPropertyTypeVolume data:data system:system handler:^(id result, NSError* error){
        
        //TODO: expand this to receive a dictionary
        complete(error);
        
    }];
}

- (void)volumeUpSystem:(id)system completion:(void (^)(id))complete
{
    //TODO: define the optimal way
    [self write:TAPropertyTypeVolume data:[@"up" dataUsingEncoding:NSUTF8StringEncoding] system:system handler:^(id result, NSError* error){
        
        //TODO: expand this to receive a dictionary
        complete(error);
        
    }];
}

- (void)volumeDownSystem:(id)system completion:(void (^)(id))complete
{
    //TODO: define the optimal way
    [self write:TAPropertyTypeVolume data:[@"down" dataUsingEncoding:NSUTF8StringEncoding] system:system handler:^(id result, NSError* error){
        
        //TODO: expand this to receive a dictionary
        complete(error);
        
    }];
}

- (void)startMonitorVolumeOfSystem:(id)system
{
    [self subscribe:TAPropertyTypeVolume system:system];
}

- (void)stopMonitorVolumeOfSystem:(id)system
{
    [self unsubscribe:TAPropertyTypeVolume system:system];
}

- (void)system:(id)system playStatus:(void (^)(TAPPlayControlServicePlayStatus))status
{
    
    [self read:TAPropertyTypePlaybackStatus system:system handler:^(NSDictionary* data, NSError* error){
        
        NSData* value = [data objectForKey:@"value"];
        
        status([self playStatusFromData:value]);
    }];
    
}

- (void)system:(id)system audioSource:(void (^)(TAPPlayControlServiceAudioSource))source
{
    [self read:TAPropertyTypePlaybackStatus system:system handler:^(NSDictionary* data, NSError* error){
        
        NSData* value = [data objectForKey:@"value"];
        
        source([self audioSourceFromData:value]);
    }];
}

- (void)system:(id)system anc:(void (^)(TAPPlayControlServiceANCStatus))anc
{
    [self read:TAPropertyTypePlaybackStatus system:system handler:^(NSDictionary* data, NSError* error){
        
        NSData* value = [data objectForKey:@"value"];
        
        anc([self ancFromData:value]);
    }];
}


- (void)system:(id)system trueWireless:(void (^)(TAPPlayControlServiceTrueWirelessStatus))status;
{
    [self read:TAPropertyTypeTrueWireless system:system handler:^(NSDictionary* data, NSError* error){
        
        NSData* value = [data objectForKey:@"value"];
        
        status([self trueWirelessStatusFromData:value]);
    }];
}

- (void)startMonitorPlayStatusOfSystem:(id)system
{
    [self subscribe:TAPropertyTypePlaybackStatus system:system];
}

- (void)stopMonitorPlayStatusOfSystem:(id)system
{
    [self unsubscribe:TAPropertyTypePlaybackStatus system:system];
}

- (void)system:(id)system play:(void (^)(TAPPlayControlServicePlayStatus))complete
{
    int8_t value = 1;
    
    NSData* data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self write:TAPropertyTypePlaybackStatus data:data system:system handler:^(id result, NSError* error){
        
        //TODO: notify write complete
        complete(result);
        
    }];
}

- (void)system:(id)system pause:(void (^)(TAPPlayControlServicePlayStatus))complete
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

- (void)system:(id)system tonescape:(void (^)(id))complete;
{
    [self read:TAPropertyTypeTonescape system:system handler:^(NSDictionary* data, NSError* error){
        
        NSData* value = [data objectForKey:@"value"];
        
        if(value)
        {
            complete(value);
            
        }else{
            
            complete(nil);
        }
        
    }];

}

- (void)system:(id)system datapacket:(NSData*)data tonescape:(void (^)(id))complete
{
    [self write:TAPropertyTypeTonescape data:data system:system handler:^(id result, NSError* error){
        
        //TODO: notify write complete
        complete(result);
        
    }];
}


- (void)system:(id)system turnANC:(TAPPlayControlServiceANCStatus)anc completion:(void (^)(id))complete
{
    int8_t value;
    
    if(anc == TAPPlayControlServiceANCStatusOn)
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

- (void)system:(id)system configTrueWireless:(TAPPlayControlServiceTrueWirelessCommand)command completion:(void (^)(id))complete;
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
    DDLogDebug(@"type: %ld dictionary: %@", (long)targetType, [data description]);
    
    id value = [data objectForKey:@"value"];
    
    switch (targetType) {
        case TAPropertyTypeVolume:
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdateVolume:)])
            {
                [self.delegate system:system didUpdateVolume:[self volumeDisplayFromSignal:value]];
            }
            
        }
            break;
            
        case TAPropertyTypePlaybackStatus:
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdatePlayStatus:)])
            {
                [self.delegate system:system didUpdatePlayStatus:[self playStatusFromData:value]];
            }
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdateAudioSource:)])
            {
                [self.delegate system:system didUpdateAudioSource:[self audioSourceFromData:value]];
            }            
        }
            
        default:
            break;
    }
}

#pragma mark - helper methods

- (NSString*)volumeDisplayFromSignal:(NSData*)data
{
    NSString* display;

    switch ([self.protocolProxy dataFormat]) {
        
        case TAPDataFormatStandard:
        {
            int8_t i;
            [data getBytes:&i length:sizeof(i)];
            
            display = [NSString stringWithFormat:@"%.f", (float)i];
        }
            break;
        case TAPDataFormatTPSignal:
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

- (TAPPlayControlServiceAudioSource)audioSourceFromData:(NSData*)data
{
    if([data length] < 1){
        
        return TAPPlayControlServiceAudioSourceUnknown;
    }
    
    NSData* subData = [data subdataWithRange:NSMakeRange(0, 1)];
    
    char buff;
    [subData getBytes:&buff length:sizeof(buff)];
    int i = buff;
    
    return i;
}

- (TAPPlayControlServicePlayStatus)playStatusFromData:(NSData*)data
{
    if([data length] < 2){
        
        return TAPPlayControlServicePlayStatusUnknown;
    }
    
    NSData* subData = [data subdataWithRange:NSMakeRange(1, 1)];
    
    char buff;
    [subData getBytes:&buff length:sizeof(buff)];
    int i = buff;
    
    return i;
}

- (TAPPlayControlServiceANCStatus)ancFromData:(NSData*)data
{
    if([data length] < 3){
        
        return TAPPlayControlServiceANCStatusUnknown;
    }
    
    NSData* subData = [data subdataWithRange:NSMakeRange(2, 1)];
    
    char buff;
    [subData getBytes:&buff length:sizeof(buff)];
    int i = buff;
    
    return i;
}

- (TAPPlayControlServiceTrueWirelessStatus)trueWirelessStatusFromData:(NSData*)data
{
    char buff;
    [data getBytes:&buff length:sizeof(buff)];
    int i = buff;
    
    return i;
}

@end
