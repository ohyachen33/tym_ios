//
//  TAPError.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 8/10/15.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const TAPProtocolErrorDomain;
FOUNDATION_EXPORT NSString * const TAPServiceErrorDomain;

enum{
    TAPErrorCodeNotFound = -1,
    TAPErrorCodeInvalidOperation,
    TAPErrorCodeNotSupported,
    TAPErrorCodeIncorrectType,
    TAPErrorCodeIncorrectPacket,
    TAPErrorCodeTimeout,
    TAPErrorCodeUnknown
};

typedef NSInteger TAPErrorCode;

@interface TAPError : NSError

@end
