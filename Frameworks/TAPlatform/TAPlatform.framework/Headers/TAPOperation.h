//
//  TAPOperation.h
//  TAPProtocol
//
//  Created by Lam Yick Hong on 20/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    TAPOperationStateReady = 0,
    TAPOperationStateExecuting,
    TAPOperationStateFinished,
    TAPOperationStateUnknown
};
typedef NSInteger TAPOperationState;

@protocol TAPOperationDelegate;

@interface TAPOperation : NSObject

@property (nonatomic, readonly)TAPOperationState state;

- (id)initWithDelegate:(id<TAPOperationDelegate>)delegate methodInfo:(NSDictionary*)methodInfo;

- (void)start;
- (void)finish;

@end

@protocol TAPOperationDelegate <NSObject>

@required

- (void)execute:(TAPOperation*)operation methodInfo:(NSDictionary*)methodInfo;

@optional

@end