//
//  TAMediaImportServiceTests.m
//  TAPService
//
//  Created by Lam Yick Hong on 3/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TAMediaImportService.h"

@interface TAMediaImportServiceTests : XCTestCase

@end

@implementation TAMediaImportServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExtensionForAssetURL{
    
    //TODO: complete this
    NSString* extension;
    
    extension = [TAMediaImportService extensionForAssetURL:[NSURL URLWithString:@"ipod-library://item/item.mp3?id=4157200259458444598"]];
    XCTAssertEqual(YES, [extension isEqualToString:@"mp3"]);
    
    extension = [TAMediaImportService extensionForAssetURL:[NSURL URLWithString:@"ipod-library://item/item.wav?id=4157200259458444598"]];
    XCTAssertEqual(YES, [extension isEqualToString:@"wav"]);
    
    extension = [TAMediaImportService extensionForAssetURL:[NSURL URLWithString:@"ipod-library://item/item.m4a?id=4157200259458444598"]];
    XCTAssertEqual(YES, [extension isEqualToString:@"m4a"]);
    
    extension = [TAMediaImportService extensionForAssetURL:[NSURL URLWithString:@"ipod-library://item/item.aif?id=4157200259458444598"]];
    XCTAssertEqual(YES, [extension isEqualToString:@"aif"]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
