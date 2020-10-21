//
//  TAOperationQueue.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 20/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAOperationQueue.h"
#import "TAOperation.h"

@interface TAOperationQueue()

@property (nonatomic, strong) NSMutableArray* queue;
@property (nonatomic, strong) TAOperation* currentOperation;

@property BOOL isRunning;

@end

@implementation TAOperationQueue

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

- (void)addOperation:(TAOperation*)operation
{
    [self.queue addObject:operation];

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
    self.isRunning = NO;
}

- (void)restart
{
    self.isRunning = YES;
    [self tick];
}

- (void)tick
{
    if(!self.isRunning){
        NSLog(@"Queue is not running");
        return;
    }
    
    if(self.currentOperation && self.currentOperation.state == TAOperationStateExecuting){
         
         NSLog(@"Operation is still running");
         return;
     }
    
    if(self.currentOperation && self.currentOperation.state == TAOperationStateFinished){
        
        NSLog(@"Operation has been finished and clean up here");
        
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
        NSLog(@"Empty Queue");
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"state"]) {
        
        TAOperationState state = [[change objectForKey:@"new"] integerValue];
        //NSLog(@"change - %@", [change description]);
        
        switch (state) {
            case TAOperationStateReady:
            {
                
            }
                break;
            case TAOperationStateExecuting:
            {
                
            }
                break;
            case TAOperationStateFinished:
            {
                [self tick];
            }
                break;
                
            default:
                break;
        }
        
    }else{
        //TODO: throw exception
    }
    
}

@end
