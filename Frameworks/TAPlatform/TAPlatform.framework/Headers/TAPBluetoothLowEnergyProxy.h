//
//  TAPBluetoothLowEnergyProxy.h
//  TAPProtocol
//
//  Created by Lam Yick Hong on 29/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPProtocolAdaptor.h"
#import "TAPBluetoothLowEnergyCentral.h"
#import "TAPOperationQueue.h"
#import "TPSignal.h"

FOUNDATION_EXPORT NSString * const TAPBluetoothLowEnergyModeTPSignalKey;
FOUNDATION_EXPORT NSString * const TAPBluetoothLowEnergyModeStandardKey;

/*!
 *  @interface TAPBluetoothLowEnergyProxy
 *  @brief     TAP Protocol for BLE. Helps communicating with system in BLE as central mode device.
 *  @author    Hong Lam
 *  @date      29/6/15
 *  @copyright Tymphany Ltd.
 *
 *  @discussion {@link TAPBluetoothLowEnergyProxy} objects are used to communicate with the {@link TAPBluetoothLowEnergyCentral}. It provides logic for the well-formatted feedback from protocol to service.
 */
@interface TAPBluetoothLowEnergyProxy : NSObject <TAPProtocolAdaptor, TAPBluetoothLowEnergyCentralDelegate, TPSignalDelegate>

@end
