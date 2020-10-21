//
//  TPSignalReadStringPacketEncoder.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 13/8/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TPSignalDataPacketEncoder.h"

@interface TPSignalReadStringPacketEncoder : TPSignalDataPacketEncoder

- (id)init;
- (NSData*) setupDataPacketWithValue:(NSData*)value body:(NSData *)body;
- (Byte*) getOffset:(NSData*)setting_packet length:(int*)len;
- (Byte*) getData:(NSData*)setting_packet length:(int*)len;

@end
