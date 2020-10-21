//
//  TAPropertySettings.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertySettings.h"
#import "TASignalType.h"
#import "TPSignalConfig.h"

@interface TAPropertySettings()

@property (readwrite) TAPropertySettingsSubType subType;

@end

@implementation TAPropertySettings

- (id)initWithSubType:(TAPropertySettingsSubType)subType
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
    NSData* result = nil;
    
    switch (self.subType) {
        case TAPropertySettingsSubTypeDisplay:
        {
            type = TPSignalTypeDisplaySetting;
            result = [signal settingWriteSignalWithData:data type:type];
        }
            break;
        case TAPropertySettingsSubTypeStandby:
        {
            type = TPSignalTypeStandbySetting;
            result = [signal settingWriteSignalWithData:data type:type];
        }
            break;
        case TAPropertySettingsSubTypeTimeout:
        {
            type = TPSignalTypeTimeoutSetting;
            result = [signal settingWriteSignalWithData:data type:type];
        }
            break;
        case TAPropertySettingsSubTypeFactoryReset:
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
        case TAPropertySettingsSubTypeDisplay:
        {
            signalType = TPSignalTypeDisplaySetting;
        }
            break;
        case TAPropertySettingsSubTypeStandby:
        {
            signalType = TPSignalTypeStandbySetting;
        }
            break;
        case TAPropertySettingsSubTypeTimeout:
        {
            signalType = TPSignalTypeTimeoutSetting;
        }
            break;
        case TAPropertySettingsSubTypeFactoryReset:
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
