//
//  TAPLoggerFormatter.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 17/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "TAPLoggerFormatter.h"

@implementation TAPLoggerFormatter

- (id)init {
    if((self = [super init])) {
        threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
        [threadUnsafeDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    
    NSString *logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError    : logLevel = @"Error"; break;
        case DDLogFlagWarning  : logLevel = @"Warning"; break;
        case DDLogFlagInfo     : logLevel = @"Info"; break;
        case DDLogFlagDebug    : logLevel = @"Debug"; break;
        default                : logLevel = @"Verbose"; break;
    }

    NSString *dateAndTime = [threadUnsafeDateFormatter stringFromDate:(logMessage->_timestamp)];
    
    
    return [NSString stringWithFormat:@"%@ %@:[%@] %@", dateAndTime, logMessage->_function, logLevel, logMessage->_message];
}

- (void)didAddToLogger:(id <DDLogger>)logger {
    loggerCount++;
    NSAssert(loggerCount <= 1, @"This logger isn't thread-safe");
}

- (void)willRemoveFromLogger:(id <DDLogger>)logger {
    loggerCount--;
}

@end
