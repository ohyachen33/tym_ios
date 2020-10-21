//
//  TAPOperation.m
//  TAPProtocol
//
//  Created by Lam Yick Hong on 20/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPOperation.h"

@interface TAPOperation()

@property(nonatomic, strong)id<TAPOperationDelegate> delegate;
@property(nonatomic, strong)NSDictionary* methodInfo;

@property(nonatomic, readwrite)TAPOperationState state;

@end

@implementation TAPOperation

- (id)initWithDelegate:(id<TAPOperationDelegate>)delegate methodInfo:(NSDictionary*)methodInfo
{
    if(self = [super init])
    {
        self.delegate = delegate;
        self.methodInfo = methodInfo;
        self.state = TAPOperationStateReady;
        return self;
    }
    
    return nil;
}

- (void)start
{
    if(self.state != TAPOperationStateReady)
    {
        //TODO: throw exception
        return;
    }
    
    self.state = TAPOperationStateExecuting;
    
    [self.delegate execute:self methodInfo:self.methodInfo];
}

- (void)finish
{
    if(self.state != TAPOperationStateExecuting)
    {
        //TODO: throw exception
        return;
    }
    
    self.state = TAPOperationStateFinished;
}

@end
