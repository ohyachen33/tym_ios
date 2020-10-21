//
//  TABluetoothLowEnergyCharacteristic.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 7/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "TABluetoothLowEnergyCharacteristic.h"
#import "TABluetoothLowEnergyDefaults.h"

@interface TABluetoothLowEnergyCharacteristic()

@property (nonatomic, strong)NSString* serviceId;

@end

@implementation TABluetoothLowEnergyCharacteristic

/*!
 *  @method initWithType:properties:value:permissions
 *
 *  @param UUID			The Bluetooth UUID of the characteristic.
 *  @param properties	The properties of the characteristic.
 *  @param value		The characteristic value to be cached. If <i>nil</i>, the value will be dynamic and requested on-demand.
 *	@param permissions	The permissions of the characteristic value.
 *
 *  @discussion			Returns an initialized characteristic.
 *
 */

- (id)initWithCharacteristic:(CBCharacteristic*)characteristic
{    
    TABluetoothLowEnergyCharacteristicType newType = TABluetoothLowEnergyCharacteristicTypeTotalNumber;
    
    newType = [[TABluetoothLowEnergyDefaults sharedDefaults] typeByCharacteristicId:characteristic.UUID.UUIDString];
    
    return [self initWithType:newType value:characteristic.value];    
}

- (id)initWithCharacteristic:(CBCharacteristic*)characteristic serviceId:(NSString*)serviceId
{
    TABluetoothLowEnergyCharacteristicType newType = TABluetoothLowEnergyCharacteristicTypeTotalNumber;
    
    newType = [[TABluetoothLowEnergyDefaults sharedDefaults] typeByCharacteristicId:characteristic.UUID.UUIDString];
    
    if(self = [self initWithType:newType value:characteristic.value])
    {
        self.serviceId = serviceId;
    }
    return self;
}

- (id)initWithType:(TABluetoothLowEnergyCharacteristicType)type value:(NSData *)value
{
    self = [super init];
    if (self)
    {
        self.type = type;
        self.value = value;
    }
    
    return self;
}

+ (NSString*) uuid:(NSInteger) type
{

    //TODO: do a correct mapping here
    
    //Testing TP service characteristic
    NSString* uuidString = @"2D73";
    
    if(type == TABluetoothLowEnergyCharacteristicTypeBatteryRead)
    {
        uuidString = @"2A19";
        
    }else if(type == TABluetoothLowEnergyCharacteristicTypeSoftwareVersion)
    {
        uuidString = @"2A26";
        
    }else if(type == TABluetoothLowEnergyCharacteristicTypeVolumeControl)
    {
        uuidString = @"44FA50B2-D0A3-472E-A939-D80CF17638BB";
        
    }
    
    return uuidString;
}

@end
