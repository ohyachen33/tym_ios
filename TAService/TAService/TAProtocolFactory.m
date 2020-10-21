//
//  TAProtocolFactory.m
//  TAService
//
//  Created by Lam Yick Hong on 1/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAProtocolFactory.h"

@implementation TAProtocolFactory

static NSMutableDictionary* protocols;

+ (id<TAProtocolAdaptor>)generateProtocol:(NSString*)type config:(NSDictionary*)config
{
    if(!protocols)
    {
        protocols = [[NSMutableDictionary alloc] init];
    }
    
    id<TAProtocolAdaptor> protocol = [protocols objectForKey:type];
    
    if(!protocol)
    {
        protocol = [TAProtocolFactory createProtocol:type config:config];
        [protocols setObject:protocol forKey:type];
    }
    
    return protocol;
}

+ (id<TAProtocolAdaptor>)createProtocol:(NSString*)type config:(NSDictionary*)config
{
    Class class;
    
    if([type hasPrefix:@"BLE"])
    {
        class = NSClassFromString(@"TABluetoothLowEnergyProxy");
    }
    
    @try {
        return [[class alloc] initWithConfig:config];
    }
    @catch (NSException *exception) {
        NSLog(@"Intantiate protocol proxy not created: %@", [exception description]);
        return nil;
    }
    @finally {

    }
    
    return nil;
}

@end
