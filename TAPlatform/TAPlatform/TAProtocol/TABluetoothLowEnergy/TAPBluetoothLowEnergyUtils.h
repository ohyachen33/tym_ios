//
//  TAPBluetoothLowEnergyUtils.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 6/9/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface TAPBluetoothLowEnergyUtils : NSObject

+ (NSString*)stringOfUUID:(CBUUID*)uuid;

@end
