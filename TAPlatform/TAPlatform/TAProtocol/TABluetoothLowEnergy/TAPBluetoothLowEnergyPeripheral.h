//
//  TAPBluetoothLowEnergyPeripheral.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 11/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol TAPBluetoothLowEnergyPeripheralDelegate;

// Implements the Bluetooth 4.0 LE Peripheral (Server) interface
//
// This service works by using CoreBluetooth CBPeripheralManager to expose
// a Bluetooth Peripheral (Server) that contains one primary |service|.
//
// The service has one subscribable/notifable |characteristic| that is
// referenced by UUID "c0de".
//
// Any Bluetooth 4.0 LE Central (aka. Client) that subscribes to this peripheral
// will cause a delegate message to be sent. This in turn will allow the
// peripheral to respond with data by calling the |sendToSubscribers| method.
@interface TAPBluetoothLowEnergyPeripheral : NSObject

@property(nonatomic, assign) id<TAPBluetoothLowEnergyPeripheralDelegate> delegate;

@property(nonatomic, strong) NSString *serviceName;
@property(nonatomic, strong) CBUUID *serviceUUID;
@property(nonatomic, strong) CBUUID *characteristicUUID;

// Returns YES if Bluetooth 4 LE is supported on this operation system.
+ (BOOL)isBluetoothSupported;

- (id)initWithDelegate:(id<TAPBluetoothLowEnergyPeripheralDelegate>)delegate;

- (void)sendToSubscribers:(NSData *)data;

- (void)sendBatteryToSubscribers:(NSData *)data;

// Called by the application if it enters the background.
- (void)applicationDidEnterBackground;

// Called by the application if it enters the foregroud.
- (void)applicationWillEnterForeground;

// Allows turning on or off the advertisments.
- (void)startAdvertising;
- (void)stopAdvertising;
- (BOOL)isAdvertising;

@end

// Simplified protocol to respond to subscribers.
@protocol TAPBluetoothLowEnergyPeripheralDelegate <NSObject>

// Called when the peripheral receives a new subscriber.
- (void)peripheral:(TAPBluetoothLowEnergyPeripheral *)peripheral centralDidSubscribe:(CBCentral *)central characteristic:(CBCharacteristic *)characteristic;

- (void)peripheral:(TAPBluetoothLowEnergyPeripheral *)peripheral centralDidUnsubscribe:(CBCentral *)central characteristic:(CBCharacteristic *)characteristic;

- (void)peripheral:(TAPBluetoothLowEnergyPeripheral *)peripheral readCharacteristic:(CBCharacteristic *)characteristic completion:(void (^)(NSData*))data;

- (void)peripheral:(TAPBluetoothLowEnergyPeripheral *)peripheral writeCharacteristic:(CBCharacteristic *)characteristic withData:(NSData*)data completion:(void (^)(NSDictionary*))handler;

@end
