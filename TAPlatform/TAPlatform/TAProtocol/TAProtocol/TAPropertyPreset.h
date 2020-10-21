//
//  TAPropertyPreset.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAProperty.h"

/*!
 *  @typedef TAPropertyPresetSubType
 *  @brief Values representing the sub type of Preset
 */
typedef NS_ENUM(NSInteger, TAPropertyPresetSubType){
    
    TAPropertyPresetSubTypeLoad = 0,
    TAPropertyPresetSubTypeSave,
    TAPropertyPresetSubTypeName,
    TAPropertyPresetSubTypeUnknown
};

@interface TAPropertyPreset : TAProperty

@property (readonly) TAPropertyPresetSubType subType;
@property (readonly) NSInteger index;

- (id)initWithSubType:(TAPropertyPresetSubType)subType index:(NSInteger)index;

@end
