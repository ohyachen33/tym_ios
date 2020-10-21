//
//  TABluetoothLowEnergyCentral.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 7/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAProtocol.h"
#import "TABluetoothLowEnergyCentral.h"
#import "TAOperationQueue.h"
#import "TABluetoothLowEnergyReceiver.h"
#import "TABluetoothLowEnergyDefaults.h"
#import "TABluetoothLowEnergyService.h"

#define kGAPServiceID @"1800"
//TODO: refactor this to somewhere else. These should be in somewhere else once we have different protocol.
//TODO: need a better design: separate operation and property

NSString * const TAProtocolKeyCommand                   =   @"TAProtocolKeyCommand";
NSString * const TAProtocolKeyTargetSystem              =   @"TAProtocolKeyTargetSystem";
NSString * const TAProtocolKeyValue                     =   @"TAProtocolKeyValue";
NSString * const TAProtocolKeyCompleteBlock             =   @"TAProtocolKeyCompleteBlock";
NSString * const TAProtocolKeyError                     =   @"TAProtocolKeyError";
NSString * const TAProtocolKeyState                     =   @"TAProtocolKeyState";
NSString * const TAProtocolKeySuccess                   =   @"TAProtocolKeySuccess";
NSString * const TAProtocolKeyIdentifier                =   @"TAProtocolKeyIdentifier";
NSString * const TAProtocolPropertyType                 =   @"TAProtocolPropertyType";

NSString * const TAProtocolReadSoftwareVersion          =   @"TAProtocolReadSoftwareVersion";
NSString * const TAProtocolReadBatteryLevel             =   @"TAProtocolReadBatteryLevel";
NSString * const TAProtocolSubscribeBatteryStatus       =   @"TAProtocolSubscribeBatteryStatus";
NSString * const TAProtocolUnsubscribeBatteryStatus     =   @"TAProtocolUnsubscribeBatteryStatus";
NSString * const TAProtocolReadEqualizer                =   @"TAProtocolReadEqualizer";
NSString * const TAProtocolWriteEqualizer               =   @"TAProtocolWriteEqualizer";
NSString * const TAProtocolReadVolume                   =   @"TAProtocolReadVolume";
NSString * const TAProtocolWriteVolume                  =   @"TAProtocolWriteVolume";
NSString * const TAProtocolWriteVolumeUp                =   @"TAProtocolWriteVolumeUp";
NSString * const TAProtocolWriteVolumeDown              =   @"TAProtocolWriteVolumeDown";

NSString * const TAProtocolEventDidUpdateState          =   @"TAProtocolEventDidUpdateState";
NSString * const TAProtocolEventDidUpdateValue          =   @"TAProtocolEventDidUpdateValue";
NSString * const TAProtocolEventDidWriteValue           =   @"TAProtocolEventDidWriteValue";
NSString * const TAProtocolEventDidUpdateNotification   =   @"TAProtocolEventDidUpdateNotification";
NSString * const TAProtocolEventDidDiscoverSystem       =   @"TAProtocolEventDidDiscoverSystem";
NSString * const TAProtocolEventDidConnectSystem        =   @"TAProtocolEventDidConnectSystem";
NSString * const TAProtocolEventDidDisconnectSystem     =   @"TAProtocolEventDidDisconnectSystem";

NSString * const TAProtocolErrorDomainService           =   @"TAProtocolErrorDomainService";

@interface TABluetoothLowEnergyCentral() <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) NSMutableArray *discoveredPeripherals;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property TABluetoothLowEnergyCentralScanMode scanMode;
@property TABluetoothLowEnergyCentralConnectMode connectMode;

@property (strong, nonatomic) NSDictionary *serviceInfo;
@property (strong, nonatomic) CBService* targetService;

@property (strong, nonatomic) TAOperationQueue *operationQueue;
@property (strong, nonatomic) TAOperation *currentOperation;

@property (strong, nonatomic) id<TACommand> currentCommand;

@property BOOL notificationEnabled;

//counting how many services are ready to be read/write
@property NSInteger readyServicesCount;


@end


@implementation TABluetoothLowEnergyCentral

- (NSArray*)services
{
    return [[TABluetoothLowEnergyDefaults sharedDefaults] serviceUuids];
}

/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)startScan
{
    [self.centralManager scanForPeripheralsWithServices:[self services] options:nil];
    NSLog(@"Scanning started");
}

- (void)stopScan
{
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    //Clean up for the possible next scan
    [self.discoveredPeripherals removeAllObjects];
}


- (id) initWithDelegate:(id<TABluetoothLowEnergyCentralDelegate>)delegate serviceInfo:(NSDictionary*)serviceInfo scanMode:(TABluetoothLowEnergyCentralScanMode)scanMode connectMode:(TABluetoothLowEnergyCentralConnectMode)connectMode
{
    self.delegate = delegate;
    self.tpServiceUuid = TP_SERVICE;
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    if(serviceInfo)
    {
        [[TABluetoothLowEnergyDefaults sharedDefaults] createDefault:serviceInfo];
        self.serviceInfo = serviceInfo;
    }else{
        self.serviceInfo = [[TABluetoothLowEnergyDefaults sharedDefaults] serviceInfo];
    }
    
    self.scanMode = scanMode;
    self.connectMode = connectMode;

    //no notification by default
    self.notificationEnabled = NO;
    
    self.discoveredPeripherals = [[NSMutableArray alloc] init];
    self.operationQueue = [[TAOperationQueue alloc] init];
    //suspend it first
    [self.operationQueue suspend];
    
    return self;
}

- (id) initWithDelegate:(id<TABluetoothLowEnergyCentralDelegate>)delegate
{
    NSDictionary* serviceInfo = [[TABluetoothLowEnergyDefaults sharedDefaults] serviceInfo];
    
    self = [self initWithDelegate:delegate serviceInfo:serviceInfo scanMode:TABluetoothLowEnergyCentralScanModeManual connectMode:TABluetoothLowEnergyCentralConnectModeManual];
    return self;
}

- (void)connectDevice:(CBPeripheral *)device
{
    [self.centralManager connectPeripheral:device options:nil];
}

- (void) disconnectDevice:(CBPeripheral *)device
{
    // Don't do anything if we're not connected
    if (device.state == CBPeripheralStateDisconnected)
    {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (device.services != nil) {
        for (CBService *service in device.services)
        {
            if (service.characteristics != nil)
            {
                for (CBCharacteristic *characteristic in service.characteristics)
                {
                    if (characteristic.isNotifying)
                    {
                        // It is notifying, so unsubscribe
                        [device setNotifyValue:NO forCharacteristic:characteristic];
                        
                        // And we're done.
                        //return;
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:device];
}

- (void)subscribeCharacteristic:(TABluetoothLowEnergyCharacteristicType)type
{
    //[self subscribeCharacteristic:type device:nil];
}

- (void)subscribeCharacteristic:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral
{
    // we loop through the array, just in case.
    NSString *idString = characteristicId;
    NSString *serviceId = [[TABluetoothLowEnergyDefaults sharedDefaults] serviceUuidFromCharacteristicUuid:idString];
    NSLog(@"idString, %@",idString);
    
    CBService* service = [TABluetoothLowEnergyCentral serviceWithPeripheral:targetPeripheral uuidString:serviceId];
    
    if(service)
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            // And check if it's the right one
            NSLog(@"characteristic.uuid = %@", characteristic.UUID.UUIDString);
            if ([characteristic.UUID.UUIDString isEqualToString:idString])
            {
                // If it is, subscribe to it
                
                if(targetPeripheral)
                {
                    [targetPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                    
                    NSLog(@"Subscribe %@ to %@ %@", characteristic.UUID, targetPeripheral.name, targetPeripheral.identifier.UUIDString);
                    
                    break;
                    
                }else{
                    
                    NSArray* connected = [self connectedPeripherals];
                    
                    for(CBPeripheral* peripheral in connected)
                    {
                        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                        
                        NSLog(@"Subscribe %@ to %@ %@", characteristic.UUID, peripheral.name, peripheral.identifier.UUIDString);
                    }
                }
            }
        }
    }
}

- (void)unsubscribeCharacteristic:(TABluetoothLowEnergyCharacteristicType)type
{
    //[self unsubscribeCharacteristic:type device:nil];
}

- (void)unsubscribeCharacteristic:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral
{
    
    NSString *idString = characteristicId;
    NSString *serviceId = [[TABluetoothLowEnergyDefaults sharedDefaults] serviceUuidFromCharacteristicUuid:idString];

    // we loop through the array, just in case.
    CBService* service = [TABluetoothLowEnergyCentral serviceWithPeripheral:targetPeripheral uuidString:serviceId];
    
    if(service)
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            // And check if it's the right one
            if ([characteristic.UUID.UUIDString isEqualToString:idString])
            {
                // If it is, subscribe to it
                
                if(targetPeripheral)
                {
                    [targetPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                    
                    NSLog(@"Unsubscribe %@ to %@ %@", characteristic.UUID, targetPeripheral.name, targetPeripheral.identifier.UUIDString);
                    
                }else{
                    
                    NSArray* connected = [self connectedPeripherals];
                    
                    for(CBPeripheral* peripheral in connected)
                    {
                        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                        
                        NSLog(@"Unsubscribe %@ to %@ %@", characteristic.UUID, peripheral.name, peripheral.identifier.UUIDString);
                    }
                }
            }
        }        
    }
}

- (void) writeData:(NSData*)data forCharacteristic:(TABluetoothLowEnergyCharacteristicType)type
{
    //[self writeData:data forCharacteristic:type device:nil];
}

- (void) writeData:(NSData*)data characteristicId:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral
{
    NSString *uuidString = characteristicId;
    NSString *serviceId = [[TABluetoothLowEnergyDefaults sharedDefaults] serviceUuidFromCharacteristicUuid:uuidString];
    
    CBService* service = [TABluetoothLowEnergyCentral serviceWithPeripheral:targetPeripheral uuidString:serviceId];
    
    if(service)
    {
        // we loop through the array, just in case.
        if (service.characteristics == nil)
        {
            NSLog(@"characteristic is empty");
        }
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            // And check if it's the right one
            if ([characteristic.UUID.UUIDString isEqualToString:uuidString])
            {
                CBCharacteristicWriteType type = CBCharacteristicWriteWithoutResponse;
                
                if(characteristic.properties & CBCharacteristicPropertyWrite)
                {
                    type = CBCharacteristicWriteWithResponse;
                }
                
                if(targetPeripheral)
                {
                    //write to target peripheral
                    TAOperation* operation = [[TAOperation alloc] initWithDelegate:self methodInfo:@{@"method" : @"writeValue", @"peripheral" : targetPeripheral, @"data" : data, @"characteristic" : characteristic, @"type" : [NSNumber numberWithInteger:type]}];
                    
                    [self.operationQueue addOperation:operation];

                    
                }else{
                    
                    //TODO: We need further study on how we could send to 3 connected peripheral at a time
                    
                    //write to every peripherals if no target device
                    NSArray* connected = [self connectedPeripherals];
                    
                    for(CBPeripheral* peripheral in connected)
                    {
                        //[peripheral writeValue:data forCharacteristic:characteristic type:type];
                        
                        //NSLog(@"Write %@ to %@ %@", characteristic.UUID, peripheral.name, peripheral.identifier.UUIDString);
                        
                        TAOperation* operation = [[TAOperation alloc] initWithDelegate:self methodInfo:@{@"method" : @"writeValue", @"peripheral" : peripheral, @"data" : data, @"characteristic" : characteristic, @"type" : [NSNumber numberWithInteger:type]}];
                        
                        [self.operationQueue addOperation:operation];
                    }
                }
            }
        }
        
    }else{
        
        [self notifyNoSerivceForEvent:TAProtocolEventDidWriteValue commandType:[self.currentCommand type] peripheral:targetPeripheral];
    }
}

- (void)readDataForCharacteristic:(TABluetoothLowEnergyCharacteristicType)type
{
    //[self readDataForCharacteristic:type device:nil];
}

- (void)readDataForCharacteristic:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral
{
    NSString *uuidString = characteristicId;
    NSString *serviceId = [[TABluetoothLowEnergyDefaults sharedDefaults] serviceUuidFromCharacteristicUuid:uuidString];
    
    if(targetPeripheral)
    {
        //if a target periperhal
        CBService* service = [TABluetoothLowEnergyCentral serviceWithPeripheral:targetPeripheral uuidString:serviceId];
        
        if(service)
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                if ([characteristic.UUID.UUIDString isEqualToString:uuidString])
                {
                    //[targetPeripheral readValueForCharacteristic:characteristic];
                    
                    TAOperation* operation = [[TAOperation alloc] initWithDelegate:self methodInfo:@{@"method" : @"read", @"peripheral" : targetPeripheral, @"characteristic" : characteristic}];
                    
                    [self.operationQueue addOperation:operation];
                }
            }
            
        }else{
            
            //special case: it's the GAP service hidden by iOS corebluetooth
            if([serviceId isEqualToString:kGAPServiceID])
            {
                //device name
                if([uuidString isEqualToString:@"2A00"])
                {
                    TAOperation* operation = [[TAOperation alloc] initWithDelegate:self methodInfo:@{@"method" : @"read", @"peripheral" : targetPeripheral, @"uuid" : uuidString}];
                    
                    [self.operationQueue addOperation:operation];
                    
                }
                
            }

            [self notifyNoSerivceForEvent:TAProtocolEventDidUpdateValue commandType:[self.currentCommand type] peripheral:targetPeripheral];
        }
        
    }else{
        
        //TODO: We need further testing on: if it works, how it works or even if it's feasible
        
        //read from every peripherals if no target device
        NSArray* connected = [self connectedPeripherals];
        
        for(CBPeripheral* peripheral in connected)
        {
            CBService* service = [TABluetoothLowEnergyCentral serviceWithPeripheral:peripheral uuidString:serviceId];
            
            if(service)
            {
                for (CBCharacteristic *characteristic in service.characteristics)
                {
                    if ([characteristic.UUID.UUIDString isEqualToString:uuidString])
                    {
                        TAOperation* operation = [[TAOperation alloc] initWithDelegate:self methodInfo:@{@"method" : @"read", @"peripheral" : peripheral, @"characteristic" : characteristic}];
                        
                        [self.operationQueue addOperation:operation];
                    }
                }
            }else{
               
                [self notifyNoSerivceForEvent:TAProtocolEventDidUpdateValue commandType:[self.currentCommand type] peripheral:targetPeripheral];
            }
        }
    }
}

- (void)cleanupDevice:(CBPeripheral*)peripheral
{
    //clean up those connected only
    if(peripheral.state == CBPeripheralStateConnected)
    {
        // See if we are subscribed to a characteristic on the peripheral
        if (peripheral.services != nil) {
            for (CBService *service in peripheral.services)
            {
                if (service.characteristics != nil)
                {
                    for (CBCharacteristic *characteristic in service.characteristics)
                    {
                        //TODO: actually, does this even work?
                        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:INTERESTED_SERVICE]]) {
                            if (characteristic.isNotifying)
                            {
                                // It is notifying, so unsubscribe
                                [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                                
                                // And we're done.
                                return;
                            }
                        }
                    }
                }
            }
        }
        
        // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
        [self.centralManager cancelPeripheralConnection:peripheral];
        
    }
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    TABluetoothLowEnergyCentralState state = TABluetoothLowEnergyCentralStateUnknown;

    switch(central.state)
    {
        case CBCentralManagerStatePoweredOn:

            state = TABluetoothLowEnergyCentralStatePowerOn;
            
            //Queue start operating
            [self.operationQueue restart];
            
            if(self.scanMode == TABluetoothLowEnergyCentralScanModeAuto)
            {
                [self startScan];
            }
            
            break;
            
        case CBCentralManagerStatePoweredOff:
            
            state = TABluetoothLowEnergyCentralStatePowerOff;

            //suspend the queue
            [self.operationQueue suspend];

            
            break;
            
        case CBCentralManagerStateResetting:
            
            break;
            
        case CBCentralManagerStateUnauthorized:
            
            break;
            
        case CBCentralManagerStateUnsupported:
            
            break;
            
            
        case CBCentralManagerStateUnknown:

            break;
            
        default:
            break;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidUpdateState:)])
    {
        [self.delegate bluetoothLowEnergyCentralDidUpdateState:state];
    }
}

/** This callback comes whenever a peripheral that is advertising the TYMRC_SERVICE_UUID is discovered.
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //[central cancelPeripheralConnection:peripheral]; // important, to clear off any pending connenctions
    
    BOOL discovered = [self isPeripheral:peripheral existAt:self.discoveredPeripherals];

    // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
    if(!discovered)
    {
        [self.discoveredPeripherals addObject:peripheral];
        
        //Connect if we are in auto connect mode
        if(self.connectMode == TABluetoothLowEnergyCentralConnectModeAuto)
        {
            NSLog(@"Connecting to peripheral %@", peripheral);
            [self.centralManager connectPeripheral:peripheral options:nil];
        }
        
        if(self.delegate  && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidDiscoverDevice:RSSI:)]){
            [self.delegate bluetoothLowEnergyCentralDidDiscoverDevice:peripheral RSSI:RSSI];
        }
    }
}

/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanupDevice:peripheral];
    
    //Notfiy delegate
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidFailToConnectDevice:error:)]){
        [self.delegate bluetoothLowEnergyCentralDidFailToConnectDevice:peripheral error:error];
    }
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    //Stop scanning if we are in auto scan mode
    if(self.scanMode == TABluetoothLowEnergyCentralScanModeAuto)
    {
        [self.centralManager stopScan];
        NSLog(@"Scanning stopped");
    }
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    NSLog(@"Discovered Service: %@", [peripheral.services description]);
    
    // Notifiy delegate
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidConnectToDevice:)]){
        [self.delegate bluetoothLowEnergyCentralDidConnectToDevice:peripheral];
    }
    
    //reset the counter
    self.readyServicesCount = 0;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:[self services]];
}

/** The tymphany rc Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"did discover tym rc service  on %@. ", peripheral);
    if (error)
    {
        NSLog(@"Error discovering services: %@ at device %@", [error localizedDescription], peripheral);
        [self cleanupDevice:peripheral];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidFailToConnectDevice:error:)])
        {
            [self.delegate bluetoothLowEnergyCentralDidFailToConnectDevice:peripheral error:error];
        }
        
        // [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
        return;
    }
    
    // Discover the characteristic we want...
    
    NSLog(@"Discovered Service: %@", [peripheral.services description]);
    
    for (CBService* service in peripheral.services)
    {
        if([[TABluetoothLowEnergyDefaults sharedDefaults] hasService:service])
        {
            [peripheral discoverCharacteristics:[[TABluetoothLowEnergyDefaults sharedDefaults] characteristicUuidsOfServiceUuid:service.UUID.UUIDString] forService:service];
        }
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"did discover tym rc characteristic  on %@. ", peripheral);
    
    if (error)
    {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);

        if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidFailToConnectDevice:error:)]){
            [self.delegate bluetoothLowEnergyCentralDidFailToConnectDevice:peripheral error:error];
        }
        
        [self cleanupDevice:peripheral];
        return;
    }
    
    // Again, we loop through the array, just in case.
    /*for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        //if ([characteristic.UUID isEqual:self.targetService.UUID]) {
            
            // If it is, subscribe to it
            //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
        //}
    }*/
    
    self.readyServicesCount++;
    
    //we got all of them ready. notify everyone
    if (self.readyServicesCount >= [peripheral.services count])
    {
        //Notify delegate
        if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidConnectDevice:didDiscoverCharacteristicsForService:)]){
            // Once this is complete, we just need to wait for the data to come in.
            [self.delegate bluetoothLowEnergyCentralDidConnectDevice:peripheral didDiscoverCharacteristicsForService:service.characteristics];
        }        
    }
}

/** This callback lets us know more data has arrived via notification or read operation on the characteristic
 */


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    NSLog(@"didUpdateValueForCharacteristic: characteristic.uuid = %@",characteristic.UUID);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:error:)]){
        [self.delegate bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:characteristic error:error];
    }
    
    [self.currentOperation finish];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didWriteValueForCharacteristic - %@", peripheral.name);
    
    if(error)
    {
        NSLog(@"Received error in writing: %@", [error localizedDescription]);
    }

    if(characteristic.properties & CBCharacteristicPropertyWrite)
    {
        //means it's write with response. we should have not finished the operation nor notify delegate. do it here
        [self.currentOperation finish];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)]){
            [self.delegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
        }
    }
}

/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateNotificationStateForCharacteristic char type %@", characteristic.UUID);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:error:)]){
        [self.delegate bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
    
    if (error)
    {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Notification has started
    if (characteristic.isNotifying)
    {
        NSLog(@"Notification start on %@", characteristic);
    }
    else
    {
        NSLog(@"Notification terminate on %@", characteristic);
    }
    
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");

    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidDisconnectPeripheral:error:)]){
        [self.delegate bluetoothLowEnergyCentralDidDisconnectPeripheral:peripheral error:error];
    }

    // We're disconnected, so start scanning again
    if(self.scanMode == TABluetoothLowEnergyCentralScanModeAuto)
    {
        [self startScan];
    }
}

#pragma mark - TAOperationDelegate method

- (void)execute:(TAOperation*)operation methodInfo:(NSDictionary*)methodInfo
{
    NSString* method = [methodInfo objectForKey:@"method"];
    
    if([method isEqualToString:@"writeValue"])
    {
        CBPeripheral* peripheral = [methodInfo objectForKey:@"peripheral"];
        CBCharacteristic* characteristic = [methodInfo objectForKey:@"characteristic"];
        CBCharacteristicWriteType type = [[methodInfo objectForKey:@"type"] integerValue];
        NSData* data = [methodInfo objectForKey:@"data"];
        
        self.currentOperation = operation; //queue responsible to control
        [peripheral writeValue:data forCharacteristic:characteristic type:type];
        
        NSLog(@"Write %@ %@ to %@ %@", characteristic.UUID, [data description], peripheral.name, peripheral.identifier.UUIDString);
        
        if(type == CBCharacteristicWriteWithoutResponse){
            
            [self.currentOperation finish];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)]){
                [self.delegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:nil];
            }
            
        }
        
    }else if([method isEqualToString:@"read"])
    {
        CBPeripheral* peripheral = [methodInfo objectForKey:@"peripheral"];
        CBCharacteristic* characteristic = [methodInfo objectForKey:@"characteristic"];
        CBCharacteristicWriteType type = [[methodInfo objectForKey:@"type"] integerValue];
        
        self.currentOperation = operation; //queue responsible to control
        
        //with target characteristic
        if(characteristic)
        {
            [peripheral readValueForCharacteristic:characteristic];
            
            NSLog(@"Read %@ from %@ %@", characteristic.UUID, peripheral.name, peripheral.identifier.UUIDString);
        }else{
            //without target characteristic
            
            NSString* uuid = [methodInfo objectForKey:@"uuid"];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:error:)]){
                
                NSData* name = [peripheral.name dataUsingEncoding:NSUTF8StringEncoding];
                
                CBMutableCharacteristic* characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:uuid] properties:CBCharacteristicPropertyRead value:name permissions:CBAttributePermissionsReadable];
                
                [self.delegate bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:characteristic error:nil];
            }
            
            [self.currentOperation finish];
        }
    }
}

#pragma mark - TAProtocol method

- (CBCentralManagerState)state
{
    return self.centralManager.state;
}

- (void)scan
{
    [self startScan];
}

- (void)connectSystem:(id)system
{
    [self connectDevice:system];
}

- (void)disconnectSystem:(id)system
{
    [self disconnectDevice:system];
}

- (void)execute:(id<TACommand>)command
{
    //cache the command as we will need to provide the command information on return the operation result
    self.currentCommand = command;
    
    [TABluetoothLowEnergyReceiver execute:command protocol:self];
}

- (void)enableNotification:(BOOL)enable
{
    //subclass with this property?
    self.notificationEnabled = enable;
}

#pragma mark - helper methods

//get service from peripheral, refactor it out to a util class?
+ (CBService*)serviceWithPeripheral:(CBPeripheral*)peripheral uuidString:(NSString*)uuidString
{
    
    for (CBService *service in peripheral.services) {
        
        //NSLog(@"Compare %@ %@",service.UUID.UUIDString, uuidString);
        
        //service.UUID.UUIDString always come with uppercase
        if ([service.UUID.UUIDString isEqualToString:[uuidString uppercaseString]])
        {
            return service;
        }
    }
    
    
    
    return nil;
}

- (NSArray*)connectedPeripherals
{
    return [self.centralManager retrieveConnectedPeripheralsWithServices:[self services]];
}

- (CBPeripheral*)retreivePeripheral:(NSString*)uuidString
{
    NSArray* array = [self.centralManager retrievePeripheralsWithIdentifiers:@[uuidString]];
    
    if([array count] >= 1)
    {
        return [array firstObject];
    }
    return nil;
}

//TODO: do we really need to compare the identifier or simply as object search which seems working well?
- (BOOL)isPeripheral:(CBPeripheral*)peripheral existAt:(NSArray*)peripherals
{
    for(CBPeripheral* discoveredPeripheral in peripherals)
    {
        if([discoveredPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString])
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)notifyNoSerivceForEvent:(NSString*)actionType commandType:(NSString*)commandType peripheral:(id)peripheral
{
    NSLog(@"No service discovered for peripheral %@", [peripheral name]);
    
    if(self.notificationEnabled)
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:actionType object:self userInfo:@{ TAProtocolKeyCommand : commandType, TAProtocolKeyTargetSystem : peripheral, TAProtocolKeyError : [NSError errorWithDomain:TAProtocolErrorDomainService code:TAProtocolErrorDomainServiceNotFound userInfo:nil]}];
    }
}


@end
