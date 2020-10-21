//
//  TAPLoggerFormatter.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 17/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface TAPLoggerFormatter : NSObject <DDLogFormatter> {
    int loggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}

@end
