//
//  TAPropertyParametricEQ.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertyParametricEQ.h"
#import "TASignalType.h"

@interface TAPropertyParametricEQ()

@property (readwrite) TAPropertyParametricEQSubType subType;
@property (readwrite) NSInteger index;

@end

@implementation TAPropertyParametricEQ

- (id)initWithSubType:(TAPropertyParametricEQSubType)subType index:(NSInteger)index
{
    if(self = [super init])
    {
        self.subType = subType;
        self.index = index;
    }
    
    return self;
}

- (NSData*)dataBySignal:(TPSignal*)signal writeData:(NSData*)data
{
    TPSignalType type = TPSignalTypeTotalNumber;
    
    switch (self.subType) {
        case TAPropertyParametricEQSubTypeOnOff:
        {
            switch (self.index) {
                case 0:
                {
                    type = TPSignalTypePEQ1SaveLoadSetting;
                }
                    break;
                case 1:
                {
                    type = TPSignalTypePEQ2SaveLoadSetting;
                }
                    break;
                case 2:
                {
                    type = TPSignalTypePEQ3SaveLoadSetting;
                }
                    break;
                default:
                    break;
            }

        }
            break;
        case TAPropertyParametricEQSubTypeBoost:
        {
            switch (self.index) {
            case 0:
                {
                    type = TPSignalTypeEQ1BoostSetting;
                }
                break;
            case 1:
                {
                    type = TPSignalTypeEQ2BoostSetting;
                }
                break;
            case 2:
                {
                    type = TPSignalTypeEQ3BoostSetting;
                }
                break;
            default:
                break;
            }
        }
            break;
        case TAPropertyParametricEQSubTypeFrequency:
        {
            switch (self.index) {
            case 0:
                {
                    type = TPSignalTypeEQ1FrequencySetting ;
                }
                break;
            case 1:
                {
                    type = TPSignalTypeEQ2FrequencySetting;
                }
                break;
            case 2:
                {
                    type = TPSignalTypeEQ3FrequencySetting;
                }
                break;
            default:
                break;
            }
        }
            break;
        case TAPropertyParametricEQSubTypeQFactor:
        {
            switch (self.index) {
            case 0:
                {
                    type = TPSignalTypeEQ1QFactorSetting;
                }
                break;
            case 1:
                {
                    type = TPSignalTypeEQ2QFactorSetting;
                }
                break;
            case 2:
                {
                    type = TPSignalTypeEQ3QFactorSetting;
                }
                break;
            default:
                break;
            }
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
        case TAPropertyParametricEQSubTypeOnOff:
        {
            switch (self.index) {
                case 0:
                {
                    signalType = TPSignalTypePEQ1SaveLoadSetting;
                }
                    break;
                case 1:
                {
                    signalType = TPSignalTypePEQ2SaveLoadSetting;
                }
                    break;
                case 2:
                {
                    signalType = TPSignalTypePEQ3SaveLoadSetting;
                }
                    break;
                    
                default:
                    break;
            };
        }
            break;
        case TAPropertyParametricEQSubTypeBoost:
        {
            switch (self.index) {
                case 0:
                {
                    signalType = TPSignalTypeEQ1BoostSetting;
                }
                    break;
                case 1:
                {
                    signalType = TPSignalTypeEQ2BoostSetting;
                }
                    break;
                case 2:
                {
                    signalType = TPSignalTypeEQ3BoostSetting;
                }
                    break;
                    
                default:
                    break;
            };
        }
            break;
        case TAPropertyParametricEQSubTypeFrequency:
        {
            switch (self.index) {
                case 0:
                {
                    signalType = TPSignalTypeEQ1FrequencySetting;
                }
                    break;
                case 1:
                {
                    signalType = TPSignalTypeEQ2FrequencySetting;
                }
                    break;
                case 2:
                {
                    signalType = TPSignalTypeEQ2FrequencySetting;
                }
                    break;
                    
                default:
                    break;
            };
        }
            break;
        case TAPropertyParametricEQSubTypeQFactor:
        {
            switch (self.index) {
                case 0:
                {
                    signalType = TPSignalTypeEQ1QFactorSetting;
                }
                    break;
                case 1:
                {
                    signalType = TPSignalTypeEQ2QFactorSetting;
                }
                    break;
                case 2:
                {
                    signalType = TPSignalTypeEQ3QFactorSetting;
                }
                    break;
                    
                default:
                    break;
            };
        }
            break;
            
        default:
            break;
    };
    
    return signalType;
}

@end
