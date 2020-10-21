//
//  TPSignalSender.h
//  TPSignal
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSignalDataPacketEncoder.h"
#import "TPSignalWriteSettingPacketEncoder.h"
#import "TPSignalButtonPacketEncoder.h"

@interface TPSignalSender : NSObject

- (id) init;
- (NSData *) assemblePacketWithHeaderBlock:(NSData*)header_block encoder:(TPSignalDataPacketEncoder*)encoder body:(NSData*)body value:(NSData*)value;

@end
