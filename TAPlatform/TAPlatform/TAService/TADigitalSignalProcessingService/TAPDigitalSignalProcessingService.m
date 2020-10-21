//
//  TAPDigitalSignalProcessingService.m
//  TAPDigitalSignalProcessingService
//
//  Created by Lam Yick Hong on 20/4/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPDigitalSignalProcessingService.h"

NSString * const TAPDigitalSignalProcessingKeyLowPassFrequency   =   @"LowPassFrequency";
NSString * const TAPDigitalSignalProcessingKeyLowPassSlope       =   @"LowPassSlope";
NSString * const TAPDigitalSignalProcessingKeyPhase              =   @"Phase";
NSString * const TAPDigitalSignalProcessingKeyEQ1Frequency       =   @"EQ1Frequency";
NSString * const TAPDigitalSignalProcessingKeyEQ1Boost           =   @"EQ1Boost";
NSString * const TAPDigitalSignalProcessingKeyEQ1QFactor         =   @"EQ1QFactor";
NSString * const TAPDigitalSignalProcessingKeyEQ2Frequency       =   @"EQ2Frequency";
NSString * const TAPDigitalSignalProcessingKeyEQ2Boost           =   @"EQ2Boost";
NSString * const TAPDigitalSignalProcessingKeyEQ2QFactor         =   @"EQ2QFactor";
NSString * const TAPDigitalSignalProcessingKeyEQ3Frequency       =   @"EQ3Frequency";
NSString * const TAPDigitalSignalProcessingKeyEQ3Boost           =   @"EQ3Boost";
NSString * const TAPDigitalSignalProcessingKeyEQ3QFactor         =   @"EQ3QFactor";
NSString * const TAPDigitalSignalProcessingKeyRGCFrequency       =   @"RGCFrequency";
NSString * const TAPDigitalSignalProcessingKeyRGCSlope           =   @"RGCSlope";
NSString * const TAPDigitalSignalProcessingKeyLowPassOnOff       =   @"LowPassOnOff";
NSString * const TAPDigitalSignalProcessingKeyPEQ1OnOff          =   @"PEQ1OnOff";
NSString * const TAPDigitalSignalProcessingKeyPEQ2OnOff          =   @"PEQ2OnOff";
NSString * const TAPDigitalSignalProcessingKeyPEQ3OnOff          =   @"PEQ3OnOff";
NSString * const TAPDigitalSignalProcessingKeyRGCOnOff           =   @"RGCOnOff";
NSString * const TAPDigitalSignalProcessingKeyVolume             =   @"Volume";
NSString * const TAPDigitalSignalProcessingKeyDisplay            =   @"Display";
NSString * const TAPDigitalSignalProcessingKeyTimeout            =   @"Timeout";
NSString * const TAPDigitalSignalProcessingKeyStandby            =   @"Standby";
NSString * const TAPDigitalSignalProcessingKeyBrightness         =   @"Brightness";
NSString * const TAPDigitalSignalProcessingKeyPolarity           =   @"Polarity";
NSString * const TAPDigitalSignalProcessingKeyTunning            =   @"Tunning";
NSString * const TAPDigitalSignalProcessingKeyFactoryReset       =   @"FactoryReset";

@interface TAPService(Private)

@property (nonatomic, strong) id<TAPProtocolAdaptor> protocolProxy;
@property (nonatomic, strong) NSMutableDictionary* observers;


- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block;
- (void)reset:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)subscribe:(TAPropertyType)targetType system:(id)system;
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system;
- (NSError*)unsupportedErrorWithInfo:(NSDictionary*)info;
- (void)registerReadObserver:(id)observer forKey:(id)observerKey;


@end

@implementation TAPDigitalSignalProcessingService

- (void)system:(id)system equalizer:(void (^)(NSDictionary*, NSError*))equalizer
{
    NSString* observerKey = [NSString stringWithFormat:@"%@ - %@", @"read", @"eq-all"];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAPProtocolEventDidUpdateValue object:nil queue:nil usingBlock:^(NSNotification* note){
        
        NSDictionary* value = [[note userInfo] objectForKey:TAPProtocolKeyValue];
        NSArray* values = [value objectForKey:@"value"];
        TAPropertyType type = [[[note userInfo] objectForKey:TAPProtocolPropertyType] integerValue];
        NSError* error = [[note userInfo] objectForKey:TAPProtocolKeyError];
        
        id targetObserver = [self.observers objectForKey:observerKey];
        
        //only return result if we have a observer, it means it's the first result
        if(targetObserver && type == 0 /*TAPropertyTypeDisplay*/){
            
            //Because we are loading the whole settings, it should always be the first one in the table. If the table is revised, we should always come back to this. Not safe, may need to think of a new mechanism
            NSDictionary* eqInfo = [self equalizerInfoFromValues:values type:type];
            
            //Return the value
            equalizer(eqInfo, error);
            
            if(targetObserver)
            {
                [[NSNotificationCenter defaultCenter] removeObserver:targetObserver name:TAPProtocolEventDidUpdateValue object:nil];
                [self.observers removeObjectForKey:observerKey];
            }
            
        }
        
    }];
    
    [self registerReadObserver:observerKey forKey:observerKey];
    
    
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
    [self system:system writeEqualizer:equalizer type:TAPDigitalSignalProcessingKeyLowPassOnOff property:TAPropertyTypeLowPassOnOff completion:complete];
    [self system:system writeEqualizer:equalizer type:TAPDigitalSignalProcessingKeyLowPassFrequency property:TAPropertyTypeLowPassFrequency completion:complete];
    [self system:system writeEqualizer:equalizer type:TAPDigitalSignalProcessingKeyPhase property:TAPropertyTypePhase completion:complete];
    [self system:system writeEqualizer:equalizer type:TAPDigitalSignalProcessingKeyPolarity property:TAPropertyTypePolarity completion:complete];
    
}

- (void)startMonitorEqualizerOfSystem:(id)system
{
    [self subscribe:TAPropertyTypeEqualizer system:system];
}

- (void)stopMonitorEqualizerOfSystem:(id)system
{
    [self unsubscribe:TAPropertyTypeEqualizer system:system];
}

- (void)system:(TAPSystem*)system resetEqualizerType:(NSString*)type completion:(void (^)(id))complete
{
    TAPropertyType property = [self propertyFromType:type];
    
    [self reset:property system:system handler:^(NSDictionary* fullSettings, NSError* error){
        
        complete(fullSettings);
    }];
}

- (void)system:(TAPSystem*)system writeEqualizer:(NSDictionary*)equalizer type:(NSString*)type property:(TAPropertyType)property completion:(void (^)(id))complete
{
    NSNumber* value = [equalizer objectForKey:type];
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

- (void)system:(TAPSystem*)system writeEqualizerType:(NSString*)type value:(id)value completion:(void (^)(id))complete
{

    TAPropertyType property = [self propertyFromType:type];
    
    if(value)
    {
        NSInteger i = [value floatValue] * 10;
        
        NSData* data = [NSData dataWithBytes:&i length:sizeof(i)];
        
        [self write:property data:data system:system handler:^(id result, NSError* error){
            //TODO: expand this to receive a dictionary
            complete(error);
        }];
    }
}

- (void)system:(id)system didReceiveUpdateValue:(NSDictionary*)data type:(TAPropertyType)targetType
{    
    id values = [data objectForKey:@"value"];
    
    DDLogDebug(@"type: %ld dictionary: %@", (long)targetType, [data description]);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdateEqualizer:)])
    {
        NSDictionary* eqInfo;
        eqInfo = [self equalizerInfoFromValues:values type:targetType];
        [self.delegate system:system didUpdateEqualizer:eqInfo];

    }
}

#pragma mark - Helper functions

- (TAPropertyType)propertyFromType:(NSString*)type
{
    TAPropertyType property = TAPropertyTypeUnknown;
    
    if([type isEqualToString:TAPDigitalSignalProcessingKeyLowPassOnOff])
    {
        property = TAPropertyTypeLowPassOnOff;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyLowPassFrequency])
    {
        property = TAPropertyTypeLowPassFrequency;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyLowPassSlope])
    {
        property = TAPropertyTypeLowPassSlope;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyPhase])
    {
        property = TAPropertyTypePhase;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyPolarity])
    {
        property = TAPropertyTypePolarity;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyRGCOnOff])
    {
        property = TAPropertyTypeRGCOnOff;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyRGCFrequency])
    {
        property = TAPropertyTypeRGCFrequency;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyRGCSlope])
    {
        property = TAPropertyTypeRGCSlope;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyTunning])
    {
        property = TAPropertyTypeTuning;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ1Boost])
    {
        property = TAPropertyTypeEQ1Boost;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ1Frequency])
    {
        property = TAPropertyTypeEQ1Frequency;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ1QFactor])
    {
        property = TAPropertyTypeEQ1QFactor;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ2Boost])
    {
        property = TAPropertyTypeEQ2Boost;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ2Frequency])
    {
        property = TAPropertyTypeEQ2Frequency;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ2QFactor])
    {
        property = TAPropertyTypeEQ2QFactor;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ3Boost])
    {
        property = TAPropertyTypeEQ3Boost;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ3Frequency])
    {
        property = TAPropertyTypeEQ3Frequency;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyEQ3QFactor])
    {
        property = TAPropertyTypeEQ3QFactor;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyPEQ1OnOff])
    {
        property = TAPropertyTypePEQ1OnOff;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyPEQ2OnOff])
    {
        property = TAPropertyTypePEQ2OnOff;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyPEQ3OnOff])
    {
        property = TAPropertyTypePEQ3OnOff;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyVolume])
    {
        property = TAPropertyTypeVolume;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyStandby])
    {
        property = TAPropertyTypeStandby;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyBrightness])
    {
        property = TAPropertyTypeBrightness;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyTimeout])
    {
        property = TAPropertyTypeTimeout;
        
    }else if([type isEqualToString:TAPDigitalSignalProcessingKeyDisplay])
    {
        property = TAPropertyTypeDisplay;
        
    }
    
    
    return property;
}

- (NSDictionary*)equalizerInfoFromValues:(NSArray*)values type:(TAPropertyType)type
{
    NSMutableDictionary* eqInfo = [[NSMutableDictionary alloc] init];
    
    NSArray* keys = @[TAPDigitalSignalProcessingKeyDisplay,
                      TAPDigitalSignalProcessingKeyTimeout,
                      TAPDigitalSignalProcessingKeyStandby,
                      TAPDigitalSignalProcessingKeyBrightness,
                      
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
    
    
        if([values isKindOfClass:[NSArray class]])
        {
            
            if(type + [values count] <= [keys count])
            {
                
                DDLogVerbose(@"%@", [values description]);
                
                for(int i = 0; i < [values count]; i++){
                    
                    NSData* data = [values objectAtIndex:i];
                    
                    int16_t buff;
                    [data getBytes:&buff length:sizeof(buff)];
                    
                    NSString* key = [keys objectAtIndex:i + type];
                    
                    DDLogVerbose(@"%@", @"-------------------");
                    DDLogVerbose(@"%@", key);
                    
                    DDLogVerbose(@"%d", buff);
                    
                    NSNumber* number = [NSNumber numberWithFloat:((float)buff / 10.0)];
                    
                    DDLogVerbose(@"%f", [number floatValue]);
                    
                    [eqInfo setObject:number forKey:key];
                }
                
                //Return the value
                return eqInfo;
                
            }else{
                
                DDLogVerbose(@"Out of bound. It must be some issues on the type table or data from the system");
            }
            
        }else if([values isKindOfClass:[NSData class]]){
            NSData* data = (NSData*)values;
            
            int16_t buff;
            [data getBytes:&buff length:sizeof(buff)];
            
            NSNumber* number = [NSNumber numberWithFloat:((float)buff / 10.0)];
            
            [eqInfo setObject:number forKey:[keys objectAtIndex:type]];
        }else if (type == TAPropertyTypeFactoryReset){
            [eqInfo setObject:@"0" forKey:TAPDigitalSignalProcessingKeyFactoryReset];
        }
    
    return eqInfo;
}

@end
