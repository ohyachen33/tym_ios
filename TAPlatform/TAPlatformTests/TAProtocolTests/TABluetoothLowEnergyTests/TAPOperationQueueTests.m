//
//  TAPOperationQueue.m
//  TAPProtocol
//
//  Created by Lam Yick Hong on 20/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TAPOperationQueue.h"
#import "TAPOperation.h"

@interface TAPOperationQueueTests : XCTestCase <TAPOperationDelegate>

@property (nonatomic, strong)TAPOperationQueue* queue;

@end

@implementation TAPOperationQueueTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testOperationExecution{
    
    TAPOperationQueue* queue = [[TAPOperationQueue alloc] init];
    TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : @"testOperationExecution", @"characteristic" : @"volume", @"data" : @"1"}];
    
    XCTAssertEqual(operation.state, TAPOperationStateReady);
    
    [queue addOperation:operation];
}

- (void)testOperationsExecution{
    
    self.queue = [[TAPOperationQueue alloc] init];
    TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : @"testOperationsExecution1", @"characteristic" : @"volume", @"data" : @"1"}];
    
    XCTAssertEqual(operation.state, TAPOperationStateReady);
    
    [self.queue addOperation:operation];
    [self.queue addOperation:[[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : @"testOperationsExecution2", @"characteristic" : @"volume", @"data" : @"1"}]];
    [self.queue addOperation:[[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : @"testOperationsExecution3", @"characteristic" : @"volume", @"data" : @"1"}]];
}

- (void)testRestart{
    
    self.queue = [[TAPOperationQueue alloc] init];
    [self.queue suspend];
    
    TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : @"testRestart1", @"characteristic" : @"volume", @"data" : @"1"}];
    [self.queue addOperation:operation];
    
    XCTAssertEqual([self.queue count], 1);
    
    [self.queue restart];
    
    XCTAssertEqual([self.queue count], 0);
}

- (void)execute:(TAPOperation*)operation methodInfo:(NSDictionary*)methodInfo
{
    NSString* method = [methodInfo objectForKey:@"method"];
    
    if([method isEqualToString:@"testOperationExecution"])
    {
        XCTAssertEqual(operation.state, TAPOperationStateExecuting);
        [operation finish];
        XCTAssertEqual(operation.state, TAPOperationStateFinished);
        
    }else if([method isEqualToString:@"testOperationsExecution1"])
    {
        //long running
        [self performSelector:@selector(finish) withObject:nil afterDelay:2.0];
        
    }else if([method isEqualToString:@"testOperationsExecution2"])
    {
        XCTAssertEqual([self.queue count], 2);
        [operation finish];
        XCTAssertEqual([self.queue count], 1);
        
    }else if([method isEqualToString:@"testRestart1"] || [method isEqualToString:@"testRestart2"] )
    {
        [operation finish];
        
    }else if([method isEqualToString:@"testRestart1"])
    {
        XCTAssertEqual([self.queue count], 1);
        [operation finish];
        XCTAssertEqual([self.queue count], 0);
        
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
