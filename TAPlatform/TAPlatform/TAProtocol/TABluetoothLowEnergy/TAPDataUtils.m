//
//  TAPDataUtils.m
//  TAPProtocol
//
//  Created by Lam Yick Hong on 6/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPDataUtils.h"

@implementation TAPDataUtils

+ (NSData*)reverse:(NSData*)data
{
    if([data length] == 2){
        
        Byte *stream = (Byte*)[data bytes];
        int16_t bytes = stream[1];
        bytes = (bytes << 8) | stream[0];
        
        return [NSData dataWithBytes:&bytes length:sizeof(bytes)];
    }
    
    return data;    
}

+ (NSArray*)arrayOfDataFrom:(NSData*)source length:(NSInteger)length count:(NSInteger)count
{
    if ([source length] >= (length * count))
    {
        NSMutableArray* datas = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < count; i++)
        {
            NSData* subData = [source subdataWithRange:NSMakeRange(i * length, length)];
            
            [datas addObject:subData];
        }
        
        return datas;
    }
    
    return nil;
}

@end
