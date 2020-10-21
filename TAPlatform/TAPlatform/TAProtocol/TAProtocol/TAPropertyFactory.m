//
//  TAPropertyFactory.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertyFactory.h"

@implementation TAPropertyFactory

+ (TAProperty*)createPropertyWithType:(TAPropertyType)type
{
    TAProperty* property = nil;
    
    switch (type) {
        case TAPropertyTypeVolume:
        {
            property = [[TAPropertyVolume alloc] init];
        }
            break;
            
        case TAPropertyTypeLowPassOnOff:
        {
            property = [[TAPropertyLowPassFilter alloc] initWithSubType:TAPropertyLowPassFilterSubTypeOnOff];
        }
            break;
            
        case TAPropertyTypeLowPassFrequency:
        {
            property = [[TAPropertyLowPassFilter alloc] initWithSubType:TAPropertyLowPassFilterSubTypeFrequency];
        }
            break;
        case TAPropertyTypeLowPassSlope:
        {
            property = [[TAPropertyLowPassFilter alloc] initWithSubType:TAPropertyLowPassFilterSubTypeSlope];
        }
            break;
        case TAPropertyTypeRGCOnOff:
        {
            property = [[TAPropertyRGC alloc] initWithSubType:TAPropertyRGCSubTypeOnOff];
        }
            break;
        case TAPropertyTypeRGCFrequency:
        {
            property = [[TAPropertyRGC alloc] initWithSubType:TAPropertyRGCSubTypeFrequency];
        }
            break;
        case TAPropertyTypeRGCSlope:
        {
            property = [[TAPropertyRGC alloc] initWithSubType:TAPropertyRGCSubTypeSlope];
        }
            break;
        case TAPropertyTypePhase:
        {
            property = [[TAPropertyPhase alloc] initWithSubType:TAPropertyPhaseSubTypePhase];
        }
            break;
        case TAPropertyTypePolarity:
        {
            property = [[TAPropertyPhase alloc] initWithSubType:TAPropertyPhaseSubTypePolarity];
        }
            break;
        case TAPropertyTypeTuning:
        {
            property = [[TAPropertyPortTuning alloc] init];
        }
            break;
        case TAPropertyTypeEQ1Boost:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeBoost index:0];
        }
            break;
        case TAPropertyTypeEQ1Frequency:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeFrequency index:0];
        }
            break;
        case TAPropertyTypeEQ1QFactor:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeQFactor index:0];
        }
            break;
        case TAPropertyTypeEQ2Boost:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeBoost index:1];
        }
            break;
        case TAPropertyTypeEQ2Frequency:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeFrequency index:1];
        }
            break;
        case TAPropertyTypeEQ2QFactor:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeQFactor index:1];
        }
            break;
        case TAPropertyTypeEQ3Boost:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeBoost index:2];
        }
            break;
        case TAPropertyTypeEQ3Frequency:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeFrequency index:2];
        }
            break;
        case TAPropertyTypeEQ3QFactor:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeQFactor index:2];
        }
            break;
        case TAPropertyTypePEQ1OnOff:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeOnOff index:0];
        }
            break;
        case TAPropertyTypePEQ2OnOff:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeOnOff index:1];
        }
            break;
        case TAPropertyTypePEQ3OnOff:
        {
            property = [[TAPropertyParametricEQ alloc] initWithSubType:TAPropertyParametricEQSubTypeOnOff index:2];
        }
            break;
        case TAPropertyTypeDisplay:
        {
            property = [[TAPropertySettings alloc] initWithSubType:TAPropertySettingsSubTypeDisplay];
        }
            break;
        case TAPropertyTypeStandby:
        {
            property = [[TAPropertySettings alloc] initWithSubType:TAPropertySettingsSubTypeStandby];
        }
            break;
        case TAPropertyTypeTimeout:
        {
            property = [[TAPropertySettings alloc] initWithSubType:TAPropertySettingsSubTypeTimeout];
        }
            break;
        case TAPropertyTypeBrightness:
        {
            property = [[TAPropertyScreenDisplay alloc] initWithSubType:TAPropertyScreenDisplaySubTypeBrightness];
        }
            break;
        case TAPropertyTypePresetName1:
        {
            property = [[TAPropertyPreset alloc] initWithSubType:TAPropertyPresetSubTypeName index:0];
        }
            break;
        case TAPropertyTypePresetName2:
        {
            property = [[TAPropertyPreset alloc] initWithSubType:TAPropertyPresetSubTypeName index:1];
        }
            break;
        case TAPropertyTypePresetName3:
        {
            property = [[TAPropertyPreset alloc] initWithSubType:TAPropertyPresetSubTypeName index:2];
        }
            break;
        case TAPropertyTypePresetLoading:
        {
            property = [[TAPropertyPreset alloc] initWithSubType:TAPropertyPresetSubTypeLoad index:-1];
        }
            break;
            
        case TAPropertyTypePresetSaving:
        {
            property = [[TAPropertyPreset alloc] initWithSubType:TAPropertyPresetSubTypeSave index:-1];
        }
            break;
        case TAPropertyTypeFactoryReset:
        {
            property = [[TAPropertySettings alloc] initWithSubType:TAPropertySettingsSubTypeFactoryReset];
        }
            break;
        case TAPropertyTypeScreenOnOff:
        {
            property = [[TAPropertyScreenDisplay alloc] initWithSubType:TAPropertyScreenDisplaySubTypeToggleOnOff];
        }
            break;
            
        default:
            break;
    }
    
    return property;
}

@end
