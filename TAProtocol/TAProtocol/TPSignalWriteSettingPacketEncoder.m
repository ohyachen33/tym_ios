//
//  TPSignalSettingPacket.m
//  TPSignal
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import "TPSignalWriteSettingPacketEncoder.h"

typedef struct{
    Byte QP_info[8];
    Byte setting_id[4];
    Byte offset[2];
    Byte size[2];
    Byte data[2];
} TPSignalWriteSettingPacket_t;

@implementation TPSignalWriteSettingPacketEncoder


- (Byte*) getOffset:(NSData*)setting_packet length:(int*)len
{
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalWriteSettingPacket_t *t_setting_packet = (TPSignalWriteSettingPacket_t *)byte_stream;
    *len = sizeof(t_setting_packet->offset);
    return t_setting_packet->offset;
}

- (Byte*) getData:(NSData*)setting_packet length:(int *)len
{
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalWriteSettingPacket_t *t_setting_packet = (TPSignalWriteSettingPacket_t *)byte_stream;
    *len = sizeof(t_setting_packet->data);
    return t_setting_packet->data;
}


- (NSData*) setupDataPacketWithValue:(NSData*)value body:(NSData *)body
{
    NSLog(@"in TPSignalSettingPacket \n");
    TPSignalWriteSettingPacket_t t_setting_packet = [self packSettingPacket:body];
    Byte* value_byte = (Byte*)[value bytes];
 //   TPSignalSettingPacket.data[0] = value_byte[0];
 //   TPSignalSettingPacket.data[1] = value_byte[1];
    memcpy(t_setting_packet.data,value_byte,value.length);
    NSData * setting_packet = [NSData dataWithBytes:&t_setting_packet length:sizeof(t_setting_packet)];
    NSLog(@"setting_packet = %@",setting_packet);
    return setting_packet;
}

// helper function to pack

- (TPSignalWriteSettingPacket_t) packSettingPacket:(NSData *)body
{
    // TODO length equal
    NSLog(@"check body length with TPSignalSettingPacket_t %lu \n",(unsigned long)body.length);
    Byte *byte_stream = (Byte*)[body bytes];
    TPSignalWriteSettingPacket_t t_setting_packet;
    memcpy(&t_setting_packet,byte_stream,sizeof(t_setting_packet));
    return t_setting_packet;
}

@end
