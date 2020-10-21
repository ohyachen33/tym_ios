//
//  TAPDataUtils.h
//  TAPProtocol
//
//  Created by Lam Yick Hong on 6/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAPDataUtils : NSObject

+ (NSData*)reverse:(NSData*)data;
+ (NSArray*)arrayOfDataFrom:(NSData*)source length:(NSInteger)length count:(NSInteger)count;

@end
