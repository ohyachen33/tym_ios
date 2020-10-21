//
//  TAOperation.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 20/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    TAOperationStateReady = 0,
    TAOperationStateExecuting,
    TAOperationStateFinished,
    TAOperationStateUnknown
};
typedef NSInteger TAOperationState;

@protocol TAOperationDelegate;

@interface TAOperation : NSObject

@property (nonatomic, readonly)TAOperationState state;

- (id)initWithDelegate:(id<TAOperationDelegate>)delegate methodInfo:(NSDictionary*)methodInfo;

- (void)start;
- (void)finish;

@end

@protocol TAOperationDelegate <NSObject>

@required

- (void)execute:(TAOperation*)operation methodInfo:(NSDictionary*)methodInfo;

@optional

@end