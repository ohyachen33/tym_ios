//
//  TPSignalHeader.m
//  TYM Transfer
//
//  Created by John Xu on 4/5/15.
//  Copyright (c) 2015 TYMPHANY. All rights reserved.
//

#import "TPSignalHeader.h"

@implementation TPSignalHeader


- (id) initAndSetupHeaderWithSigId:(Byte)sig_id srvId:(Byte)srv_id andSize:(UInt16)size16
{
    self = [super init];
    
    if (self)
    {
        self.header = [self setupHeaderWithSigId:sig_id srvId:srv_id andSize:size16];
    }
    return self;
}

- (id) initAndSetupHeaderWithHeaderBlock:(NSData *) header_block
{
    self = [super init];
    
    NSLog(@"if length is not 5 then (TODO)error, %lu",(unsigned long)header_block.length);
    Byte *byte_stream = (Byte*)[header_block bytes];
    Byte sig_id = byte_stream[1];
    Byte srv_id = byte_stream[2];
    UInt16 size16 = byte_stream[4];
    size16 = (size16<<8) | byte_stream[3];
    
    if (self)
    {
        self.header = [self setupHeaderWithSigId:sig_id srvId:srv_id andSize:size16];
        NSLog(@"header = %@ \n",self.header);
    }
    return self;

}

- (void)setupHeaderWithBlock:(NSData *) header_block
{
    self.header = [NSData dataWithData:header_block];
   // return self.header;
}

- (NSData*) setupHeaderWithSigId:(Byte)sig_id srvId:(Byte)srv_id andSize:(UInt16)size16
{
    TPSignalHeader_t tp_header;
    tp_header.sequence_number = SEQ;
    tp_header.signal_id = sig_id;
    tp_header.server_id = srv_id;
    tp_header.LSB = size16 & 0xff;
    tp_header.MSB = (size16>>8) & 0xff;
    NSData* header_packet = [NSData dataWithBytes:(Byte *)&tp_header length:sizeof(TPSignalHeader_t)];
    return header_packet;
}



- (int)getLengthPacket:(NSData *)packet
{
    Byte *byte_stream = (Byte*)[packet bytes];
    TPSignalHeader_t *header = (TPSignalHeader_t *)byte_stream;
    int length = header->MSB;
    length = (length << 8) | header->LSB;
    return length;
}

- (Byte)getTypePacket:(NSData *)packet
{
    Byte *byte_stream = (Byte*)[packet bytes];
    TPSignalHeader_t *header = (TPSignalHeader_t *)byte_stream;
    return header->signal_id;
}


@end
