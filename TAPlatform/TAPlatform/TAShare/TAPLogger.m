//
//  TALogger.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 15/9/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPLogger.h"
#import "TAPLoggerFormatter.h"

@implementation TAPLogger

+ (TAPLogger*)sharedLogger
{
    static TAPLogger* sharedLogger = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [[TAPLogger alloc] init];
        
    });
    return sharedLogger;
}


- (id)init
{
    if(self = [super init])
    {
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        [DDASLLogger sharedInstance].logFormatter = [[TAPLoggerFormatter alloc] init];
        [DDTTYLogger sharedInstance].logFormatter = [[TAPLoggerFormatter alloc] init];
        
        DDFileLogger* fileLogger = [[DDFileLogger alloc] init];
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        fileLogger.logFormatter = [[TAPLoggerFormatter alloc] init];
        
        [DDLog addLogger:fileLogger];

        return self;
    }
    
    return nil;
}

@end
