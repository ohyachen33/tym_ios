//
//  TABluetoothLowEnergyCharacteristic.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 7/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TABluetoothLowEnergyService.h"

/*!
 *  @interface TABluetoothLowEnergyCharacteristic
 *
 *  @deprecated This class is deprecated and to be removed
 */
@interface TABluetoothLowEnergyCharacteristic : NSObject

/*!
 * @property type
 *
 *  @discussion
 *      The Bluetooth UUID of the characteristic.
 *
 */
@property(readwrite, nonatomic) TABluetoothLowEnergyCharacteristicType type;

/*!
 * @property value
 *
 *  @discussion
 *      The value of the characteristic.
 *
 */
@property(strong, readwrite) NSData *value;

- (id)initWithCharacteristic:(CBCharacteristic*)characteristic;
- (id)initWithCharacteristic:(CBCharacteristic*)characteristic serviceId:(NSString*)serviceId;
- (id)initWithType:(TABluetoothLowEnergyCharacteristicType)type value:(NSData *)value;

+ (NSString*) uuid:(NSInteger) type;

@end
