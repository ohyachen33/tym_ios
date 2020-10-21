//
//  TPSignalReadFeaturesResponseEncoder.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 20/1/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TPSignalDataPacketEncoder.h"

@interface TPSignalReadFeaturesResponseEncoder : TPSignalDataPacketEncoder

- (Byte*) getNumOfFeatures:(NSData*)setting_packet;
- (Byte*) getData:(NSData*)setting_packet length:(int *)len;

@end
