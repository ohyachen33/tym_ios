//
//  TAPOperationQueue.h
//  TAPProtocol
//
//  Created by Lam Yick Hong on 20/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TAPOperation;
@interface TAPOperationQueue : NSObject

- (void)addOperation:(TAPOperation*)operation;
- (NSInteger)count;

- (void)suspend;
- (void)restart;

- (void)flush;

@end
