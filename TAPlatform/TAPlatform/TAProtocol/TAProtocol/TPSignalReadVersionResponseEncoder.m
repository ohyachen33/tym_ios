//
//  TPSignalReadVersionResponseEncoder.m
//  TAPlatform
//
//  Created by Alain Hsu on 07/02/2017.
//  Copyright © 2017 Tymphany. All rights reserved.
//

#import "TPSignalReadVersionResponseEncoder.h"
typedef struct{
    Byte returnValue[4];
    Byte numOfVersion;
    Byte values[20]; //the max number of features we can have is 20
} TPSignalReadVersionResponsePacket_t;

@implementation TPSignalReadVersionResponseEncoder

- (Byte) getNumOfVersion:(NSData*)setting_packet
{
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalReadVersionResponsePacket_t *t_setting_packet = (TPSignalReadVersionResponsePacket_t *)byte_stream;
    return t_setting_packet->numOfVersion;
}

- (NSData*) getVersionData:(NSData*)setting_packet
{
    NSInteger len = [self getNumOfVersion:setting_packet];
    
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalReadVersionResponsePacket_t *t_setting_packet = (TPSignalReadVersionResponsePacket_t *)byte_stream;
    NSData *data=  [NSData dataWithBytes:t_setting_packet->values length:len];
    
    return data;
}

@end
