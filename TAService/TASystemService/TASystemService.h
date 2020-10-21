//
//  TASystemService.h
//  TASystemService
//
//  Created by Lam Yick Hong on 31/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TAService.h"

FOUNDATION_EXPORT NSString * const TASystemKeyDisplay;
FOUNDATION_EXPORT NSString * const TASystemKeyTimeout;
FOUNDATION_EXPORT NSString * const TASystemKeyStandby;

/*!
 *  @typedef TASystemServicePowerStatus
 *  @brief Values representing the current power status
 */
typedef NS_ENUM(NSInteger, TASystemServicePowerStatus){
    //The states where the system is completely turned off
    TASystemServicePowerStatusCompletelyOff = 0,
    //The states where the system is turned on
    TASystemServicePowerStatusOn,
    //The states where the system is standby low
    TASystemServicePowerStatusStandbyLow,
    //The states where the system is standby high
    TASystemServicePowerStatusStandbyHigh,
    //The states where the system is in unknown status
    TASystemServicePowerStatusUnknown
};


/*!
 *  @typedef TASystemServiceState
 *  @brief Values representing the state of the system service
 */
typedef NS_ENUM(NSInteger, TASystemServiceState){
    //The states where the system service is ready, can start scanning
    TASystemServiceStateReady = 0,
    //The states where the system service is off
    TASystemServiceStateOff,
    //The states where the system service is not supporting the assigned protocol
    TASystemServiceStateUnsupported,
    //The states where the system service is not authorized to communicate with the system
    TASystemServiceStateUnauthorized,
    //The states where the system service is in unknown
    TASystemServiceStateUnknown
};

@protocol TASystemServiceDelegate;

/*!
 *  @warning This is a prelimenary document. The TAP libraries and interfaces are under development and will have heavy changes along.
 *
 *  @interface TASystemService
 *  @brief     TAP Service for managing the system. Helps exchange device/system related information.
 *  @author    Hong Lam
 *  @date      31/3/15
 *  @copyright Tymphany Ltd.
 *
 *  @discussion {@link TASystemService} objects are used to retrieve or manipulate any settings on a system with Tymphany system software. This service is particularly important which certain message related to other communication will be returned from this service. E.g. on BLE case, this is the service which notify the App BLE status and if the system is ready for BLE communication. You should not call any API on other service if the {@link TASystemService} object have not notify you BLE state is ready.
 *
 *  You should implement the {@link TASystemServiceDelegate} and assign to the TASystemService object to receive any status update related to the system.
 */
@interface TASystemService : TAService

/*!
 *  @property   delegate
 *  @brief      A TASystemService delegate object
 */
@property (nonatomic, strong) id<TASystemServiceDelegate> delegate;

/*!
 *  @property   state
 *  @brief      The current state of the system service
 */
@property TASystemServiceState state;

/*!
 *  @method initWithType:config:
 *
 *  @param type     The type of the protocol.
 *  @param config   The configuration dictionary
 *  @param delegate The system service delegate object
 *
 *  @brief              Initiates a service instance which make use of a protocol object, with a custom config
 *
 */
- (id)initWithType:(NSString*)type config:(NSDictionary*)config delegate:(id<TASystemServiceDelegate>)delegate;

/*!
 *  @method scanForSystems
 *
 *  @brief Start discovering systems
 *
 *  @discussion Scans for systems over the assigned protocol. You should implement the TASystemServiceDelegate protocol {@link bluetoothLowEnergyCentralDidConnectDevice:didDiscoverCharacteristicsForService:}
 */
- (void)scanForSystems;

/*!
 *  @method stopScanForSystems
 *
 *  @brief Stop discovering systems
 *
 *  @discussion Stops scanning for systems over the assigned protocol.
 */
- (void)stopScanForSystems;

/*!
 *  @method connectSystem:
 *
 *  @param system   The target system
 *
 *  @brief Connects to target system
 *
 */
- (void)connectSystem:(id)system;

/*!
 *  @method disconnectSystem:
 *
 *  @param system   The target system
 *
 *  @brief Disconnects to target system
 *
 */
- (void)disconnectSystem:(id)system;

/*!
 *  @method system:deviceName:
 *
 *  @param system           The target system
 *  @param deviceName       The block which taking the device name as a parameter
 *
 *  @brief                  Reads the model number from the target system
 *
 *
 */
- (void)system:(id)system deviceName:(void (^)(NSString*))deviceName;

/*!
 *  @method system:customName:
 *
 *  @param system           The target system
 *  @param customName       The block which taking the custom name as a parameter
 *
 *  @brief                  Reads the custom number from the target system
 *
 *
 */
- (void)system:(id)system customName:(void (^)(NSString*))customName;

/*!
 *  @method system:writeCustomName:completion:
 *
 *  @param system           The target system
 *  @param customName       The target custom name
 *  @param completion       The completion block
 *
 *  @brief                  Writes the custom name to the target system
 *
 *
 */
- (void)system:(id)system writeCustomName:(NSString*)customName completion:(void (^)(id))complete;

/*!
 *  @method system:modelNumber:
 *
 *  @param system           The target system
 *  @param modelNumber      The block which taking the model number as a parameter
 *
 *  @brief                  Reads the model number from the target system
 *
 */
- (void)system:(id)system modelNumber:(void (^)(NSString*))modelNumber;

/*!
 *  @method system:serialNumber:
 *
 *  @param system           The target system
 *  @param serialNumber     The block which taking the serial number as a parameter
 *
 *  @brief                  Reads the serial number from the target system
 *
 *
 */
- (void)system:(id)system serialNumber:(void (^)(NSString*))serialNumber;

/*!
 *  @method system:hardwareVersion:
 *
 *  @param system           The target system
 *  @param version         	The block which taking the hardware version as a parameter
 *
 *  @brief                  Reads the hardware version from the target system
 *
 *
 */
- (void)system:(id)system hardwareVersion:(void (^)(NSString*))version;

/*!
 *  @method system:softwareVersion:
 *
 *  @param system           The target system
 *  @param version         	The block which taking the software version as a parameter
 *
 *  @brief                  Reads the software version from the target system
 *
 *
 */
- (void)system:(id)system softwareVersion:(void (^)(NSString*))version;

/*!
 *  @method system:batteryLevel:
 *
 *  @param system           The target system
 *  @param batteryLevel     The block which taking the batteryLevel as a parameter
 *
 *  @brief                  Reads the batteryLevel from the target system
 *
 *
 */
- (void)system:(id)system batteryLevel:(void (^)(NSString*))batteryLevel;

/*!
 *  @method startMonitorBatteryStatusOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Starts monitoring the battery status of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE battery charateristic provided by the system in audio service. Whenever there's a battery change, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TASystemService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TASystemService} , {@link system:didUpdateBatteryStatus:} will be triggered and provide the response data.
 *
 *  @see {@link system:didUpdateBatteryStatus:}
 */
- (void)startMonitorBatteryStatusOfSystem:(id)system;

/*!
 *  @method stopMonitorBatteryStatusOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Stops monitoring the battery status of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App unsubscripe to the BLE battery status charateristic provided by the system in audio service.
 *  @see {@link startMonitorBatteryStatusOfSystem:}
 */
- (void)stopMonitorBatteryStatusOfSystem:(id)system;

/*!
 *  @method system:locationName:
 *
 *  @param system           The target system
 *  @param locationName     The block which taking the location name as a parameter
 *
 *  @brief                  Reads the location number from the target system
 *
 *
 */
- (void)system:(id)system locationName:(void (^)(NSString*))locationName;

/*!
 *  @method system:writeLocationName:completion:
 *
 *  @param system           The target system
 *  @param locationName     The target location name
 *  @param completion       The completion block
 *
 *  @brief                  Writes the location name to the target system
 *
 *
 */
- (void)system:(id)system writeLocationName:(NSString*)locationName completion:(void (^)(id))complete;

/*!
 *  @method system:color:
 *
 *  @param system           The target system
 *  @param color            The block which taking the color as a parameter
 *
 *  @brief                  Reads the color from the target system
 *
 *
 */
- (void)system:(id)system color:(void (^)(UIColor*))color;

/*!
 *  @method system:customColor:
 *
 *  @param system           The target system
 *  @param customColor      The block which taking the custom color as a parameter
 *
 *  @brief                  Reads the custom color from the target system
 *
 *
 */
- (void)system:(id)system customColor:(void (^)(UIColor*))customColor;

/*!
 *  @method system:writeCustomColor:completion:
 *
 *  @param system           The target system
 *  @param customColor      The target custom color
 *  @param completion       The completion block
 *
 *  @brief                  Writes the custom color to the target system
 *
 *
 */
- (void)system:(id)system writeCustomColor:(UIColor*)customColor completion:(void (^)(id))complete;

/*!
 *  @method system:powerStatus:
 *
 *  @param system           The target system
 *  @param status           The block which taking the power status as a parameter
 *
 *  @brief                  Reads the power status of the target system
 *
 *
 */
- (void)system:(id)system powerStatus:(void (^)(TASystemServicePowerStatus))status;

/*!
 *  @method system:writeLocationName:completion:
 *
 *  @param system           The target system
 *  @param status           The target power status to turn to
 *  @param completion       The completion block
 *
 *  @brief                  Turns the target system to the target power status
 *
 *
 */
- (void)system:(id)system turnPowerStatus:(TASystemServicePowerStatus)status completion:(void (^)(id))complete;

/*!
 *  @method startMonitorPowerStatusOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Starts monitoring the power status of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE power status charateristic provided by the system in audio service. Whenever there's a power status change, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TASystemService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TASystemService} , {@link system:didUpdatePowerStatus:} will be triggered and provide the response data.
 *
 *  @see {@link system:didUpdateBatteryStatus:}
 */
- (void)startMonitorPowerStatusOfSystem:(id)system;

/*!
 *  @method stopMonitorPowerStatusOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Stops monitoring the battery status of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App unsubscripe to the BLE power status charateristic provided by the system in audio service.
 *  @see {@link startMonitorPowerStatusOfSystem:}
 */
- (void)stopMonitorPowerStatusOfSystem:(id)system;

/*!
 *  @method system:speakerLink:
 *
 *  @param system           The target system
 *  @param config           The block which taking the SpeakerLink config as a parameter
 *
 *  @brief                  Read the SpeakerLink config of the target system
 *
 *
 */
- (void)system:(id)system speakerLink:(void (^)(NSDictionary*))config;

/*!
 *  @method system:configSpeakerLink:completion:
 *
 *  @param system           The target system
 *  @param config           The target config of SpeakerLink
 *  @param completion       The completion block
 *
 *  @brief                  Configue the SpeakerLink of the target system
 *
 *
 */
- (void)system:(id)system configSpeakerLink:(NSDictionary*)config completion:(void (^)(id))complete;

/*!
 *  @method startMonitorSpeakerLinkConfigOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Starts monitoring the SpeakerLink Config of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE SpeakerLink config charateristic provided by the system in audio service. Whenever there's a SpeakerLink config change, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TASystemService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TASystemService} , {@link system:didUpdateSpeakerLinkConfig:} will be triggered and provide the response data.
 *
 *  @see {@link system:didUpdateSpeakerLinkConfig:}
 */
- (void)startMonitorSpeakerLinkConfigOfSystem:(id)system;

/*!
 *  @method stopMonitorSpeakerLinkConfigOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Stops monitoring the battery status of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App unsubscripe to the BLE SpeakerLink config charateristic provided by the system in audio service.
 *  @see {@link startMonitorSpeakerLinkConfigOfSystem:}
 */
- (void)stopMonitorSpeakerLinkConfigOfSystem:(id)system;

/*!
 *  @method system:settings:
 *
 *  @param system           The target system
 *  @param settings         The dictionary encapsulates all the settings
 *
 *  @brief                  Read the settings of the target system
 *
 *
 */
- (void)system:(TASystem*)system settings:(void (^)(NSDictionary*, NSError*))settings;

/*!
 *  @method system:writeSettingsType:value:completion:
 *
 *  @param system           The target system
 *  @param type             The type of the settings
 *  @param value            The value of the settings
 *  @param completion       The completion block
 *
 *  @brief                  Configue one type of settings with a target value of the target system
 *
 *
 */
- (void)system:(TASystem*)system writeSettingsType:(NSString*)type value:(id)value completion:(void (^)(id))complete;

/*!
 *  @method system:settings:
 *
 *  @param system           The target system
 *  @param presentId        The ID of the target preset
 *  @param presetName       The name of the target settings
 *
 *  @brief                  Read the name of the target preset of the target system
 *
 *
 */
- (void)system:(TASystem*)system preset:(NSString*)presetId name:(void (^)(NSString*))presetName;

/*!
 *  @method system:preset:writeName:completion:
 *
 *  @param system           The target system
 *  @param presetId         The ID of the target preset
 *  @param value            The value to be written
 *  @param completion       The completion block
 *
 *  @brief                  Configue name of the target preset of the target system
 *
 *
 */
- (void)system:(TASystem*)system preset:(NSString*)presetId writeName:(NSString*)name completion:(void (^)(id))complete;

/*!
 *  @method system:loadToCurrentFromPreset:completion:
 *
 *  @param system           The target system
 *  @param presetId         The ID of the target preset
 *  @param completion       The completion block
 *
 *  @brief                  Loading the preset value to the system
 *
 *
 */
- (void)system:(TASystem*)system loadToCurrentFromPreset:(NSString*)presetId completion:(void (^)(id))complete;

/*!
 *  @method system:saveCurrentToPreset:completion:
 *
 *  @param system           The target system
 *  @param presetId         The ID of the target preset
 *  @param completion       The completion block
 *
 *  @brief                  Save the current value of the system to the target preset
 *
 *
 */
- (void)system:(TASystem*)system saveCurrentToPreset:(NSString*)presetId completion:(void (^)(id))complete;

/*!
 *  @method system:factoryReset:
 *
 *  @param system           The target system
 *  @param complete         The completion block
 *
 *  @brief                  Factory reset the target system
 */
- (void)system:(id)system factoryReset:(void (^)(id))complete;

@end

/*!
 *  @protocol TASystemServiceDelegate
 *
 *  @brief    Delegate define methods for receive notifications from TASystemService object.
 *
 */
@protocol TASystemServiceDelegate <NSObject>

@required

/*!
 *  @method didUpdateState:
 *
 *  @param state        The state of the system service
 *
 *  @brief              Invoked when there is an udpate of the state of the systemService
 *
 *  @discussion You should only start using the system service when you receive the TASystemServiceStateReady. Different protocol will need to take different steps to initial the system service. For example, BLE will need to wait for the bluetooth radio power on. This delegate function will notify you all these steps completed and the system service are ready to be used.
 */
- (void)didUpdateState:(TASystemServiceState)state;

@optional

/*!
 *  @method didDiscoverDevice:RSSI
 *
 *  @param system       The discovered system
 *  @param RSSI         The RSSI of the system
 *
 *  @brief              Invoked when a new system has been discovered
 */
- (void)didDiscoverSystem:(id)system RSSI:(NSNumber *)RSSI;

/*!
 *  @method didConnectToSystem:success:error:
 *
 *  @param system       The target system
 *  @param success      The connection result
 *  @param error        The connection error
 *
 *  @brief              Invoked when connection operation to the target system is finished
 *  @discussion         Return the connection result no matter it's successful or failed, which is indicated by the success flag. The connection can be successful with or without an error object. This depends on what we received from the system.
 */
- (void)didConnectToSystem:(id)system success:(BOOL)success error:(NSError*)error;

/*!
 *  @method didDisconnectToSystem:error:
 *
 *  @param system       The target system
 *  @param error        The disconnection error
 *
 *  @brief              Invoked when disconnection operation to the target system is finished
 */
- (void)didDisconnectToSystem:(id)system error:(NSError*)error;

/*!
 *  @method system:didUpdateBatteryStatus:
 *
 *  @param system       The system which has this update
 *  @param batteryLevel The new battery level
 *
 *  @brief              Invoked when a the system has a battery update
 */
- (void)system:(id)system didUpdateBatteryStatus:(NSString*)batteryLevel;

/*!
 *  @method system:didUpdatePowerStatus:
 *
 *  @param system       The system which has this update
 *  @param status       The new power status
 *
 *  @brief              Invoked when a the system has a power status update
 */
- (void)system:(id)system didUpdatePowerStatus:(TASystemServicePowerStatus)status;

/*!
 *  @method system:didUpdateTrueWirelessConfig:
 *
 *  @param system       The system which has this update
 *  @param config       The new TrueWireless config
 *
 *  @brief              Invoked when a the system has a truewireless config
 */
- (void)system:(id)system didUpdateTrueWirelessConfig:(NSDictionary*)config;

/*!
 *  @method system:didUpdateSpeakerLinkConfig:
 *
 *  @param system       The system which has this update
 *  @param config       The new SpeakerLink config
 *
 *  @brief              Invoked when a the system has a SpeakerLink update
 */
- (void)system:(id)system didUpdateSpeakerLinkConfig:(NSDictionary*)config;

/*!
 *  @method system:didReceiveError:
 *
 *  @param system        The system which has this update
 *  @param error         The received system error
 *
 *  @brief               Notifies if any errors received from the system
 */
- (void)system:(id)system didReceiveError:(NSError*)error;

@end
