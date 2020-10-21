//
//  TPSignalReceiverTests.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 2/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TPSignalReceiver.h"

@interface TPSignalReceiverTests : XCTestCase <TPSignalReceiverDelegate>

@end

@implementation TPSignalReceiverTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIntegerFromReveresedData {
  
    Byte dataByte[2] = {0x05,0x00};
    NSData *data = [[NSData alloc] initWithBytes:dataByte length:sizeof(dataByte)];
    
    TPSignalReceiver* receiver = [[TPSignalReceiver alloc] initWithDelegate:self];
    int result = [receiver integerFromReveresedData:data];
    
    XCTAssertEqual(result, 5);
}

- (void)testParseCompletePacket {
  
    Byte dataByte[71] = {
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
    
    TPSignalReceiver* receiver = [[TPSignalReceiver alloc] initWithDelegate:self];
    [receiver parseCompletePacket:data];
}

- (void) didParseDataPacket:(NSData*)data_packet type:(Byte)type
{
    XCTAssertEqual(type, 40);
}

@end
