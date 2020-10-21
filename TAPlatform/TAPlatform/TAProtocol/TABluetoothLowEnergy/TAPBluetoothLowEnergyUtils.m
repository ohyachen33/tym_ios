//
//  TAPBluetoothLowEnergyUtils.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 6/9/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPBluetoothLowEnergyUtils.h"

@implementation TAPBluetoothLowEnergyUtils

+ (NSString*)stringOfUUID:(CBUUID*)uuid
{
    NSString* uuidString = nil;
    
    if([uuid respondsToSelector:@selector(UUIDString)])
    {
        //iOS 7.1+
        uuidString = [uuid UUIDString];
    }else{

        //reference: http://stackoverflow.com/questions/13275859/how-to-turn-cbuuid-into-string
        NSData *data = [uuid data];
        
        NSUInteger bytesToConvert = [data length];
        const unsigned char *uuidBytes = [data bytes];
        NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
        
        for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
        {
            switch (currentByteIndex)
            {
                case 3:
                case 5:
                case 7:
                case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
                default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
            }
            
        }
        
        uuidString = [outputString uppercaseString];
    }
    
    return uuidString;
}

@end
