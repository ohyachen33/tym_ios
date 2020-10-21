//
//  TAPProtocolFactory.m
//  TAPService
//
//  Created by Lam Yick Hong on 1/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPProtocolFactory.h"

NSString * const TAPProtocolTypeBluetoothLowEnergy      =   @"BLE";

@implementation TAPProtocolFactory

static NSMutableDictionary* protocols;

+ (id<TAPProtocolAdaptor>)generateProtocol:(NSString*)type config:(NSDictionary*)config
{
    if(!protocols)
    {
        protocols = [[NSMutableDictionary alloc] init];
    }
    
    id<TAPProtocolAdaptor> protocol = [protocols objectForKey:type];
    
    if(!protocol)
    {
        protocol = [TAPProtocolFactory createProtocol:type config:config];
        [protocols setObject:protocol forKey:type];
    }
    
    return protocol;
}

+ (id<TAPProtocolAdaptor>)createProtocol:(NSString*)type config:(NSDictionary*)config
{
    Class class;
    
    if([type hasPrefix:TAPProtocolTypeBluetoothLowEnergy])
    {
        class = NSClassFromString(@"TAPBluetoothLowEnergyProxy");
    }
    
    @try {
        return [[class alloc] initWithConfig:config];
    }
    @catch (NSException *exception) {
        DDLogError(@"Intantiate protocol proxy not created: %@", [exception description]);
        return nil;
    }
    @finally {

    }
    
    return nil;
}

@end
