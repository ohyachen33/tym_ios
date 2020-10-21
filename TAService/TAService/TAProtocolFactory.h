//
//  TAProtocolFactory.h
//  TAService
//
//  Created by Lam Yick Hong on 1/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAProtocolAdaptor.h"

@interface TAProtocolFactory : NSObject

+ (id<TAProtocolAdaptor>)generateProtocol:(NSString*)type config:(NSDictionary*)config;

@end
