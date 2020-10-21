//
//  TPSignalConfig.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 24/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "TPSignalConfig.h"

@implementation TPSignalConfig


+ (NSData*)dataForVolumeUp
{
    Byte byte[4] = {0x05,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForVolumeDown
{
    Byte byte[4] = {0x04,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForLoadPresetOne
{
    Byte byte[4] = {0x18,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForLoadPresetTwo
{
    Byte byte[4] = {0x19,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForLoadPresetThree
{
    Byte byte[4] = {0x1a,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForLoadPresetDefault
{
    Byte byte[4] = {0x1b,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForSavePresetOne
{
    Byte byte[4] = {0x1c,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForSavePresetTwo
{
    Byte byte[4] = {0x1d,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForSavePresetThree
{
    Byte byte[4] = {0x1e,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForFactoryReset
{
    Byte byte[4] = {0x23,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForToggleScreen
{
    Byte byte[4] = {0x2e,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

+ (NSData*)dataForDisplayLock
{
    Byte byte[4] = {0x2f,0x00,0x00,0x00};
    return [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
}

@end
