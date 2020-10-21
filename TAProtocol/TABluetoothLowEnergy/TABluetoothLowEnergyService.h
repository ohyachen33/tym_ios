//
//  TABluetoothLowEnergyService.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 7/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#ifndef TAProtocol_TABluetoothLowEnergyService_h
#define TAProtocol_TABluetoothLowEnergyService_h

#define TYM_SERVICE_UUID                        @"7d24"

#define TYM_CHARACTERISTIC_SW_VERSION           @"9876"
#define TYM_CHARACTERISTIC_BATTERY_READ         @"9875"
#define TYM_CHARACTERISTIC_BATTERY_STATUS       @"9874"
#define TYM_CHARACTERISTIC_VOLUME_CONTROL       @"5345" //TODO: make it a volume sync
#define TYM_CHARACTERISTIC_PLAY_CONTROL         @"5342"
#define TYM_CHARACTERISTIC_CURRENT_TRACK_TITLE  @"5341"

typedef NS_ENUM (NSInteger, TABluetoothLowEnergyCharacteristicType){
    TABluetoothLowEnergyCharacteristicTypeSoftwareVersion = 0,
    TABluetoothLowEnergyCharacteristicTypeBatteryRead,
    TABluetoothLowEnergyCharacteristicTypeBatteryStatus,
    TABluetoothLowEnergyCharacteristicTypeVolumeControl,
    TABluetoothLowEnergyCharacteristicTypePlayControl,
    TABluetoothLowEnergyCharacteristicTypeCurrentTrackTitle,
    TABluetoothLowEnergyCharacteristicTypeTymphanyPlatform,
    
    TABluetoothLowEnergyCharacteristicTypeTotalNumber
};

#endif
