//
//  TAPropertyScreenDisplay.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertyScreenDisplay.h"
#import "TASignalType.h"
#import "TPSignalConfig.h"

@interface TAPropertyScreenDisplay()

@property (readwrite) TAPropertyScreenDisplaySubType subType;

@end

@implementation TAPropertyScreenDisplay

- (id)initWithSubType:(TAPropertyScreenDisplaySubType)subType
{
    if(self = [super init])
    {
        self.subType = subType;
    }
    
    return self;
}

- (NSData*)dataBySignal:(TPSignal*)signal writeData:(NSData*)data
{    
    NSData* result = nil;
    
    switch (self.subType) {
        case TAPropertyScreenDisplaySubTypeBrightness:
        {
            result = [signal settingWriteSignalWithData:data type:TPSignalTypeBrightnessSetting];
        }
            break;
        case TAPropertyScreenDisplaySubTypeToggleOnOff:
        {
            result = [signal keySignalWithKeyIdData:[TPSignalConfig dataForToggleScreen] type:TPSignalTypeKey];
        }
            break;
            
        default:
            break;
    }
    
    return result;
}

- (TPSignalType)signalType
{
    TPSignalType signalType = TPSignalTypeTotalNumber;
    
    switch (self.subType) {
        case TAPropertyScreenDisplaySubTypeBrightness:
        {
            signalType = TPSignalTypeBrightnessSetting;
        }
            break;
        case TAPropertyScreenDisplaySubTypeToggleOnOff:
        {
            signalType = TPSignalTypeKey;
        }
            break;
        default:
            break;
    };
    
    return signalType;
}

@end
