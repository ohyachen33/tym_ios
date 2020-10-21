//
//  Crc16.h
//  TYM Transfer
//
//  Created by John Xu on 4/3/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Crc16 : NSObject

@property(readwrite, nonatomic) UInt16 crc16;
- (id) initCRC16WithCRC:(UInt16)crc16;
- (id) initAndCalculateCRC16WithPacket:(NSData *)packet length:(NSUInteger)length;
- (bool) checkCRC:(const UInt16)crc16 WithByteStream:(NSData *)byte_stream_without_crc;
- (bool) checkCRCWithWholePacket:(NSData *)whole_packet;
- (UInt16) calculateCRC16WithPacket:(NSData *)packet length:(NSUInteger)length;

@end
