//
//  TPSignalStringsPacketEncoder.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 5/8/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TPSignalDataPacketEncoder.h"

@interface TPSignalWriteStringsPacketEncoder : TPSignalDataPacketEncoder

- (NSData*) setupDataPacketWithValue:(NSData*)value body:(NSData *)body;
- (Byte*) getOffset:(NSData*)setting_packet length:(int*)len;
- (Byte*) getData:(NSData*)setting_packet length:(int*)len;

@end
