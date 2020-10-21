//
//  TPSignalStringsPacketEncoder.m
//  TAPProtocol
//
//  Created by Lam Yick Hong on 5/8/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TPSignalWriteStringsPacketEncoder.h"

typedef struct{
    Byte setting_id[4];
    Byte offset[2];
    Byte size[2];
    Byte data[8];
} TPSignalWriteStringPacket_t;

@implementation TPSignalWriteStringsPacketEncoder

- (Byte*) getOffset:(NSData*)setting_packet length:(int*)len
{

    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalWriteStringPacket_t *t_setting_packet = (TPSignalWriteStringPacket_t *)byte_stream;
    *len = sizeof(t_setting_packet->offset);
    return t_setting_packet->offset;
}

- (Byte*) getData:(NSData*)setting_packet length:(int *)len
{
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalWriteStringPacket_t *t_setting_packet = (TPSignalWriteStringPacket_t *)byte_stream;
    *len = sizeof(t_setting_packet->data);
    return t_setting_packet->data;
}

- (Byte*) getWelcomeInfoData:(NSData*)setting_packet length:(int *)len
{
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalWriteStringPacket_t *t_setting_packet = (TPSignalWriteStringPacket_t *)byte_stream;
    *len = sizeof(t_setting_packet->data);
    return t_setting_packet->data;
}


- (NSData*) setupDataPacketWithValue:(NSData*)value body:(NSData *)body
{
    DDLogVerbose(@"in TPSignalWriteStringPacket_t \n");
    TPSignalWriteStringPacket_t t_setting_packet = [self packSettingPacket:body];
    Byte* value_byte = (Byte*)[value bytes];
    memcpy(t_setting_packet.data,value_byte,value.length);
    NSData * setting_packet = [NSData dataWithBytes:&t_setting_packet length:sizeof(t_setting_packet)];
    DDLogVerbose(@"setting_packet = %@",setting_packet);
    return setting_packet;
}

// helper function to pack

- (TPSignalWriteStringPacket_t) packSettingPacket:(NSData *)body
{
    // TODO length equal
    DDLogVerbose(@"check body length with TPSignalWriteStringPacket_t %lu \n",(unsigned long)body.length);
    Byte *byte_stream = (Byte*)[body bytes];
    TPSignalWriteStringPacket_t t_setting_packet;
    memcpy(&t_setting_packet,byte_stream,sizeof(t_setting_packet));
    return t_setting_packet;
}

@end
