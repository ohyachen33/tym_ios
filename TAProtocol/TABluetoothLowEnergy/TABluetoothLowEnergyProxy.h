//
//  TABluetoothLowEnergyProxy.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 29/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAProtocolAdaptor.h"
#import "TABluetoothLowEnergyCentral.h"
#import "TAOperationQueue.h"
#import "TPSignal.h"

/*!
 *  @interface TABluetoothLowEnergyProxy
 *  @brief     TAP Protocol for BLE. Helps communicating with system in BLE as central mode device.
 *  @author    Hong Lam
 *  @date      29/6/15
 *  @copyright Tymphany Ltd.
 *
 *  @discussion {@link TABluetoothLowEnergyProxy} objects are used to communicate with the {@link TABluetoothLowEnergyCentral}. It provides logic for the well-formatted feedback from protocol to service.
 */
@interface TABluetoothLowEnergyProxy : NSObject <TAProtocolAdaptor, TABluetoothLowEnergyCentralDelegate, TPSignalDelegate>

@end
