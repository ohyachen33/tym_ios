//
//  TAPropertyDevice.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 13/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAProperty.h"

/*!
 *  @typedef TAPropertyDeviceSubType
 *  @brief Values representing the sub type of device information
 */
typedef NS_ENUM(NSInteger, TAPropertyDeviceSubType){
    
    TAPropertyDeviceSubTypeModelNumber = 0,
    TAPropertyDeviceSubTypeSerialNumber,
    TAPropertyDeviceSubTypeDeviceName,
    TAPropertyDeviceSubTypeSoftwareVersion,
    TAPropertyDeviceSubTypeHardwareNumber,
    TAPropertyDeviceSubTypeUnknown
};

@interface TAPropertyDevice : TAProperty

@property (readonly) TAPropertyDeviceSubType subType;

- (id)initWithSubType:(TAPropertyDeviceSubType)subType;

@end
