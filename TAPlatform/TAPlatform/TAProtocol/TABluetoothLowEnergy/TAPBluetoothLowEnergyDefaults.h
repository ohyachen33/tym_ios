//
//  TAPBluetoothLowEnergyDefaults.h
//  TAPProtocol
//
//  Created by Lam Yick Hong on 27/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPBluetoothLowEnergyService.h"

@class CBService;

/*! 
 *  @warning This is a prelimenary document. This class is subjected to be refactored and possibly deprecated.
 *
 *  @interface TAPBluetoothLowEnergyDefaults
 *
 *  @discussion {@link TAPBluetoothLowEnergyDefaults} objects are used to load the Default configuration for BLE. This Defaults singleton object will load up the default config file from application level and make it available.
 *
 *  {@link TAPBluetoothLowEnergyCentral} objects use the TAPBluetoothLowEnergyDefaults to initialize the target BLE services and characteristics in {@link initWithDelegate:serviceInfo:scanMode:connectMode:}. However, you can always load your own custom config by using {@link createDefault:}.
 */

@interface TAPBluetoothLowEnergyDefaults : NSObject

/*!
 *  @method sharedDefaults
 *
 *  @discussion				Return the defaults by loading a default config file. If the config file doesn't exist, no serviceInfo will be loaded nor prepared.
 */
+ (TAPBluetoothLowEnergyDefaults*)sharedDefaults;

/*!
 *  @method createDefault
 *  @param serviceInfo      The dictionary capture the services and characteristic for the BLE library
 *
 *  @discussion				Return the defaults by loading a default config file. If the config file doesn't exist, no serviceInfo will be loaded nor prepared.
 */
- (void)createDefault:(NSDictionary*)serviceInfo;

/*! @deprecated This method is deprecated and to be removed since it's only used in a deprecated class */
- (TAPBluetoothLowEnergyCharacteristicType)typeByCharacteristicId:(NSString*)characteristicId;

- (NSString*)characteristicIdFromCommandType:(NSString*)commandType;
- (NSString*)commandTypeOfReadingFromCharacteristicId:(NSString*)characteristicId;

- (NSDictionary*)serviceInfo;
- (NSArray*)serviceUuids;
- (NSArray*)characteristicUuidsOfServiceUuid:(NSString*)uuid;

- (NSString*)serviceUuidFromCharacteristicUuid:(NSString*)characteristicId;

- (NSString*)uuidOfTpSignalService;
- (NSString*)uuidOfTpSignalServiceCharacteristic;

- (BOOL)hasService:(CBService*)service;

@end
