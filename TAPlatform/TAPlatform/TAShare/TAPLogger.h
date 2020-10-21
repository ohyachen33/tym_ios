//
//  TALogger.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 15/9/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLumberjack.h"

@interface TAPLogger : NSObject

+ (TAPLogger*)sharedLogger;

@end

