//
//  TAPropertyScreenDisplay.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAProperty.h"

/*!
 *  @typedef TAPropertyScreenDisplaySubType
 *  @brief Values representing the sub type of screen display
 */
typedef NS_ENUM(NSInteger, TAPropertyScreenDisplaySubType){
    
    TAPropertyScreenDisplaySubTypeBrightness = 0,
    TAPropertyScreenDisplaySubTypeToggleOnOff,
    TAPropertyScreenDisplaySubTypeUnknown
};

@interface TAPropertyScreenDisplay : TAProperty

@property (readonly) TAPropertyScreenDisplaySubType subType;

- (id)initWithSubType:(TAPropertyScreenDisplaySubType)subType;

@end
