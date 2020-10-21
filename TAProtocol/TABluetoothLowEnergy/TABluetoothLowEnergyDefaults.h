//
//  TABluetoothLowEnergyDefaults.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 27/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TABluetoothLowEnergyService.h"

@class CBService;

/*! 
 *  @warning This is a prelimenary document. This class is subjected to be refactored and possibly deprecated.
 *
 *  @interface TABluetoothLowEnergyDefaults
 *
 *  @discussion {@link TABluetoothLowEnergyDefaults} objects are used to load the Default configuration for BLE. This Defaults singleton object will load up the default config file from application level and make it available.
 *
 *  {@link TABluetoothLowEnergyCentral} objects use the TABluetoothLowEnergyDefaults to initialize the target BLE services and characteristics in {@link initWithDelegate:serviceInfo:scanMode:connectMode:}. However, you can always load your own custom config by using {@link createDefault:}.
 */

@interface TABluetoothLowEnergyDefaults : NSObject

/*!
 *  @method sharedDefaults
 *
 *  @discussion				Return the defaults by loading a default config file. If the config file doesn't exist, no serviceInfo will be loaded nor prepared.
 */
+ (TABluetoothLowEnergyDefaults*)sharedDefaults;

/*!
 *  @method createDefault
 *  @param serviceInfo      The dictionary capture the services and characteristic for the BLE library
 *
 *  @discussion				Return the defaults by loading a default config file. If the config file doesn't exist, no serviceInfo will be loaded nor prepared.
 */
- (void)createDefault:(NSDictionary*)serviceInfo;

/*! @deprecated This method is deprecated and to be removed since it's only used in a deprecated class */
- (TABluetoothLowEnergyCharacteristicType)typeByCharacteristicId:(NSString*)characteristicId;

- (NSString*)characteristicIdFromCommandType:(NSString*)commandType;
- (NSString*)commandTypeOfReadingFromCharacteristicId:(NSString*)characteristicId;

- (NSDictionary*)serviceInfo;
- (NSArray*)serviceUuids;
- (NSArray*)characteristicUuidsOfServiceUuid:(NSString*)uuid;

- (NSString*)serviceUuidFromCharacteristicUuid:(NSString*)characteristicId;

- (NSString*)uuidOfTpSignalService;
- (BOOL)hasService:(CBService*)service;

@end
