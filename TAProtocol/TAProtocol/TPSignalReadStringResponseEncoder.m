//
//  TPSignalReadStringResponseEncoder.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 13/8/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TPSignalReadStringResponseEncoder.h"

typedef struct{
    Byte QP_info[4];
    Byte returnValue[4];
    Byte settingId[4];
    Byte offset[2];
    Byte size[2];
    Byte data[8];
} TPSignalReadSettingResponsePacket_t;

@implementation TPSignalReadStringResponseEncoder

- (Byte*) getOffset:(NSData*)setting_packet length:(int*)len
{
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalReadSettingResponsePacket_t *t_setting_packet = (TPSignalReadSettingResponsePacket_t *)byte_stream;
    *len = sizeof(t_setting_packet->offset);
    return t_setting_packet->offset;
}

- (Byte*) getData:(NSData*)setting_packet length:(int *)len
{
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalReadSettingResponsePacket_t *t_setting_packet = (TPSignalReadSettingResponsePacket_t *)byte_stream;
    
    //grab data size as intenger
    int size = t_setting_packet->size[1];
    size = (size << 8) | t_setting_packet->size[0];
    
    *len = size;
    
    return t_setting_packet->data;
}


@end
