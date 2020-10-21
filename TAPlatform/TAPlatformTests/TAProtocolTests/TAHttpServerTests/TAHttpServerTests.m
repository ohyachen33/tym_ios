//
//  TAHttpServerTests.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 27/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TAHttpServer.h"

@interface TAHttpServerTests : XCTestCase

@end

@implementation TAHttpServerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit{
    
    TAHttpServer* server = [[TAHttpServer alloc] init];
    [server start];
    
    XCTAssertEqual(YES, [[server propertyByKey:TAHttpServerConfigPort] longLongValue] == 8081);
    XCTAssertEqual(YES, [[server propertyByKey:TAHttpServerConfigType] isEqualToString:@"_http._tcp."]);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* root = [paths objectAtIndex:0];
    
    XCTAssertEqual(YES, [[server propertyByKey:TAHttpServerConfigRoot] isEqualToString:root]);
    
    [server stop];
}

- (void)testInitWithConfig{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* root = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"web"];
    
    NSDictionary* config = @{TAHttpServerConfigPort : [NSNumber numberWithLongLong:8080],
                             TAHttpServerConfigType : @"_http._tcp.",
                             TAHttpServerConfigRoot : root};
    
    TAHttpServer* server = [[TAHttpServer alloc] initWithConfig:config];
    [server start];
    
    XCTAssertEqual(YES, [[server propertyByKey:TAHttpServerConfigPort] longLongValue] == 8080);
    XCTAssertEqual(YES, [[server propertyByKey:TAHttpServerConfigType] isEqualToString:@"_http._tcp."]);
    
    XCTAssertEqual(YES, [[server propertyByKey:TAHttpServerConfigRoot] isEqualToString:root]);
    
    [server stop];
}

- (void)testCreateRootFolder{

    //folder name
    NSString* foldername = @"test";
    
    TAHttpServer* server = [[TAHttpServer alloc] init];
    [server start];
    
    //create path
    NSString* folderPath = [[server propertyByKey:TAHttpServerConfigRoot] stringByAppendingPathComponent:foldername];
    
    BOOL ready = NO;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:folderPath]){
        //remove it
        ready = [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
    }else{
        //already ready to start unit test
        ready = YES;
    }
    
    if(ready)
    {
        //newly create case
        BOOL result = [server createRootFolder:foldername];
        XCTAssertEqual(YES, result);
        
        //already exist case
        result = [server createRootFolder:foldername];
        XCTAssertEqual(YES, result);
    }else{
        NSLog(@"Setup failed");
    }

    [server stop];
}

- (void)testPerformanceStartServer {

    [self measureBlock:^{
        TAHttpServer* server = [[TAHttpServer alloc] init];
        [server start];
    }];
}

@end
