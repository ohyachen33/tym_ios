//
//  TPSignalTests.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 2/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TPSignal.h"

@interface TPSignalTests : XCTestCase <TPSignalDelegate>

@property (nonatomic, strong) NSString* testTypeOfParseSignal;

@end

@implementation TPSignalTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testVolumeParseTPSignalPacket {
    
    self.testTypeOfParseSignal = @"volume";
    
    //The data sample is outdated. it's a SIG 40. But it has been updated to 41. We would make up a random number but we should not as the we don't have the correct CRC. TODO:// update when you got a correct sample
    /*Byte dataByte[71] = {
        //SEQ, SIG, SRV_ID, SIZE 2 bytes,
        0xaa, 0x28, 0x00, 0x47, 0x00,
        //QP 4 bytes, return value 4 bytes
        0x28, 0x00, 0x03, 0x01, 0x00, 0x00, 0x00, 0x00,
        //eSetting ID 4 bytes, offset 2 bytes, size 2 bytes
        0x0c, 0x00, 0x00, 0x00, 0x26, 0x00, 0x02, 0x00,
        //data 48 bytes
        0xb0, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        //CRC
        0xa5, 0xd1};
    
    NSData *data = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];
    
    TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];
    [signal parseTPSignalPacket:data];*/
}

- (void)testStringParseTPSignalPacket {
    
    self.testTypeOfParseSignal = @"string";
    
    //TODO: this is preset 1. should test if preset 2 and preset 3 provide correct result as well
    Byte dataByte[73] = {
     //SEQ, SIG, SRV_ID, SIZE 2 bytes,
     0xaa, 0x29, 0x00, 0x49, 0x00,
     //QP 4 bytes, return value 4 bytes
     0x29, 0x00, 0x03, 0x01, 0x00, 0x00, 0x00, 0x00,
     //eSetting ID 4 bytes, offset 2 bytes, size 2 bytes
     0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00,
     //data
     0x20, 0x4d, 0x4f, 0x56, 0x49, 0x45, 0x20, 0x20,
     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
     0x00, 0x00,
     //CRC
     0xa4, 0x11};
     
     NSData *data = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];
     
     TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];
     [signal parseTPSignalPacket:data];
}

- (void)testErrorParseTPSignalPacket {
    
    self.testTypeOfParseSignal = @"error";
    
    Byte dataByte[73] = {
        //SEQ, SIG, SRV_ID, SIZE 2 bytes,
        0xaa, 0x29, 0x00, 0x49, 0x00,
        //QP 4 bytes, return value 4 bytes
        0x29, 0x00, 0x03, 0x01, 0x00, 0x00, 0x00, 0x00,
        //eSetting ID 4 bytes, offset 2 bytes, size 2 bytes
        0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00,
        //data
        0x20, 0x4d, 0x4f, 0x56, 0x49, 0x45, 0x20, 0x20,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00,
        //INCORRECT CRC
        0x00, 0x00};
    
    NSData *data = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];
    
    TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];
    [signal parseTPSignalPacket:data];
}

- (void)didReceiveMessageItem:(NSData *)item type:(TPSignalType)sneakType
{
    if([self.testTypeOfParseSignal isEqualToString:@"volume"])
    {
        XCTAssertEqual(sneakType, TPSignalTypeVolumeSetting);
        
    }
}

- (void) didReceiveStringItem:(NSString*)item type:(TPSignalStringType)stringType
{
    if([self.testTypeOfParseSignal isEqualToString:@"string"])
    {
        XCTAssertEqual(stringType, TPSignalStringTypePreset1Name);
        XCTAssert([item isEqualToString:@" MOVIE  "]);
    }
}

- (void) didFailToParseItem:(NSData*)item error:(NSError*)error
{
    XCTAssertTrue([self.testTypeOfParseSignal isEqualToString:@"error"]);
}


- (void)testStringWriteSignalWithDataType
{
    TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];
    
    NSString* testString = @"testing";
    NSData* data = [testString dataUsingEncoding:NSASCIIStringEncoding];
    
    NSData* packet = [signal stringWriteSignalWithData:data type:TPSignalStringTypePreset1Name];
    
    NSLog(@"%@", [packet description]);
    //TODO: confirm if package is correct
    
    XCTAssert(YES);
}

- (void)testStringReadSignalWithDataType
{
    TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];

    NSData* packet = [signal stringReadSignalWithType:TPSignalStringTypePreset1Name];
    
    NSLog(@"%@", [packet description]);
    //TODO: confirm if package is correct
    
    Byte dataByte[23] = {
        //SEQ, SIG, SRV_ID, SIZE 2 bytes,
        0xaa, 0x59, 0x0b, 0x17, 0x00,
        //QP 8 bytes
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        //eSetting ID 4 bytes, offset 2 bytes, size 2 bytes
        0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00,
        //CRC
        0x77, 0xca};
    
    NSData *data = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];
    
    XCTAssert([data isEqualToData:packet]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
