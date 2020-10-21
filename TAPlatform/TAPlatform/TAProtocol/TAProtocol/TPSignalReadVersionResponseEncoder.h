//
//  TPSignalReadVersionResponseEncoder.h
//  TAPlatform
//
//  Created by Alain Hsu on 07/02/2017.
//  Copyright © 2017 Tymphany. All rights reserved.
//

#import "TPSignalDataPacketEncoder.h"

@interface TPSignalReadVersionResponseEncoder : TPSignalDataPacketEncoder

- (NSData*) getVersionData:(NSData*)setting_packet;

@end
