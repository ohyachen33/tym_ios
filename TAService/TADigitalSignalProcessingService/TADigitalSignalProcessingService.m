//
//  TADigitalSignalProcessingService.m
//  TADigitalSignalProcessingService
//
//  Created by Lam Yick Hong on 20/4/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TADigitalSignalProcessingService.h"

NSString * const TADigitalSignalProcessingKeyLowPassFrequency   =   @"LowPassFrequency";
NSString * const TADigitalSignalProcessingKeyLowPassSlope       =   @"LowPassSlope";
NSString * const TADigitalSignalProcessingKeyPhase              =   @"Phase";
NSString * const TADigitalSignalProcessingKeyEQ1Frequency       =   @"EQ1Frequency";
NSString * const TADigitalSignalProcessingKeyEQ1Boost           =   @"EQ1Boost";
NSString * const TADigitalSignalProcessingKeyEQ1QFactor         =   @"EQ1QFactor";
NSString * const TADigitalSignalProcessingKeyEQ2Frequency       =   @"EQ2Frequency";
NSString * const TADigitalSignalProcessingKeyEQ2Boost           =   @"EQ2Boost";
NSString * const TADigitalSignalProcessingKeyEQ2QFactor         =   @"EQ2QFactor";
NSString * const TADigitalSignalProcessingKeyEQ3Frequency       =   @"EQ3Frequency";
NSString * const TADigitalSignalProcessingKeyEQ3Boost           =   @"EQ3Boost";
NSString * const TADigitalSignalProcessingKeyEQ3QFactor         =   @"EQ3QFactor";
NSString * const TADigitalSignalProcessingKeyRGCFrequency       =   @"RGCFrequency";
NSString * const TADigitalSignalProcessingKeyRGCSlope           =   @"RGCSlope";
NSString * const TADigitalSignalProcessingKeyLowPassOnOff       =   @"LowPassOnOff";
NSString * const TADigitalSignalProcessingKeyPEQ1OnOff          =   @"PEQ1OnOff";
NSString * const TADigitalSignalProcessingKeyPEQ2OnOff          =   @"PEQ2OnOff";
NSString * const TADigitalSignalProcessingKeyPEQ3OnOff          =   @"PEQ3OnOff";
NSString * const TADigitalSignalProcessingKeyRGCOnOff           =   @"RGCOnOff";
NSString * const TADigitalSignalProcessingKeyVolume             =   @"Volume";
NSString * const TADigitalSignalProcessingKeyDisplay            =   @"Display";
NSString * const TADigitalSignalProcessingKeyTimeout            =   @"Timeout";
NSString * const TADigitalSignalProcessingKeyStandby            =   @"Standby";
NSString * const TADigitalSignalProcessingKeyPolarity           =   @"Polarity";
NSString * const TADigitalSignalProcessingKeyTunning            =   @"Tunning";

@interface TAService(Private)

@property (nonatomic, strong) id<TAProtocolAdaptor> protocolProxy;
@property (nonatomic, strong) NSMutableDictionary* observers;


- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block;
- (void)subscribe:(TAPropertyType)targetType system:(id)system;
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system;

@end

@implementation TADigitalSignalProcessingService

- (void)system:(id)system equalizer:(void (^)(NSDictionary*, NSError*))equalizer
{
    NSString* observerKey = [NSString stringWithFormat:@"%@ - %@", @"read", @"eq-all"];
    
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
                NSArray* keys = @[TADigitalSignalProcessingKeyDisplay,
                                  TADigitalSignalProcessingKeyTimeout,
                                  TADigitalSignalProcessingKeyStandby,
                                  
                                  TADigitalSignalProcessingKeyLowPassOnOff,
                                  TADigitalSignalProcessingKeyLowPassFrequency,
                                  TADigitalSignalProcessingKeyLowPassSlope,
                                  
                                  TADigitalSignalProcessingKeyPEQ1OnOff,
                                  TADigitalSignalProcessingKeyEQ1Frequency,
                                  TADigitalSignalProcessingKeyEQ1Boost,
                                  TADigitalSignalProcessingKeyEQ1QFactor,
                                  
                                  TADigitalSignalProcessingKeyPEQ2OnOff,
                                  TADigitalSignalProcessingKeyEQ2Frequency,
                                  TADigitalSignalProcessingKeyEQ2Boost,
                                  TADigitalSignalProcessingKeyEQ2QFactor,
                                  
                                  TADigitalSignalProcessingKeyPEQ3OnOff,
                                  TADigitalSignalProcessingKeyEQ3Frequency,
                                  TADigitalSignalProcessingKeyEQ3Boost,
                                  TADigitalSignalProcessingKeyEQ3QFactor,
                                  
                                  TADigitalSignalProcessingKeyRGCOnOff,
                                  TADigitalSignalProcessingKeyRGCFrequency,
                                  TADigitalSignalProcessingKeyRGCSlope,
                                  
                                  TADigitalSignalProcessingKeyVolume,
                                  TADigitalSignalProcessingKeyPhase,
                                  TADigitalSignalProcessingKeyPolarity,
                                  TADigitalSignalProcessingKeyTunning];
                
                NSMutableDictionary* eqInfo = [[NSMutableDictionary alloc] init];
                
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
                    
                    [eqInfo setObject:number forKey:[keys objectAtIndex:i]];
                }
                
                //Return the value
                equalizer(eqInfo, error);
                
                if(targetObserver)
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:targetObserver];
                    [self.observers removeObjectForKey:observerKey];
                }
                
            }
            
        }
        
    }];
    
    [self.observers setObject:observer forKey:observerKey];
    
    
    [self.protocolProxy perform:@{@"operation" : @"read", @"property" : @"eq-all", @"system" : system}];
}

- (void)system:(id)system targetKeys:(NSArray*)targetKeys equalizer:(void (^)(NSDictionary*, NSError*))equalizer
{
    //get full settings and filter. the reason is, we can't guarantee the user always provide a continous row in the setting table and we want to avoid multiple call to the system, as least in TP Signal case we should do it this way
    [self system:system equalizer:^(NSDictionary* fullSettings, NSError* error){
        
        NSMutableDictionary* targetSettings = [[NSMutableDictionary alloc] init];
        
        for(NSString* key in targetKeys)
        {
            NSNumber* number = [fullSettings objectForKey:key];
            if(number)
            {
                [targetSettings setObject:number forKey:key];
            }
        }
        
        equalizer(targetSettings, error);
    }];
}

- (void)system:(id)system writeEqualizer:(NSDictionary*)equalizer completion:(void (^)(id))complete
{
    //This is okay in BLE. In BLE, this is only good because we know the BLE protocol will handle the task as a queue and finishing then one by one. If other third party libraries don't handle it this way, this part of code mayb need to be re-writtenm introducing the queue concept here.
    [self system:system writeEqualizer:equalizer type:TADigitalSignalProcessingKeyLowPassOnOff property:TAPropertyTypeLowPassOnOff completion:complete];
    [self system:system writeEqualizer:equalizer type:TADigitalSignalProcessingKeyLowPassFrequency property:TAPropertyTypeLowPassFrequency completion:complete];
    [self system:system writeEqualizer:equalizer type:TADigitalSignalProcessingKeyPhase property:TAPropertyTypePhase completion:complete];
    [self system:system writeEqualizer:equalizer type:TADigitalSignalProcessingKeyPolarity property:TAPropertyTypePolarity completion:complete];
    
}

- (void)startMonitorEqualizerOfSystem:(id)system
{
    //TODO: implementation
}

- (void)stopMonitorEqualizerOfSystem:(id)system
{
    //TODO: implementation
}

- (void)system:(TASystem*)system writeEqualizer:(NSDictionary*)equalizer type:(NSString*)type property:(TAPropertyType)property completion:(void (^)(id))complete
{
    NSNumber* value = [equalizer objectForKey:type];
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

- (void)system:(TASystem*)system writeEqualizerType:(NSString*)type value:(id)value completion:(void (^)(id))complete
{

    TAPropertyType property = TAPropertyTypeUnknown;
    
    if([type isEqualToString:TADigitalSignalProcessingKeyLowPassOnOff])
    {
        property = TAPropertyTypeLowPassOnOff;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyLowPassFrequency])
    {
        property = TAPropertyTypeLowPassFrequency;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyLowPassSlope])
    {
        property = TAPropertyTypeLowPassSlope;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyPhase])
    {
        property = TAPropertyTypePhase;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyPolarity])
    {
        property = TAPropertyTypePolarity;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyRGCOnOff])
    {
        property = TAPropertyTypeRGCOnOff;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyRGCFrequency])
    {
        property = TAPropertyTypeRGCFrequency;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyRGCSlope])
    {
        property = TAPropertyTypeRGCSlope;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyEQ1Boost])
    {
        property = TAPropertyTypeEQ1Boost;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyEQ1Frequency])
    {
        property = TAPropertyTypeEQ1Frequency;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyEQ1QFactor])
    {
        property = TAPropertyTypeEQ1QFactor;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyEQ2Boost])
    {
        property = TAPropertyTypeEQ2Boost;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyEQ2Frequency])
    {
        property = TAPropertyTypeEQ2Frequency;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyEQ2QFactor])
    {
        property = TAPropertyTypeEQ2QFactor;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyEQ3Boost])
    {
        property = TAPropertyTypeEQ3Boost;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyEQ3Frequency])
    {
        property = TAPropertyTypeEQ3Frequency;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyEQ3QFactor])
    {
        property = TAPropertyTypeEQ3QFactor;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyPEQ1OnOff])
    {
        property = TAPropertyTypePEQ1OnOff;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyPEQ2OnOff])
    {
        property = TAPropertyTypePEQ2OnOff;
        
    }else if([type isEqualToString:TADigitalSignalProcessingKeyPEQ3OnOff])
    {
        property = TAPropertyTypePEQ3OnOff;
        
    }
    
    if(value)
    {
        NSInteger i = [value floatValue] * 10;
        
        NSData* data = [NSData dataWithBytes:&i length:sizeof(i)];
        
        [self write:property data:data system:system handler:^(id result, NSError* error){
            complete(result);
        }];
    }
}

@end
