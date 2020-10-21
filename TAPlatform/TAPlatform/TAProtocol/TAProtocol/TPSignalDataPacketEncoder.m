//
//  TPSignalDataPacket.m
//  TPSignal
//
//  Created by John Xu on 5/5/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import "TPSignalDataPacketEncoder.h"

@implementation TPSignalDataPacketEncoder

- (NSData*) setupDataPacketWithValue:(NSData*)value body:(NSData *)body
{
    NSData* val = [NSData dataWithData:value];
    NSMutableData* data = [NSMutableData dataWithData:body];
    [data appendData:val];
    DDLogVerbose(@"in TPSignalDataPacket data packet =%@\n",data);
    return data;
}

@end
