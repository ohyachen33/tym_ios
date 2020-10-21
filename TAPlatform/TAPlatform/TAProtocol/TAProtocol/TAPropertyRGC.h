//
//  TAPropertyRGC.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAProperty.h"

/*!
 *  @typedef TAPropertyRGCSubType
 *  @brief Values representing the sub type of the room gain compensation
 */
typedef NS_ENUM(NSInteger, TAPropertyRGCSubType){
    
    TAPropertyRGCSubTypeOnOff = 0,
    TAPropertyRGCSubTypeFrequency,
    TAPropertyRGCSubTypeSlope,
    TAPropertyRGCSubTypeUnknown
};

@interface TAPropertyRGC : TAProperty

@property (readonly) TAPropertyRGCSubType subType;

- (id)initWithSubType:(TAPropertyRGCSubType)subType;

@end
