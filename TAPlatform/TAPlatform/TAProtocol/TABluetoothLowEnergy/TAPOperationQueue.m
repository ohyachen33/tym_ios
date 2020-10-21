//
//  TAPOperationQueue.m
//  TAPProtocol
//
//  Created by Lam Yick Hong on 20/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPOperationQueue.h"
#import "TAPOperation.h"

@interface TAPOperationQueue()

@property (nonatomic, strong) NSMutableArray* queue;
@property (nonatomic, strong) TAPOperation* currentOperation;

@property BOOL isRunning;

@end

@implementation TAPOperationQueue

- (id)init
{
    if(self = [super init])
    {
        self.queue = [[NSMutableArray alloc] init];
        self.isRunning = YES;
        return self;
    }
    
    return nil;
}

- (void)addOperation:(TAPOperation*)operation
{
    [self.queue addObject:operation];
    DDLogVerbose(@"size after added:%lu", (unsigned long)[self.queue count]);

    if([self.queue count] == 1)
    {
        [self tick];
    }
}

- (NSInteger)count
{
    return [self.queue count];
}

- (void)suspend
{
    DDLogVerbose(@"Queue is suspensed (size:%lu)", (unsigned long)[self.queue count]);
    self.isRunning = NO;
}

- (void)restart
{
    DDLogVerbose(@"Queue is to be restarted (size:%lu)", (unsigned long)[self.queue count]);
    self.isRunning = YES;
    [self tick];
}

- (void)flush
{
    DDLogVerbose(@"Queue is to be flushed (size:%lu)", (unsigned long)[self.queue count]);
    
    [self.currentOperation removeObserver:self forKeyPath:@"state" context:nil];
    self.currentOperation = nil;
    
    [self.queue removeAllObjects];
}

- (void)tick
{
    if(!self.isRunning){
        DDLogVerbose(@"Queue is not running (size:%lu)", (unsigned long)[self.queue count]);
        return;
    }
    
    if(self.currentOperation && self.currentOperation.state == TAPOperationStateExecuting){
         
         DDLogVerbose(@"Operation is still running (size:%lu)", (unsigned long)[self.queue count]);
         return;
     }
    
    if(self.currentOperation && self.currentOperation.state == TAPOperationStateFinished){
        
        DDLogVerbose(@"Operation has been finished and clean up here (size:%lu)", (unsigned long)[self.queue count]);
        
        [self.currentOperation removeObserver:self forKeyPath:@"state" context:nil];
        self.currentOperation = nil;
    }
    
    if([self.queue count] > 0)
    {
        self.currentOperation = [self.queue objectAtIndex:0];
        [self.queue removeObject:self.currentOperation];
        
        [self.currentOperation addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [self.currentOperation start];        
        
    }else{
        DDLogVerbose(@"Empty Queue");
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"state"]) {
        
        TAPOperationState state = [[change objectForKey:@"new"] integerValue];
        
        switch (state) {
            case TAPOperationStateReady:
            {
                
            }
                break;
            case TAPOperationStateExecuting:
            {
                
            }
                break;
            case TAPOperationStateFinished:
            {
                [self tick];
            }
                break;
                
            default:
                break;
        }
        
    }else{
        
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Observed keypath in TAPOperationQueue is not a state" userInfo:nil];
    }
    
}

@end
