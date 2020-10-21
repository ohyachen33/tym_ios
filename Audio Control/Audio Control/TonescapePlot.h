//
//  TonescapePlot.h
//  Audio Control
//
//  Created by Alain Hsu on 10/11/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TonescapePlot : NSObject

+ (NSData*)datapacketWithVolume:(int)volume power:(int)power x:(float)x y:(float)y z:(float)z;

+ (NSInteger)readPower:(NSData*)data;

//+ (NSInteger)readVolume:(NSData*)data;

+ (NSInteger)readX:(NSData*)data;

+ (NSInteger)readY:(NSData*)data;

+ (NSInteger)readZ:(NSData*)data;

@end
