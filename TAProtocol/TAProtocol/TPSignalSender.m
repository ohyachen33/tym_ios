//
//  TPSignalSender.m
//  TPSignal
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import "TPSignalSender.h"
#import "TPSignalHeader.h"
#import "Crc16.h"

typedef struct{
    Byte signal_id;
    Byte server_id;
    UInt16 size;
} Header_param_t;

#define GET_MSB(x) (((x)>>8)&0xFF)
#define GET_LSB(x) ((x)&0xFF)



@interface TPSignalSender()

@property (strong, nonatomic) NSMutableData *packet_to_send;

@end

@implementation TPSignalSender

- (id)init
{
    self = [super init];
    if (self)
    {
        self.packet_to_send = [[NSMutableData alloc] init];
    }
    return self;
}


- (NSData *) assemblePacketWithHeaderBlock:(NSData*)header_block encoder:(TPSignalDataPacketEncoder*)encoder body:(NSData*)body value:(NSData*)value
{
    [self appendHeaderToPacket:header_block];
    [self appendDataToPacket:encoder body:body value:value];
    [self appendCRCToPacket:self.packet_to_send];
    NSLog(@"header+payload + crc = %@ ",self.packet_to_send);
    return self.packet_to_send;
}

- (void) appendHeaderToPacket:(NSData*)header_block
{
    TPSignalHeader *tp_header = [[TPSignalHeader alloc] initAndSetupHeaderWithHeaderBlock:header_block];
    [self.packet_to_send appendData:tp_header.header];
    //NSLog(@"header = %@ ",tp_header.header);
}


- (void) appendDataToPacket:(TPSignalDataPacketEncoder*)encoder body:(NSData*)body value:(NSData*)value
{
    //data packet
    NSData* data = [encoder setupDataPacketWithValue:value body:body];
    [self.packet_to_send appendData:data];
    //NSLog(@"payload = %@ ",tp_payload.payload);
}

- (void) appendCRCToPacket:(NSData*)packet
{
    // get crc16
    Crc16* tp_crc16 = [[Crc16 alloc] initAndCalculateCRC16WithPacket:packet length:packet.length];
    Byte lsb = GET_LSB(tp_crc16.crc16);
    Byte msb = GET_MSB(tp_crc16.crc16);
    NSLog(@"lsb = %d , msb = %d crc16 = %d",lsb,msb,tp_crc16.crc16);
    [self.packet_to_send appendBytes:&lsb length:sizeof(lsb)];
    [self.packet_to_send appendBytes:&msb length:sizeof(msb)];
}


@end

