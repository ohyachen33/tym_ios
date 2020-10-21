//
//  TAProtocolAdaptor.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 29/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#ifndef TAProtocol_TAProtocolAdaptor_h
#define TAProtocol_TAProtocolAdaptor_h

/*!
 *  @typedef TAProtocolState
 *  @brief Values representing the state of the system service
 */
typedef NS_ENUM(NSInteger, TAPropertyType){
    
    TAPropertyTypeDisplay = 0,
    TAPropertyTypeTimeout,
    TAPropertyTypeStandby,
    
    TAPropertyTypeLowPassOnOff,
    TAPropertyTypeLowPassFrequency,
    TAPropertyTypeLowPassSlope,
    
    TAPropertyTypePEQ1OnOff,
    TAPropertyTypeEQ1Frequency,
    TAPropertyTypeEQ1Boost,
    TAPropertyTypeEQ1QFactor,
    
    TAPropertyTypePEQ2OnOff,
    TAPropertyTypeEQ2Frequency,
    TAPropertyTypeEQ2Boost,
    TAPropertyTypeEQ2QFactor,
    
    TAPropertyTypePEQ3OnOff,
    TAPropertyTypeEQ3Frequency,
    TAPropertyTypeEQ3Boost,
    TAPropertyTypeEQ3QFactor,
    
    TAPropertyTypeRGCOnOff,
    TAPropertyTypeRGCFrequency,
    TAPropertyTypeRGCSlope,

    TAPropertyTypeVolume,
    TAPropertyTypePhase,
    TAPropertyTypePolarity,
    TAPropertyTypeTunning,
    
    TAPropertyTypePresetName1,
    TAPropertyTypePresetName2,
    TAPropertyTypePresetName3,
    TAPropertyTypePresetLoading,
    TAPropertyTypePresetSaving,
    
    TAPropertyTypeFactoryReset,
    
    TAPropertyTypeDeviceName,
    
    TAPropertyTypeModelNumber,
    TAPropertyTypeSerialNumber,
    TAPropertyTypeHardwareNumber,
    TAPropertyTypeSoftwareVersion,
    TAPropertyTypeBattery,
    
    TAPropertyTypePowerStatus,
    
    TAPropertyTypePlaybackStatus,
    TAPropertyTypeTrueWireless,
    
    TAPropertyTypeTonescape,
    
    TAPropertyTypeUnknown
};


enum{
    TAProtocolErrorDomainServiceNotFound = -1,
    TAProtocolErrorDomainServiceInvalidOperation,
    TAProtocolErrorDomainServiceNotSupported,
    TAProtocolErrorDomainServiceUnknown
};

typedef NSInteger TAProtocolErrorDomainServiceCode;

/*!
 *  @typedef TAProtocolState
 *  @brief Values representing the state of the system service
 */
typedef NS_ENUM(NSInteger, TAProtocolState){
    //The states where the protocol is ready
    TAProtocolStateReady = 0,
    //The states where the protocol is on, connected, can operate
    TAProtocolStateOn,
    //The states where the protocol is off
    TAProtocolStateOff,
    //The states where the protocol is not supporting the assigned protocol
    TAProtocolStateUnsupported,
    //The states where the protocol is not authorized to communicate with the system
    TAProtocolStateUnauthorized,
    //The states where the protocol is in unknown
    TAProtocolStateUnknown
};


enum{
    TABluetoothLowEnergyModeTPSignal = 0,
    TABluetoothLowEnergyModeStandard,
    TABluetoothLowEnergyModeUnknown
};

typedef NSInteger TABluetoothLowEnergyMode;

enum{
    TADataFormatTPSignal = 0,
    TADataFormatStandard,
    TADataFormatUnknown
};

typedef NSInteger TADataFormat;


@class TASystem;
@protocol TAProtocolAdaptor <NSObject>

- (id)initWithConfig:(NSDictionary*)config;

- (TAProtocolState)state;

- (TADataFormat)dataFormat;

/*!
 *  @method read:
 *
 *  @param system The target system
 *  @param type The type of value to be read
 *
 *  @brief  Perform read action with the specific type
 */
- (void)read:(TASystem*)system type:(TAPropertyType)type;

/*!
 *  @method write:data:
 *
 *  @param system The target system
 *  @param type The type of value to be written
 *  @param data The data to be written
 *
 *  @brief  Perform write action with the specific type
 */
- (void)write:(TASystem*)system type:(TAPropertyType)type data:(id)data;

/*!
 *  @method subscribe:
 *
 *  @param system The target system
 *  @param type The type of value to be subscribed
 *
 *  @brief  Perform subscribe action with the specific type
 */
- (void)subscribe:(TASystem*)system type:(TAPropertyType)type;

/*!
 *  @method unsubscribe:
 *
 *  @param system The target system
 *  @param type The type of value to be unsubscribed
 *
 *  @brief  Perform unsubscribe action with the specific type
 */
- (void)unsubscribe:(TASystem*)system type:(TAPropertyType)type;

/*!
 *  @method startScan:
 *
 *  @brief	Start scan for system
 */
- (void)startScan;

/*!
 *  @method stopScan:
 *
 *  @brief	Stop scan for system
 */
- (void)stopScan;

@optional

/*!
 *  @method connectSystem:
 *
 *  @param system   The target system
 *
 *  @brief Connects to target system
 *
 */
- (void)connectSystem:(TASystem*)system;

/*!
 *  @method disconnectSystem:
 *
 *  @param system   The target system
 *
 *  @brief Disconnects to target system
 *
 */
- (void)disconnectSystem:(TASystem*)system;

/*!
 *  @method perform:
 *
 *  @param operationInfo    Dictionart which encapsulates all info related to the operation
 *
 *  @return Error object describing what's wrong with this call
 *
 *  @brief A flexible interface. Using this method should be highly cautious and we should always thought about how we should refactor logic here back to an interface
 *
 */
- (NSError*)perform:(NSDictionary*)operationInfo;

@end

#endif
