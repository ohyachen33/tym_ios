//
//  TABluetoothLowEnergyPeripheral.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 11/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TABluetoothLowEnergyPeripheral.h"
#import "TABluetoothLowEnergyCharacteristic.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface TABluetoothLowEnergyPeripheral () <CBPeripheralManagerDelegate>

@property(nonatomic, strong) CBPeripheralManager *peripheral;
@property(nonatomic, strong) CBMutableCharacteristic *characteristic;
@property(nonatomic, assign) BOOL serviceRequiresRegistration;
@property(nonatomic, strong) CBMutableService *service;
@property(nonatomic, strong) NSData *pendingData;

@end

@implementation TABluetoothLowEnergyPeripheral

+ (BOOL)isBluetoothSupported {
    // Only for iOS 6.0
    if (NSClassFromString(@"CBPeripheralManager") == nil) {
        return NO;
    }
    
    // TODO: Make a check to see if the CBPeripheralManager is in unsupported state.
    return YES;
}

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<TABluetoothLowEnergyPeripheralDelegate>)delegate {
    self = [super init];
    if (self) {
        self.peripheral =
        [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        self.delegate = delegate;
    }
    return self;
}

#pragma mark -

- (void)enableService {
    // If the service is already registered, we need to re-register it again.
    if (self.service) {
        [self.peripheral removeService:self.service];
    }
    
    // Create a BTLE Peripheral Service and set it to be the primary. If it
    // is not set to the primary, it will not be found when the app is in the
    // background.
    self.service = [[CBMutableService alloc]
                    initWithType:self.serviceUUID primary:YES];
    
    // Set up the characteristic in the service. This characteristic is only
    // readable through subscription (CBCharacteristicsPropertyNotify) and has
    // no default value set.
    //
    // There is no need to set the permission on characteristic.
    /*self.characteristic =
    [[CBMutableCharacteristic alloc]
     initWithType:self.characteristicUUID
     properties:CBCharacteristicPropertyNotify
     value:nil
     permissions:0];*/
    
    //TODO: refactor this one to a default loading and additional mechanism
    CBMutableCharacteristic* characteristicVersion = [[CBMutableCharacteristic alloc]
                                                      initWithType:[CBUUID UUIDWithString:TYM_CHARACTERISTIC_SW_VERSION]
                                                      properties:CBCharacteristicPropertyRead
                                                      value:nil
                                                      permissions:CBAttributePermissionsReadable];
    
    CBMutableCharacteristic* characteristicBatteryRead = [[CBMutableCharacteristic alloc]
                                                      initWithType:[CBUUID UUIDWithString:TYM_CHARACTERISTIC_BATTERY_READ]
                                                      properties:CBCharacteristicPropertyRead
                                                      value:nil
                                                      permissions:CBAttributePermissionsReadable];
    
    CBMutableCharacteristic* characteristicBatteryStatus = [[CBMutableCharacteristic alloc]
                                                      initWithType:[CBUUID UUIDWithString:TYM_CHARACTERISTIC_BATTERY_STATUS]
                                                      properties:CBCharacteristicPropertyNotify
                                                      value:nil
                                                      permissions:0];
    
    CBMutableCharacteristic* characteristicVolumeControl = [[CBMutableCharacteristic alloc]
                                                      initWithType:[CBUUID UUIDWithString:TYM_CHARACTERISTIC_VOLUME_CONTROL]
                                                      properties:CBCharacteristicPropertyWriteWithoutResponse
                                                      value:nil
                                                      permissions:CBAttributePermissionsWriteable];
    
    CBMutableCharacteristic* characteristicPlayControl = [[CBMutableCharacteristic alloc]
                                                      initWithType:[CBUUID UUIDWithString:TYM_CHARACTERISTIC_PLAY_CONTROL]
                                                      properties:CBCharacteristicPropertyWriteWithoutResponse
                                                      value:nil
                                                      permissions:CBAttributePermissionsWriteable];
    
    CBMutableCharacteristic* characteristicCurrentTrackTitle = [[CBMutableCharacteristic alloc]
                                                      initWithType:[CBUUID UUIDWithString:TYM_CHARACTERISTIC_CURRENT_TRACK_TITLE]
                                                      properties:CBCharacteristicPropertyNotify
                                                      value:nil
                                                      permissions:CBAttributePermissionsReadable];
    
    // Assign the characteristic.
    self.service.characteristics = @[characteristicVersion, characteristicBatteryRead, characteristicBatteryStatus, characteristicVolumeControl, characteristicPlayControl, characteristicCurrentTrackTitle];
    
    //TODO: Battery subscribe. should refactor and make an interface
    self.characteristic = characteristicBatteryStatus;
    
    // Add the service to the peripheral manager.
    [self.peripheral addService:self.service];
}

- (void)disableService {
    
    if(self.peripheral && self.service){
        [self.peripheral removeService:self.service];
        self.service = nil;
    }
    
    [self stopAdvertising];
}


// Called when the BTLE advertisments should start. We don't take down
// the advertisments unless the user switches us off.
- (void)startAdvertising {
    if (self.peripheral.isAdvertising) {
        [self.peripheral stopAdvertising];
    }
    
    NSDictionary *advertisment = @{
                                   CBAdvertisementDataServiceUUIDsKey : @[self.serviceUUID],
                                   CBAdvertisementDataLocalNameKey: self.serviceName
                                   };
    [self.peripheral startAdvertising:advertisment];
}

- (void)stopAdvertising {
    [self.peripheral stopAdvertising];
}

- (BOOL)isAdvertising {
    return [self.peripheral isAdvertising];
}


#pragma mark -

- (void)sendToSubscribers:(NSData *)data {
    if (self.peripheral.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"sendToSubscribers: peripheral not ready for sending state: %ld", self.peripheral.state);
        return;
    }
    
    BOOL success = [self.peripheral updateValue:data
                              forCharacteristic:self.characteristic
                           onSubscribedCentrals:nil];
    if (!success) {
        NSLog(@"Failed to send data, buffering data for retry once ready.");
        self.pendingData = data;
        return;
    }
}

//TODO: refactor this to service layer and using a common interface to send to subscriber instead
- (void)sendBatteryToSubscribers:(NSData *)data {
    if (self.peripheral.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"sendToSubscribers: peripheral not ready for sending state: %ld", self.peripheral.state);
        return;
    }
    
    BOOL success = [self.peripheral updateValue:data
                              forCharacteristic:self.characteristic
                           onSubscribedCentrals:nil];
    if (!success) {
        NSLog(@"Failed to send data, buffering data for retry once ready.");
        self.pendingData = data;
        return;
    }
}

- (void)applicationDidEnterBackground {
    // Deliberately continue advertising so that it still remains discoverable.
}

- (void)applicationWillEnterForeground {
    NSLog(@"applicationWillEnterForeground.");
    // I once thought that it would be good to re-advertise and re-enable
    // the services when coming in the foreground, but it does more harm than
    // good. If we do that, then if there was a Central subscribing to a
    // characteristic, that would get reset.
    //
    // So here we deliberately avoid re-enabling or re-advertising the service.
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
    // As soon as the service is added, we should start advertising.
    [self startAdvertising];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"peripheralStateChange: Powered On");
            // As soon as the peripheral/bluetooth is turned on, start initializing
            // the service.
            [self enableService];
            break;
        case CBPeripheralManagerStatePoweredOff: {
            NSLog(@"peripheralStateChange: Powered Off");
            [self disableService];
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateResetting: {
            NSLog(@"peripheralStateChange: Resetting");
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateUnauthorized: {
            NSLog(@"peripheralStateChange: Deauthorized");
            [self disableService];
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateUnsupported: {
            NSLog(@"peripheralStateChange: Unsupported");
            self.serviceRequiresRegistration = YES;
            // TODO: Give user feedback that Bluetooth is not supported.
            break;
        }
        case CBPeripheralManagerStateUnknown:
            NSLog(@"peripheralStateChange: Unknown");
            break;
        default:
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"didSubscribe: %@", characteristic.UUID);
    NSLog(@"didSubscribe: - Central: %@", central.identifier);
    [self.delegate peripheral:self centralDidSubscribe:central characteristic:characteristic];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"didUnsubscribe: %@", central.identifier);
    [self.delegate peripheral:self centralDidUnsubscribe:central characteristic:characteristic];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
    if (error) {
        NSLog(@"didStartAdvertising: Error: %@", error);
        return;
    }
    NSLog(@"didStartAdvertising");
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"isReadyToUpdateSubscribers");
    if (self.pendingData) {
        NSData *data = [self.pendingData copy];
        self.pendingData = nil;
        [self sendToSubscribers:data];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"- peripheralManager:didReceiveReadRequest:");
    NSLog(@"- UUID: %@",request.characteristic.UUID);

    [self.delegate peripheral:self readCharacteristic:request.characteristic completion:^(NSData* data)
     {
         request.value = data;
         [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
     }];
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    NSLog(@"* peripheralManager:didReceiveWriteRequests:");
    
    for(CBATTRequest *request in requests){
        NSLog(@"* UUID: %@",request.characteristic.UUID);
        NSLog(@"* value: %@",request.value);
        
        [self.delegate peripheral:self writeCharacteristic:request.characteristic withData:request.value completion:^(NSDictionary* handler)
         {
             NSLog(@"Write Completed");
         }];        
    }
}

@end
