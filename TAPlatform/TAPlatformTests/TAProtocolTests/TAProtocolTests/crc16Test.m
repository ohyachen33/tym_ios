//
//  crc16Test.m
//  TPSignal
//
//  Created by John Xu on 4/8/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Crc16.h"
@interface crc16Test : XCTestCase
@property(strong, nonatomic) NSData* testing_data_0;
@property(readwrite, nonatomic) UInt16 crc16_0;
@property(strong, nonatomic) NSData* testing_data_1;
@property(readwrite, nonatomic) UInt16 crc16_1;
@property(strong, nonatomic) NSData* testing_data_2;
@property(readwrite, nonatomic) UInt16 crc16_2;
@property(strong, nonatomic) NSData* testing_data_3;
@property(readwrite, nonatomic) UInt16 crc16_3;
@property(strong, nonatomic) NSData* testing_data_4;
@property(readwrite, nonatomic) UInt16 crc16_4;
@property(strong, nonatomic) NSData* testing_data_5;
@property(readwrite, nonatomic) UInt16 crc16_5;
@end

@implementation crc16Test

- (void)setUp {
    [super setUp];
    
    char string[17] = {0xaa,0x07,0x03,0x13,0x00,0x00,0x00,0x00,0x00,0x05,0x00,0x00,0x00,0x01,0x00,0x00,0x00};
    self.crc16_0 = 0x943a;
   
    self.testing_data_0 = [NSData dataWithBytes:string length:sizeof(string)];
    
    char string_1[17] = {0xaa,0x07,0x03,0x13,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x01,0x00,0x00,0x00};
    self.crc16_1 = 0xd3e9;
    self.testing_data_1 = [NSData dataWithBytes:string_1 length:sizeof(string_1)];
    
    char string_2[17] = {0xaa,0x07,0x03,0x13,0x00,0x00,0x00,0x00,0x00,0x10,0x00,0x00,0x00,0x01,0x00,0x00,0x00};
    self.crc16_2 = 0xe130;
    self.testing_data_2 = [NSData dataWithBytes:string_2 length:sizeof(string_2)];
    
    char string_3[17] = {0xaa,0x07,0x03,0x13,0x00,0x00,0x00,0x00,0x00,0x0b,0x00,0x00,0x00,0x01,0x00,0x00,0x00};
    self.crc16_3 = 0x0a2b;
    self.testing_data_3 = [NSData dataWithBytes:string_3 length:sizeof(string_3)];
    
    
    char string_4[17] = {0xaa,0x07,0x04,0x13,0x00,0x00,0x00,0x00,0x00,0x05,0x00,0x00,0x00,0x07,0x00,0x00,0x00};
    self.crc16_4 = 0xcb34;
    self.testing_data_4 = [NSData dataWithBytes:string_4 length:sizeof(string_4)];

    char string_setting[23] = {0xaa,0x56,0x0b,0x19,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x05,0x00,0x02,0x00,0x09,0x00};
    self.crc16_5 = 0x6358;
    self.testing_data_5 = [NSData dataWithBytes:string_setting length:sizeof(string_setting)];

    
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}


- (void) testInitCRC16WithCRC
{
  
    Crc16 *tested_crc16 = [[Crc16 alloc] initCRC16WithCRC:self.crc16_1];
    
    Crc16 *tested_crc16_2 = [[Crc16 alloc] initCRC16WithCRC:self.crc16_2];
    
   
    UInt16 crc16_3 = 0x0000;
    Crc16 *tested_crc16_3 = [[Crc16 alloc] initCRC16WithCRC:crc16_3];
    
    UInt16 crc16_4 = 0x1000;
    NSData *crc_received4 = [NSData dataWithBytes:&crc16_4 length:2];
    Crc16 *tested_crc16_4 = [[Crc16 alloc] initCRC16WithCRC:(UInt16)[crc_received4 bytes]]; // wrong case
    
  //  Byte crc16_5[] = {0x00,0x10};
    //NSData *crc_received5 = [NSData dataWithBytes:crc16_5 length:2];
    //Crc16 *tested_crc16_5 = [[Crc16 alloc] initCRC16WithCRC:(UInt16)[crc_received5 bytes]]; // wrong case

    
    XCTAssertTrue(tested_crc16.crc16 == self.crc16_1);
    XCTAssertTrue(tested_crc16_2.crc16 == self.crc16_2);
    XCTAssertTrue(tested_crc16_3.crc16 == crc16_3);
    XCTAssertTrue(tested_crc16_4.crc16 != crc16_4); // fail example!
    
  //  XCTAssertTrue(tested_crc16_5.crc16 == 0x1000); // fail example!
    
   // XCTAssertTrue(tested_crc16_5.crc16 == 0x0010);
    XCTAssertTrue(TRUE);
    
}

- (void) testInitAndCalculateCRC16WithPacket
{
    Crc16* tp_crc16_0 = [[Crc16 alloc] initAndCalculateCRC16WithPacket:self.testing_data_0 length:self.testing_data_0.length];
    Crc16* tp_crc16_1 = [[Crc16 alloc] initAndCalculateCRC16WithPacket:self.testing_data_1 length:self.testing_data_1.length];
    Crc16* tp_crc16_2 = [[Crc16 alloc] initAndCalculateCRC16WithPacket:self.testing_data_2 length:self.testing_data_2.length];
    Crc16* tp_crc16_3 = [[Crc16 alloc] initAndCalculateCRC16WithPacket:self.testing_data_3 length:self.testing_data_3.length];
    Crc16* tp_crc16_4 = [[Crc16 alloc] initAndCalculateCRC16WithPacket:self.testing_data_4 length:self.testing_data_4.length];
    Crc16* tp_crc16_5 = [[Crc16 alloc] initAndCalculateCRC16WithPacket:self.testing_data_5 length:self.testing_data_5.length];
    XCTAssertTrue(tp_crc16_0.crc16 == self.crc16_0);
    XCTAssertTrue(tp_crc16_1.crc16 == self.crc16_1);
    XCTAssertTrue(tp_crc16_2.crc16 == self.crc16_2);
    XCTAssertTrue(tp_crc16_3.crc16 == self.crc16_3);
    XCTAssertTrue(tp_crc16_4.crc16 == self.crc16_4);
    XCTAssertFalse(tp_crc16_3.crc16 == self.crc16_0); // to fael
    XCTAssertTrue(tp_crc16_5.crc16 == self.crc16_5);

    
}

- (void) testCheckCRCWithByteStream
{
    Crc16* tp_crc16 = [[Crc16 alloc] init];
    XCTAssertTrue([tp_crc16 checkCRC:self.crc16_0 WithByteStream: self.testing_data_0]);
    XCTAssertTrue([tp_crc16 checkCRC:self.crc16_1 WithByteStream: self.testing_data_1]);
    XCTAssertTrue([tp_crc16 checkCRC:self.crc16_2 WithByteStream: self.testing_data_2]);
    XCTAssertTrue([tp_crc16 checkCRC:self.crc16_3 WithByteStream: self.testing_data_3]);
    XCTAssertTrue([tp_crc16 checkCRC:self.crc16_4 WithByteStream: self.testing_data_4]);
    XCTAssertFalse([tp_crc16 checkCRC:self.crc16_2 WithByteStream: self.testing_data_5]);  // FOR WRONG CASE
}


- (void) testCalculateCRC16WithPacket
{
    Crc16* tp_crc16 = [[Crc16 alloc] init];
    UInt16 crc16_0 = [tp_crc16 calculateCRC16WithPacket:self.testing_data_0 length:self.testing_data_0.length];
    UInt16 crc16_1 = [tp_crc16 calculateCRC16WithPacket:self.testing_data_1 length:self.testing_data_1.length];
    UInt16 crc16_2 = [tp_crc16 calculateCRC16WithPacket:self.testing_data_2 length:self.testing_data_2.length];
    UInt16 crc16_3 = [tp_crc16 calculateCRC16WithPacket:self.testing_data_3 length:self.testing_data_3.length];
    XCTAssertTrue(crc16_0 ==self.crc16_0);
    XCTAssertTrue(crc16_1 ==self.crc16_1);
    XCTAssertTrue(crc16_2 ==self.crc16_2);
    XCTAssertTrue(crc16_3 ==self.crc16_3);
}

@end
