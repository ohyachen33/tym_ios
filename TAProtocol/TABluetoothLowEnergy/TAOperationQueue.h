//
//  TAOperationQueue.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 20/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TAOperation;
@interface TAOperationQueue : NSObject

- (void)addOperation:(TAOperation*)operation;
- (NSInteger)count;

- (void)suspend;
- (void)restart;

@end
