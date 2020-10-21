//
//  TAPropertyParametricEQ.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAProperty.h"

/*!
 *  @typedef TAPropertyParametricEQSubType
 *  @brief Values representing the sub type of the Parametric EQ
 */
typedef NS_ENUM(NSInteger, TAPropertyParametricEQSubType){
    
    TAPropertyParametricEQSubTypeOnOff = 0,
    TAPropertyParametricEQSubTypeBoost,
    TAPropertyParametricEQSubTypeFrequency,
    TAPropertyParametricEQSubTypeQFactor,
    TAPropertyParametricEQSubTypeUnknown
};

@interface TAPropertyParametricEQ : TAProperty

@property (readonly) TAPropertyParametricEQSubType subType;
@property (readonly) NSInteger index;

- (id)initWithSubType:(TAPropertyParametricEQSubType)subType index:(NSInteger)index;

@end
