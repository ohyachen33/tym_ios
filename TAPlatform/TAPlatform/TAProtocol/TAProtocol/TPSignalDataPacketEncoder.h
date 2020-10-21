//
//  TPSignalDataPacket.h
//  TPSignal
//
//  Created by John Xu on 5/5/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPSignalDataPacketEncoder : NSObject

- (NSData*) setupDataPacketWithValue:(NSData*)value body:(NSData*)body;

@end
