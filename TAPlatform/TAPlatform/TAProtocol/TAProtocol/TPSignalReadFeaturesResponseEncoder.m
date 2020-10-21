//
//  TPSignalReadFeaturesResponseEncoder.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 20/1/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TPSignalReadFeaturesResponseEncoder.h"

typedef struct{
    Byte returnValue[4];
    Byte numOfFeatures[2];
    Byte features[13]; //the max number of features we can have is 13
} TPSignalReadFeaturesResponsePacket_t;

@implementation TPSignalReadFeaturesResponseEncoder

- (Byte*) getNumOfFeatures:(NSData*)setting_packet
{
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalReadFeaturesResponsePacket_t *t_setting_packet = (TPSignalReadFeaturesResponsePacket_t *)byte_stream;
    return t_setting_packet->numOfFeatures;
}

- (Byte*) getData:(NSData*)setting_packet length:(int *)len
{
    Byte *byte_stream = (Byte*)[setting_packet bytes];
    TPSignalReadFeaturesResponsePacket_t *t_setting_packet = (TPSignalReadFeaturesResponsePacket_t *)byte_stream;
    
    //grab data size as intenger
    int size = t_setting_packet->numOfFeatures[1];
    size = (size << 8) | t_setting_packet->numOfFeatures[0];
    
    *len = size;
    
    return t_setting_packet->features;
}

@end
