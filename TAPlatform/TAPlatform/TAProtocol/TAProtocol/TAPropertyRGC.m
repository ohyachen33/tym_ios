//
//  TAPropertyRGC.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertyRGC.h"
#import "TASignalType.h"

@interface TAPropertyRGC()

@property (readwrite) TAPropertyRGCSubType subType;

@end

@implementation TAPropertyRGC

- (id)initWithSubType:(TAPropertyRGCSubType)subType
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
        case TAPropertyRGCSubTypeOnOff:
        {
            type = TPSignalTypeRGCOnOffSetting;
        }
            break;
        case TAPropertyRGCSubTypeFrequency:
        {
            type = TPSignalTypeRGCFrequencySetting;
        }
            break;
        case TAPropertyRGCSubTypeSlope:
        {
            type = TPSignalTypeRGCSlopeSetting;
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
        case TAPropertyRGCSubTypeOnOff:
        {
            signalType = TPSignalTypeRGCOnOffSetting;
        }
            break;
        case TAPropertyRGCSubTypeFrequency:
        {
            signalType = TPSignalTypeRGCFrequencySetting;
        }
            break;
        case TAPropertyRGCSubTypeSlope:
        {
            signalType = TPSignalTypeRGCSlopeSetting;
        }
            break;
            
        default:
            break;
    };
    
    return signalType;
}


@end
