//
//  TPSignalReadProductResponseDataPacketEncoder.h
//  TAPlatform
//
//  Created by Alain Hsu on 14/03/2017.
//  Copyright © 2017 Tymphany. All rights reserved.
//

#import "TPSignalDataPacketEncoder.h"

@interface TPSignalReadProductResponseDataPacketEncoder : TPSignalDataPacketEncoder

- (NSData*) getProductData:(NSData*)setting_packet;

@end
