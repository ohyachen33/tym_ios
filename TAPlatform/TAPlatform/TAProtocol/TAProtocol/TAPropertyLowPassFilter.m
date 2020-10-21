//
//  TAPropertyLowPassFilter.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertyLowPassFilter.h"
#import "TASignalType.h"

@interface TAPropertyLowPassFilter()

@property (readwrite) TAPropertyLowPassFilterSubType subType;

@end

@implementation TAPropertyLowPassFilter

- (id)initWithSubType:(TAPropertyLowPassFilterSubType)subType
{
    if(self = [super init])
    {
        self.subType = subType;
    }
    
    return self;
}

- (NSData*)dataBySignal:(TPSignal*)signal writeData:(NSData*)data
{
    TPSignalType type = TPSignalTypeTotalNumber;
    
    switch (self.subType) {
        case TAPropertyLowPassFilterSubTypeOnOff:
        {
            type = TPSignalTypeLPOnOffSetting;
        }
            break;
        case TAPropertyLowPassFilterSubTypeFrequency:
        {
            type = TPSignalTypeLowPassFrequencySetting;
        }
            break;
        case TAPropertyLowPassFilterSubTypeSlope:
        {
            type = TPSignalTypeLowPassSlopeSetting;
        }
            break;
            
        default:
            break;
    }
    
    return [signal settingWriteSignalWithData:data type:type];
}

- (TPSignalType)signalType
{
    TPSignalType signalType = TPSignalTypeTotalNumber;
    
    switch (self.subType) {
        case TAPropertyLowPassFilterSubTypeOnOff:
        {
            signalType = TPSignalTypeLPOnOffSetting;
        }
            break;
        case TAPropertyLowPassFilterSubTypeFrequency:
        {
            signalType = TPSignalTypeLowPassFrequencySetting;
        }
            break;
        case TAPropertyLowPassFilterSubTypeSlope:
        {
            signalType = TPSignalTypeLowPassSlopeSetting;
        }
            break;
            
        default:
            break;
    };
    
    return signalType;
}

@end
