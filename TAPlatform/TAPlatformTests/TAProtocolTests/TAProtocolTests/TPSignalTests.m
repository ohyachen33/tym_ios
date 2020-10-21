//
//  TPSignalTests.m
//  TAPProtocol
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

- (void)testFactoryResetKeyTPSignalPacket {
    
    self.testTypeOfParseSignal = @"factory_reset";
    
    Byte byte[4] = {0x22,0x00,0x00,0x00};
    NSData* value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    
    TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];
    
    NSData* packet = [signal keySignalWithKeyIdData:value type:TPSignalTypeKey];
    
    
    Byte dataByte[15] = {
        //SEQ, SIG, SRV_ID, SIZE 2 bytes,
        0xaa, 0x07, 0x04, 0x0f, 0x00,
        //key ID 4 bytes, key event 4 bytes
        0x22, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
        //CRC
        0x93, 0x94};
    
    NSData *sampleData = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];
    
    XCTAssert([sampleData isEqualToData:packet]);
}

/*- (void)testVolumeParseTPSignalPacket {
    
    self.testTypeOfParseSignal = @"volume";
    
    Byte dataByte[17] = {
        //SEQ, SIG, SRV_ID, SIZE 2 bytes,
        0xaa, 0xf0, 0x1f, 0x11, 0x00,
        //eSetting ID 4 bytes
        0x04, 0x00, 0x00, 0x00,
        //offset 2 bytes, size 2 bytes
        0x2a, 0x00, 0x02, 0x00,
        //data 2 bytes
        0x4c, 0xff,
        //CRC
        0xa6, 0xc2};
    
    NSData *data = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];
    
    TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];
    [signal parseTPSignalPacket:data];
}*/

- (void)testTimeOutResetParseTPSignalPacket {
    
    self.testTypeOfParseSignal = @"volume";
    
    Byte dataByte[17] = {
        //SEQ, SIG, SRV_ID, SIZE 2 bytes,
        0xaa, 0xf3, 0x1f, 0x18, 0x00,
        //data 1 bytes
        0x01,
        //CRC
        0x67, 0xc0};
    
    NSData *data = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];
    
    TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];
    [signal parseTPSignalPacket:data];
}

//TODO: fix this. the sample no long valid due to the code change
- (void)testStringParseTPSignalPacket {
    
    self.testTypeOfParseSignal = @"string";
    
    //TODO: this is preset 1. should test if preset 2 and preset 3 provide correct result as well
    Byte dataByte[23] = {
        //SEQ, SIG, SRV_ID, SIZE 2 bytes,
        0xaa, 0xf0, 0x1f, 0x17, 0x00,
        //eSetting ID 4 bytes
        0x08, 0x00, 0x00, 0x00,
        //offset 2 bytes, size 2 bytes
        0x00, 0x00, 0x08, 0x00,
        //data 8 bytes
        0x4d, 0x4f, 0x56, 0x49, 0x45, 0x00, 0x00, 0x00,
        //CRC
        0x1e, 0x87};
     
     NSData *data = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];
     
     TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];
     [signal parseTPSignalPacket:data];
}

- (void)testErrorParseTPSignalPacket {
    
    self.testTypeOfParseSignal = @"error";
    
    Byte dataByte[17] = {
        //SEQ, SIG, SRV_ID, SIZE 2 bytes,
        0xaa, 0xf0, 0x1f, 0x11, 0x00,
        //eSetting ID 4 bytes
        0x04, 0x00, 0x00, 0x00,
        //offset 2 bytes, size 2 bytes
        0x2a, 0x00, 0x02, 0x00,
        //data 2 bytes
        0x4c, 0xff,
        //Error CRC
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
        //XCTAssert([item isEqualToString:@" MOVIE  "]);
    }
}

- (void) didFailToParseItem:(NSData*)item error:(NSError*)error
{
    XCTAssertTrue([self.testTypeOfParseSignal isEqualToString:@"error"]);
}


- (void)testStringWriteSignalWithDataType
{
    TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];
    
    NSString* testString = @" MOVIE ";
    NSData* data = [testString dataUsingEncoding:NSASCIIStringEncoding];
    
    NSData* packet = [signal stringWriteSignalWithData:data type:TPSignalStringTypePreset1Name];
    
    Byte dataByte[23] = {
        //SEQ, SIG, SRV_ID, SIZE 2 bytes,
        0xaa, 0xf0, 0x1f, 0x17, 0x00,
        //eSetting ID 4 bytes, offset 2 bytes, size 2 bytes
        0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00,
        //data 8 bytes
        0x20, 0x4d, 0x4f, 0x56, 0x49, 0x45, 0x20, 0x00,
        //CRC
        0x6d, 0xb0};
    
    NSData *sampleData = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];
    
    XCTAssert([sampleData isEqualToData:packet]);
}

- (void)testStringReadSignalWithDataType
{
    TPSignal* signal = [[TPSignal alloc] initWithDelegate:self];

    NSData* packet = [signal stringReadSignalWithType:TPSignalStringTypePreset1Name];
    
    Byte dataByte[15] = {
        //SEQ, SIG, SRV_ID, SIZE 2 bytes,
        0xaa, 0xf1, 0x1f, 0x0f, 0x00,
        //eSetting ID 4 bytes, offset 2 bytes, size 2 bytes
        0x8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00,
        //CRC
        0xfc, 0x2b};
    
    NSData *sampleData = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];

    XCTAssert([sampleData isEqualToData:packet]);
}

@end
