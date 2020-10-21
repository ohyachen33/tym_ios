//
//  TASystemSettings.h
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 19/8/15.
//  Copyright (c) 2015 primax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TASystemSettings : NSObject

@property (strong) NSNumber* display;
@property (strong) NSNumber* timeout;
@property (strong) NSNumber* standby;

@property (strong) NSNumber* lowPassOnOff;
@property (strong) NSNumber* lowPassFrequency;
@property (strong) NSNumber* lowPassSlope;

@property (strong) NSNumber* pEq1OnOff;
@property (strong) NSNumber* pEq1Frequency;
@property (strong) NSNumber* pEq1Boost;
@property (strong) NSNumber* pEq1QFactor;

@property (strong) NSNumber* pEq2OnOff;
@property (strong) NSNumber* pEq2Frequency;
@property (strong) NSNumber* pEq2Boost;
@property (strong) NSNumber* pEq2QFactor;

@property (strong) NSNumber* pEq3OnOff;
@property (strong) NSNumber* pEq3Frequency;
@property (strong) NSNumber* pEq3Boost;
@property (strong) NSNumber* pEq3QFactor;

@property (strong) NSNumber* rgcOnOff;
@property (strong) NSNumber* rgcFrequency;
@property (strong) NSNumber* rgcSlope;

@property (strong) NSString* volume;
@property (strong) NSNumber* phase;
@property (strong) NSNumber* polarity;
@property (strong) NSNumber* tunning;



@end
