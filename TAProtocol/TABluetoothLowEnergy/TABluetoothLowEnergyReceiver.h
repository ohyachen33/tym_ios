//
//  TABluetoothLowEnergyReceiver.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 9/4/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAProtocol.h"

@class TABluetoothLowEnergyCentral;
@interface TABluetoothLowEnergyReceiver : NSObject

/*!
 *  @method execute:protocol:
 *
 *  @param command      the object that implement TACommand which provide all the information for executing the command
 *  @param central      the BLE central to execute BLE central mode related communication operations
 *
 *  @discussion         We took out this from TABluetoothLowEnergyCentral. This class may need to re-design to define a clear role
 *
 */
+ (void)execute:(id<TACommand>)command protocol:(TABluetoothLowEnergyCentral*)central;

@end
