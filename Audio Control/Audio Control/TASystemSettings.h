//
//  TASystemSettings.h
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 19/8/15.
//  Copyright (c) 2015 primax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TASystemSettings : NSObject



@property (strong) NSString* volume;

@property (strong) NSNumber* connection;
@property (strong) NSNumber* powerStatus;
@property (strong) NSNumber* playStatus;

@property (strong) NSNumber* EQx;
@property (strong) NSNumber* EQy;
@property (strong) NSNumber* EQz;

@end
