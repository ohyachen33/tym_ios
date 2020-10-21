//
//  TAPProtocolAdaptor.h
//  TAPProtocol
//
//  Created by Lam Yick Hong on 29/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#ifndef TAPProtocol_TAPProtocolAdaptor_h
#define TAPProtocol_TAPProtocolAdaptor_h

/*!
 *  @typedef TAPProtocolState
 *  @brief Values representing the state of the system service
 */
typedef NS_ENUM(NSInteger, TAPropertyType){
    
    TAPropertyTypeDisplay = 0,
    TAPropertyTypeTimeout,
    TAPropertyTypeStandby,
    TAPropertyTypeBrightness,
    
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
    TAPropertyTypeTuning,
    
    TAPropertyTypeEqualizer, //this is a decoy right now, 26
    
    TAPropertyTypePresetName1,
    TAPropertyTypePresetName2,
    TAPropertyTypePresetName3,
    TAPropertyTypePresetLoading,
    TAPropertyTypePresetSaving,
    
    TAPropertyTypeFactoryReset,
    TAPropertyTypeScreenOnOff,
    TAPropertyTypeDisplayLock,

    TAPropertyTypeDFU,
    TAPropertyTypeBootloaderCommand,
    
    TAPropertyTypeDeviceName,
    
    TAPropertyTypeModelNumber,
    TAPropertyTypeSerialNumber,
    TAPropertyTypeHardwareNumber,
    TAPropertyTypeSoftwareVersion,
    TAPropertyTypeBattery,
    TAPropertyTypeProductName,
    
    TAPropertyTypePowerStatus,
    
    TAPropertyTypePlaybackStatus,
    TAPropertyTypeTrueWireless,
    
    TAPropertyTypeTonescape,

    TAPropertyTypeAvailableFeatures,
    TAPropertyTypeUnknown
};

/*!
 *  @typedef TAPProtocolState
 *  @brief Values representing the state of the system service
 */
typedef NS_ENUM(NSInteger, TAPProtocolState){
    //The states where the protocol is ready
    TAPProtocolStateReady = 0,
    //The states where the protocol is on, connected, can operate
    TAPProtocolStateOn,
    //The states where the protocol is off
    TAPProtocolStateOff,
    //The states where the protocol is not supporting the assigned protocol
    TAPProtocolStateUnsupported,
    //The states where the protocol is not authorized to communicate with the system
    TAPProtocolStateUnauthorized,
    //The states where the protocol is in unknown
    TAPProtocolStateUnknown
};


enum{
    TAPBluetoothLowEnergyModeTPSignal = 0,
    TAPBluetoothLowEnergyModeStandard,
    TAPBluetoothLowEnergyModeDFU,
    TAPBluetoothLowEnergyModeUnknown
};

typedef NSInteger TAPBluetoothLowEnergyMode;

enum{
    TAPDataFormatTPSignal = 0,
    TAPDataFormatStandard,
    TAPDataFormatUnknown
};

typedef NSInteger TAPDataFormat;


@class TAPSystem;
@protocol TAPProtocolAdaptor <NSObject>

- (id)initWithConfig:(NSDictionary*)config;

- (TAPProtocolState)state;

- (TAPDataFormat)dataFormat;

- (void)isDFUMode:(BOOL)fire;

/*!
 *  @method read:
 *
 *  @param system The target system
 *  @param type The type of value to be read
 *
 *  @brief  Perform read action with the specific type
 */
- (void)read:(TAPSystem*)system type:(TAPropertyType)type;

/*!
 *  @method write:data:
 *
 *  @param system The target system
 *  @param type The type of value to be written
 *  @param data The data to be written
 *
 *  @brief  Perform write action with the specific type
 */
- (void)write:(TAPSystem*)system type:(TAPropertyType)type data:(id)data;

/*!
 *  @method reset:data:
 *
 *  @param system The target system
 *  @param type The type of value to be reset
 *
 *  @brief  Perform reset action with the specific type
 */
- (void)reset:(TAPSystem*)system type:(TAPropertyType)type;

/*!
 *  @method subscribe:
 *
 *  @param system The target system
 *  @param type The type of value to be subscribed
 *
 *  @brief  Perform subscribe action with the specific type
 */
- (void)subscribe:(TAPSystem*)system type:(TAPropertyType)type;

/*!
 *  @method unsubscribe:
 *
 *  @param system The target system
 *  @param type The type of value to be unsubscribed
 *
 *  @brief  Perform unsubscribe action with the specific type
 */
- (void)unsubscribe:(TAPSystem*)system type:(TAPropertyType)type;

/*!
 *  @method startScan:
 *
 *  @param  options      An optional dictionary specifying options for the scan.
 *
 *  @brief    Start scan for system
 */
- (void)startScanWithOptions:(NSDictionary*)options;


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
- (void)connectSystem:(TAPSystem*)system;

/*!
 *  @method disconnectSystem:
 *
 *  @param system   The target system
 *
 *  @brief Disconnects to target system
 *
 */
- (void)disconnectSystem:(TAPSystem*)system;

/*!
 *  @method perform:
 *
 *  @param operationInfo    Dictionart which encapsulates all info related to the operation
 *
 *  @return A info dictionary encapsulate all the information. Including errors.
 *
 *  @brief A flexible interface. Using this method should be highly cautious and we should always thought about how we should refactor logic here back to an interface
 *
 */
- (NSDictionary*)perform:(NSDictionary*)operationInfo;

@end

#endif
