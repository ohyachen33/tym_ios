//
//  TAPropertyPhase.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAProperty.h"

/*!
 *  @typedef TAPropertyPhaseSubType
 *  @brief Values representing the sub type of the phase
 */
typedef NS_ENUM(NSInteger, TAPropertyPhaseSubType){
    
    TAPropertyPhaseSubTypePhase = 0,
    TAPropertyPhaseSubTypePolarity,
    TAPropertyPhaseSubTypeUnknown
};

@interface TAPropertyPhase : TAProperty

@property (readonly) TAPropertyPhaseSubType subType;

- (id)initWithSubType:(TAPropertyPhaseSubType)subType;

@end
