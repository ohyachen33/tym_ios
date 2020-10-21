//
//  TPSignalButtonPacket.h
//  TPSignal
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSignalDataPacketEncoder.h"

@interface TPSignalButtonPacketEncoder : TPSignalDataPacketEncoder
- (id)init;
- (NSData*) setupDataPacketWithValue:(NSData*)value body:(NSData *)body;
- (Byte*) getKeyId:(NSData*)button_packet length:(int*)len;
@end
