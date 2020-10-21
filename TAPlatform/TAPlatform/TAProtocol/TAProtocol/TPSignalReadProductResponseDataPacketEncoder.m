//
//  TPSignalReadProductResponseDataPacketEncoder.m
//  TAPlatform
//
//  Created by Alain Hsu on 14/03/2017.
//  Copyright © 2017 Tymphany. All rights reserved.
//

#import "TPSignalReadProductResponseDataPacketEncoder.h"
typedef struct{
    Byte returnValue[4];
    Byte numOfProduct;
    Byte values[20] //the max number of features we can have is 20
} TPSignalReadProductResponsePacket_t;
@implementation TPSignalReadProductResponseDataPacketEncoder

- (Byte) getNumOfProduct:(NSData*)setting_packet
{
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalReadProductResponsePacket_t *t_setting_packet = (TPSignalReadProductResponsePacket_t *)byte_stream;
    return t_setting_packet->numOfProduct;
}

- (NSData*) getProductData:(NSData*)setting_packet
{
    NSInteger len = [self getNumOfProduct:setting_packet];
    
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalReadProductResponsePacket_t *t_setting_packet = (TPSignalReadProductResponsePacket_t *)byte_stream;
    NSData *data=  [NSData dataWithBytes:t_setting_packet->values length:len];
    
    return data;
}

@end
