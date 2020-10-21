//
//  TAPropertyLowPassFilter.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAProperty.h"

/*!
 *  @typedef TAPropertyLowPassFilterSubType
 *  @brief Values representing the sub type of the low pass filter
 */
typedef NS_ENUM(NSInteger, TAPropertyLowPassFilterSubType){
    
    TAPropertyLowPassFilterSubTypeOnOff = 0,
    TAPropertyLowPassFilterSubTypeFrequency,
    TAPropertyLowPassFilterSubTypeSlope,
    TAPropertyLowPassFilterSubTypeUnknown
};

@interface TAPropertyLowPassFilter : TAProperty

@property (readonly) TAPropertyLowPassFilterSubType subType;

- (id)initWithSubType:(TAPropertyLowPassFilterSubType)subType;

@end
