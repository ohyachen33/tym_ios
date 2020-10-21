//
//  TAPropertySettings.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAProperty.h"

/*!
 *  @typedef TAPropertySettingsSubType
 *  @brief Values representing the sub type of settings
 */
typedef NS_ENUM(NSInteger, TAPropertySettingsSubType){
    
    TAPropertySettingsSubTypeDisplay = 0,
    TAPropertySettingsSubTypeStandby,
    TAPropertySettingsSubTypeTimeout,
    TAPropertySettingsSubTypeFactoryReset,
    TAPropertySettingsSubTypeUnknown
};

@interface TAPropertySettings : TAProperty

@property (readonly) TAPropertySettingsSubType subType;

- (id)initWithSubType:(TAPropertySettingsSubType)subType;

@end
