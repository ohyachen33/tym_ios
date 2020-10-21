//
//  TPSignalReadSettingResponseEncoder.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 2/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSignalDataPacketEncoder.h"

@interface TPSignalReadSettingResponseEncoder : TPSignalDataPacketEncoder

- (Byte*) getSettingId:(NSData*)setting_packet;
- (Byte*) getData:(NSData*)setting_packet length:(int *)len;
- (Byte*) getOffset:(NSData*)setting_packet length:(int*)len;

@end
