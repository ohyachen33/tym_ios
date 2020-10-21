//
//  TABluetoothLowEnergyCentral.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 7/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import "TABluetoothLowEnergyCharacteristic.h"
#import "TAProtocol.h"
#import "TAOperation.h"

#define INTERESTED_SERVICE TYM_SERVICE_UUID
#define TP_SERVICE @"2567" //TODO: Input a correct one
#define TRANSFER_CHARACTERISTIC_BASE_UUID_PREFIX @"01234F7E-DB05-467E-8757-0000"


enum{
    TABluetoothLowEnergyCentralOptionsWithUUID = 0,
    TABluetoothLowEnergyCentralOptionsWithOutUUID
};
typedef NSInteger TABluetoothLowEnergyCentralOptions;


enum{
    TABluetoothLowEnergyCentralStatePowerOn = 0,
    TABluetoothLowEnergyCentralStatePowerOff,
    TABluetoothLowEnergyCentralStateUnknown
};
typedef NSInteger TABluetoothLowEnergyCentralState;

enum{
    TABluetoothLowEnergyCentralScanModeManual = 0,
    TABluetoothLowEnergyCentralScanModeAuto,
    TABluetoothLowEnergyCentralScanModeUnknown
};
typedef NSInteger TABluetoothLowEnergyCentralScanMode;

enum{
    TABluetoothLowEnergyCentralConnectModeManual = 0,
    TABluetoothLowEnergyCentralConnectModeAuto,
    TABluetoothLowEnergyCentralConnectModeUnknown
};
typedef NSInteger TABluetoothLowEnergyCentralConnectMode;



/*!
 *  @protocol TABluetoothLowEnergyCentralDelegate
 *
 *  @brief    Delegate define methods for receive notifications from TABluetoothLowEnergyCentral object.
 *
 *  @discussion The delegate of a {@link TABluetoothLowEnergyCentral} object must adopt the <code>TABluetoothLowEnergyCentralDelegate</code> protocol. The optional methods allow for the discovery and connection of peripherals.
 *
 */
@protocol TABluetoothLowEnergyCentralDelegate;

/*!
 *  @interface TABluetoothLowEnergyCentral
 *  @brief     TAP Protocol for BLE. Helps communicating with system in BLE as central mode device.
 *  @author    Hong Lam
 *  @date      7/2/15
 *  @copyright Tymphany Ltd.
 *
 *  @discussion {@link TABluetoothLowEnergyCentral} objects are used to discover, connect and communicate to a Bluetooth Low Energy peripheral devices. It wraps and manages a CBCentralManager object to communicate with the peripheral devices.
 *
 *  You can use the auto scan and auto connect feature provided by this class during intialization for the ease. You can also set the scan and connect operation in manaul mode and manage them for different cases. This class also provides a queuing mechanism which every BLE read/write action will be queueing up as a TAOperation and being executed one by one.
 */
@interface TABluetoothLowEnergyCentral : NSObject <TAOperationDelegate>
{
    // Delegate to respond back
    id <TABluetoothLowEnergyCentralDelegate> _delegate;
    
}

/*!
 * @property delegate
 *
 *  @discussion
 *      The delegate object.
 *
 */
@property (nonatomic, strong) id<TABluetoothLowEnergyCentralDelegate> delegate;

/*!
 * @property tpServiceUuid
 *
 *  @discussion
 *      The UUID of TP Service.
 *
 */
@property (strong, nonatomic) NSString *tpServiceUuid;

/*!
 *  @method initWithDelegate:
 *
 *  @brief  Initializes the object with a delegate
 *
 *  @param delegate The delegate that will receive central role events.
 *
 *  @discussion     The initialization call. The events of the central role will be dispatched on the main queue.
 *
 */
- (id) initWithDelegate:(id<TABluetoothLowEnergyCentralDelegate>)delegate;

/*!
 *  @method initWithDelegate:uuids:
 *
 *  @brief  Initializes with the delegate, connect and scan mode parameters
 *
 *  @param delegate The delegate that will receive central role events.
 *
 *  @param serviceInfo A dictionary which specify which service and characteristic to be discovered. The dictionary should contain two  sub dictionary as services which has an array of dictionary. Dictionaries in the array should have property "identifier"(string) and "characteristics"(dictionary). "characteristics" consists of an array with the list of characteristic UUID. 
 *
 *  @param scanMode The mode of the scanning behavior
 *
 *  @param connectMode The mode of the connect behavior
 *
 *  @discussion     The initialization call. The events of the central role will be dispatched on the main queue.
 *
 */
- (id) initWithDelegate:(id<TABluetoothLowEnergyCentralDelegate>)delegate serviceInfo:(NSDictionary*)serviceInfo scanMode:(TABluetoothLowEnergyCentralScanMode)scanMode connectMode:(TABluetoothLowEnergyCentralConnectMode)connectMode;


- (CBCentralManagerState)state;

/*!
 *  @method connectDevice:
 *
 *  @brief  Connects to a target peripheral
 *
 *  @param device       The <code>CBPeripheral</code> to be connected.
 *
 *  @discussion         Initiates a connection to <i>peripheral</i> and then discover all characteristic for BLE service. Connection attempts never time out and, depending on the outcome, will result in a call to either {@link bluetoothLowEnergyCentralDidConnectDevice:didDiscoverCharacteristicsForService:} or {@link bluetoothLowEnergyCentralDidFailToConnectDevice:error:}.
 
 Only if connection is established, and then successfully discover service and all the charactertistic within this service, it call {@link TABluetoothLowEnergyDidConnectDevice:didDiscoverCharacteristicsForService:}.
 */
- (void) connectDevice:(CBPeripheral *)device;


/*!
 *  @method disconnectDevice :
 *
 *  @brief  Disconnects from a peripheral
 *
 *  @param device       The <code>CBPeripheral</code> to be connected.
 *
 *  @discussion         Initiates a connection to <i>peripheral</i> and then discover all characteristic for service. Connection attempts never time out and, depending on the outcome, will result in a call to either {@link bluetoothLowEnergyCentralDidConnectDevice:didDiscoverCharacteristicsForService:} or {@link bluetoothLowEnergyDidFailToConnectDevice:error:}.
 
 Only if connection is established, and then successfully discover service and all the characteristic within this service, it call {@link bluetoothLowEnergyCentralDidConnectDevice:didDiscoverCharacteristicsForService:}.
 */
- (void) disconnectDevice:(CBPeripheral *)device;

/*!
 *  @method writeData:forCharacteristic:device:
 *
 *  @brief  Writes data to the characteristic of a specific device
 *
 *  @param data				The value to write.
 *  @param characteristicId The type of characteristic ID whose value will be written.
 *  @param targetPeripheral The target periperal to write data. If it's nil, write to all connected periperals
 *
 *
 *  @discussion				Writes <i>value</i> to <i>characteristic</i>'s characteristic value. {@link bluetoothLowEnergyCentralDidWriteValueForCharacteristic:error:} is called with the result of the write request.
 *
 *  @see					bluetoothLowEnergyCentralDidWriteValueForCharacteristic:error
 
 */
- (void) writeData:(NSData*)data characteristicId:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral;

/*!
 *  @deprecated This method is deprecated due to the multiple connections are out of scope for 1.0
 *
 *  @method writeData:forCharacteristic:
 *
 *  @param data				The value to write.
 *  @param type         	The type of TABluetoothLowEnergyCharacteristicType whose value will be written.
 *
 *  @discussion				Writes <i>value</i> to <i>characteristic</i>'s characteristic value. {@link bluetoothLowEnergyCentralDidWriteValueForCharacteristic:error:} is called with the result of the write request.
 *
 *  @see					bluetoothLowEnergyCentralDidWriteValueForCharacteristic:error
 
 */
- (void) writeData:(NSData*)data forCharacteristic:(TABluetoothLowEnergyCharacteristicType)type;


/*!
 *  @deprecated This method is deprecated due to the multiple connections are out of scope for 1.0
 *
 * @method subscribeCharacteristic:
 *
 *
 *  @param type         	The type of characteristic containing the client characteristic configuration descriptor.
 *
 *  @discussion				Enables notifications/indications for the characteristic value of <i>characteristic</i>. If <i>characteristic</i>
 *							allows both, notifications will be used.
 *                          When notifications/indications are enabled, updates to the characteristic value will be received via delegate method
 *                          @link bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:error: @/link. Since it is the peripheral that chooses when to send an update,
 
 *
 *  @see					bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:error:
 */
- (void)subscribeCharacteristic:(TABluetoothLowEnergyCharacteristicType)type;

/*!
 *  @method subscribeCharacteristic:
 *
 *  @brief  Subscribes to a characterisitic to a target device
 *
 *  @param characteristicId The characteristic ID containing the client characteristic configuration descriptor.
 *  @param targetPeripheral The target peripheral to subscribe to. If it's nil, subscribe to all connected peripherals.
 *
 *  @discussion				Enables notifications/indications for the characteristic value of <i>characteristic</i>. If <i>characteristic</i>
 *							allows both, notifications will be used.
 *                          When notifications/indications are enabled, updates to the characteristic value will be received via delegate method
 *                          @link bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:error: @/link. Since it is the peripheral that chooses when to send an update,
 
 *
 *  @see					bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:error:
 */
- (void)subscribeCharacteristic:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral;

/*!
 *  @method unsubscribeCharacteristic:
 *
 *  @deprecated This method is deprecated due to the multiple connections are out of scope for 1.0
 *
 *  @param type         	The type of characteristic containing the client characteristic configuration descriptor.
 *
 *  @discussion				Disables notifications/indications for the characteristic value of <i>characteristic</i>. If <i>characteristic</i>
 *							updates to the characteristic value will not be received via delegate method
 *
 *
 */
- (void)unsubscribeCharacteristic:(TABluetoothLowEnergyCharacteristicType)type;

/*!
*  @method unsubscribeCharacteristic:
*
*  @brief unsubscribe from a characteristic of target peripheral
*
*  @param characteristicId  The characteristic ID containing the client characteristic configuration descriptor.
*  @param targetPeriperhal  The target periperhal to unsubscribe to. If it's nil, unsubscribe to all connected peripherals.
*
*  @discussion				Disables notifications/indications for the characteristic value of <i>characteristic</i>. If <i>characteristic</i>
*							updates to the characteristic value will not be received via delegate method
*
*
*/
- (void)unsubscribeCharacteristic:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral;

/*!
 *  @method readDataForCharacteristic:
 *
 *  @deprecated This method is deprecated due to the multiple connections are out of scope for 1.0
 *
 *  @param type             the type of TABluetoothLowEnergyCharacteristicType.
 *
 *  @discussion				Reads the characteristic value for <i>type</i>.
 *
 *  @see					bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:error:
 */

- (void)readDataForCharacteristic:(TABluetoothLowEnergyCharacteristicType)type;

/*!
 *  @method readDataForCharacteristic:
 *
 *  @brief Read data from a characteristic of the target periphearl
 *
 *  @param characteristicId     The type characteristicId ID.
 *  @param targetPeriperhals    The target peripherals to read. If it's nil, read from all connected peripherals
 *
 *  @discussion				Reads the characteristic value for <i>type</i>.
 *
 *  @see					bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:error:
 */
- (void)readDataForCharacteristic:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral;

/*!
 *  @method startScan:
 *
 *  @brief				Start scanning for BLE peripheral manually
 *
 */
- (void)startScan;

/*!
 *  @method startScan:
 *
 *  @brief				Stop scanning for BLE peripheral manually
 *
 */
- (void)stopScan;

/*!
 *  @method retreivePeripheral:
 *
 *  @param uuidString           the target peripherals's uuid.
 *  @return The target peripheral
 *
 *  @brief	Using the CBCentralManager retrievePeripheralsWithIdentifiers: method internally.
 *
 */
- (CBPeripheral*)retreivePeripheral:(NSString*)uuidString;

/*!
 *  @method connectedPeripherals:
 *
 *  @return The array of connected peripherals
 *
 *  @brief	Using the CBCentralManager retrieveConnectedPeripheralsWithServices: method internally.
 *
 */
- (NSArray*)connectedPeripherals;

+ (CBService*)serviceWithPeripheral:(CBPeripheral*)peripheral uuidString:(NSString*)uuidString;

@end

@protocol TABluetoothLowEnergyCentralDelegate <NSObject>

@required

@optional

/*!
 *  @method bluetoothLowEnergyCentralDidDiscoverDevice:RSSI:
 *
 *  @param device           A <code>CBPeripheral</code> object.
 *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
 *								was not available.
 *  @brief  Invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>.
 *
 *  @discussion                 Invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must
 *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager.
 *
 */
- (void) bluetoothLowEnergyCentralDidDiscoverDevice:(CBPeripheral *)device RSSI:(NSNumber *)RSSI;

/*!
 *  @method bluetoothLowEnergyCentralDidFailToConnectDevice:error:
 *
 *  @param device   The <code>CBPeripheral</code> that has connected.
 *
 *  @brief          Invoked when a connection initiated by {@link connectDevice:} has failed to complete.
 *
 */
- (void) bluetoothLowEnergyCentralDidConnectToDevice:(CBPeripheral *)device;


/*!
 *  @method bluetoothLowEnergyCentralDidFailToConnectDevice:error:
 *
 *  @param device   The <code>CBPeripheral</code> that has failed to connect.
 *  @param error        The cause of the failure.
 *
 *  @brief  Invoked when a connection initiated by {@link connectDevice:} has failed to complete
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectDevice:} has failed to complete. As connection attempts do not
 *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
 *
 */
- (void) bluetoothLowEnergyCentralDidFailToConnectDevice:(CBPeripheral *)device error:(NSError *)error;

/*!
 *  @method bluetoothLowEnergyCentralDidConnectDevice:didDiscoverCharacteristicsForService:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has connected.
 *
 *  @brief              This method is invoked when a connection initiated by {@link connectDevice:} has succeeded.
 *
 */
- (void) bluetoothLowEnergyCentralDidConnectDevice:(CBPeripheral *)device didDiscoverCharacteristicsForService:(NSArray *)characteristics;

/*!
 *  @method bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A characteristic object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @brief                  This method is invoked after a {@link readDataForCharacteristic:} call, or upon receipt of a notification/indication.
 */
- (void) bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method bluetoothLowEnergyCentralDidWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A characteristic object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @brief                  This method returns the result of a {@link writeData:forCharacteristic:type:} call
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:error:
 *  @param characteristic	A characteristic object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @brief                  This method returns the result of a {@link subscribeCharacteristic:} call.
 */
- (void) bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method bluetoothLowEnergyCentralDidUpdateState:
 *  @param state	A <code>TABluetoothLowEnergyCharacteristic</code> object.
 *
 *  @brief				This method returns the updated bluetooth state
 */
- (void) bluetoothLowEnergyCentralDidUpdateState: (TABluetoothLowEnergyCentralState)state;

/*!
 *  @method bluetoothLowEnergyCentralDidDisconnectPeripheral:error:
 *  @param state	A <code>TABluetoothLowEnergyCharacteristic</code> object.
 *
 *  @brief				This method notifies the delegate object when the App did disconnect from a peripheral
 */
- (void) bluetoothLowEnergyCentralDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

@end
