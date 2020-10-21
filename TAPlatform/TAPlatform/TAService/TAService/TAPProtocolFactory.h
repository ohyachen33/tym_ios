//
//  TAPProtocolFactory.h
//  TAPService
//
//  Created by Lam Yick Hong on 1/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPProtocolAdaptor.h"

FOUNDATION_EXPORT NSString * const TAPProtocolTypeBluetoothLowEnergy;

@interface TAPProtocolFactory : NSObject

+ (id<TAPProtocolAdaptor>)generateProtocol:(NSString*)type config:(NSDictionary*)config;

@end
