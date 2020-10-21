//
//  TAOperation.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 20/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAOperation.h"

@interface TAOperation()

@property(nonatomic, strong)id<TAOperationDelegate> delegate;
@property(nonatomic, strong)NSDictionary* methodInfo;

@property(nonatomic, readwrite)TAOperationState state;

@end

@implementation TAOperation

- (id)initWithDelegate:(id<TAOperationDelegate>)delegate methodInfo:(NSDictionary*)methodInfo
{
    if(self = [super init])
    {
        self.delegate = delegate;
        self.methodInfo = methodInfo;
        self.state = TAOperationStateReady;
        return self;
    }
    
    return nil;
}

- (void)start
{
    if(self.state != TAOperationStateReady)
    {
        //TODO: throw exception
        return;
    }
    
    self.state = TAOperationStateExecuting;
    
    [self.delegate execute:self methodInfo:self.methodInfo];
}

- (void)finish
{
    if(self.state != TAOperationStateExecuting)
    {
        //TODO: throw exception
        return;
    }
    
    self.state = TAOperationStateFinished;
}

@end
