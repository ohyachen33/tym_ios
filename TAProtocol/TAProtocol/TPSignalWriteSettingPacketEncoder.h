//
//  TPSignalSettingPacket.h
//  TPSignal
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSignalDataPacketEncoder.h"

@interface TPSignalWriteSettingPacketEncoder : TPSignalDataPacketEncoder

- (NSData*) setupDataPacketWithValue:(NSData*)value body:(NSData *)body;
- (Byte*) getOffset:(NSData*)setting_packet length:(int*)len;
- (Byte*) getData:(NSData*)setting_packet length:(int*)len;

@end
