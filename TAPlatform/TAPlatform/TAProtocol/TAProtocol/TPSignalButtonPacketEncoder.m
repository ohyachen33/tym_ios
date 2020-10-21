//
//  TPSignalButtonPacket.m
//  TPSignal
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import "TPSignalButtonPacketEncoder.h"

typedef struct{
    Byte key_id[4];
    Byte key_evt[4];
} TPSignalKeyPacket_t;


@implementation TPSignalButtonPacketEncoder

- (id)init
{
    self = [super init];
    return self;
}

- (NSData*) setupDataPacketWithValue:(NSData*)value body:(NSData *)body
{
    DDLogVerbose(@"in TPSignalKeyPacket \n");
    TPSignalKeyPacket_t t_button_packet = [self packSettingPacket:body];
    Byte* value_byte = (Byte*)[value bytes];
    //TPSignalKeyPacket.key_id[0] = value_byte[0];
    memcpy(t_button_packet.key_id,value_byte,value.length);
    NSData *button_packet = [NSData dataWithBytes:&t_button_packet length:sizeof(t_button_packet)];
    DDLogVerbose(@"button_packet = %@",button_packet);
    return button_packet;
}

- (Byte*) getKeyId:(NSData*)button_packet length:(int*)len
{
    Byte *byte_stream = (Byte*)[button_packet bytes];
    TPSignalKeyPacket_t *t_button_packet = (TPSignalKeyPacket_t *)byte_stream;
    *len = sizeof(t_button_packet->key_id);
    return t_button_packet->key_id;
}

// helper function to pack

- (TPSignalKeyPacket_t) packSettingPacket:(NSData *)body
{
    // TODO length equal
    DDLogVerbose(@"check body length with TPSignalKeyPacket_t %lu \n",(unsigned long)body.length);
    Byte *byte_stream = (Byte*)[body bytes];
    TPSignalKeyPacket_t t_button_packet;
    memcpy(&t_button_packet,byte_stream,sizeof(t_button_packet));
    return t_button_packet;
}

@end
