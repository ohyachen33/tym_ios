//
//  TAPBluetoothLowEnergyCentral.m
//  TAPProtocol
//
//  Created by Lam Yick Hong on 7/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPError.h"
#import "TAPProtocol.h"
#import "TAPBluetoothLowEnergyCentral.h"
#import "TAPOperationQueue.h"
#import "TAPBluetoothLowEnergyDefaults.h"
#import "TAPBluetoothLowEnergyService.h"
#import "TAPBluetoothLowEnergyUtils.h"

#define kGAPServiceID @"1800"
//TODO: refactor this to somewhere else. These should be in somewhere else once we have different protocol.
//TODO: need a better design: separate operation and property

NSString * const TAPProtocolKeyCommand                   =   @"TAPProtocolKeyCommand";
NSString * const TAPProtocolKeyTargetSystem              =   @"TAPProtocolKeyTargetSystem";
NSString * const TAPProtocolKeyValue                     =   @"TAPProtocolKeyValue";
NSString * const TAPProtocolKeyCompleteBlock             =   @"TAPProtocolKeyCompleteBlock";
NSString * const TAPProtocolKeyError                     =   @"TAPProtocolKeyError";
NSString * const TAPProtocolKeyState                     =   @"TAPProtocolKeyState";
NSString * const TAPProtocolKeySuccess                   =   @"TAPProtocolKeySuccess";
NSString * const TAPProtocolKeyIdentifier                =   @"TAPProtocolKeyIdentifier";
NSString * const TAPProtocolPropertyType                 =   @"TAPProtocolPropertyType";

NSString * const TAPProtocolReadSoftwareVersion          =   @"TAPProtocolReadSoftwareVersion";
NSString * const TAPProtocolReadBatteryLevel             =   @"TAPProtocolReadBatteryLevel";
NSString * const TAPProtocolSubscribeBatteryStatus       =   @"TAPProtocolSubscribeBatteryStatus";
NSString * const TAPProtocolUnsubscribeBatteryStatus     =   @"TAPProtocolUnsubscribeBatteryStatus";
NSString * const TAPProtocolReadEqualizer                =   @"TAPProtocolReadEqualizer";
NSString * const TAPProtocolWriteEqualizer               =   @"TAPProtocolWriteEqualizer";
NSString * const TAPProtocolReadVolume                   =   @"TAPProtocolReadVolume";
NSString * const TAPProtocolWriteVolume                  =   @"TAPProtocolWriteVolume";
NSString * const TAPProtocolWriteVolumeUp                =   @"TAPProtocolWriteVolumeUp";
NSString * const TAPProtocolWriteVolumeDown              =   @"TAPProtocolWriteVolumeDown";

NSString * const TAPProtocolEventDidUpdateState          =   @"TAPProtocolEventDidUpdateState";
NSString * const TAPProtocolEventDidUpdateValue          =   @"TAPProtocolEventDidUpdateValue";
NSString * const TAPProtocolEventDidWriteValue           =   @"TAPProtocolEventDidWriteValue";
NSString * const TAPProtocolEventDidUpdateNotification   =   @"TAPProtocolEventDidUpdateNotification";
NSString * const TAPProtocolEventDidDiscoverSystem       =   @"TAPProtocolEventDidDiscoverSystem";
NSString * const TAPProtocolEventDidConnectSystem        =   @"TAPProtocolEventDidConnectSystem";
NSString * const TAPProtocolEventDidDisconnectSystem     =   @"TAPProtocolEventDidDisconnectSystem";
NSString * const TAPProtocolEventDidUpdateSystem         =   @"TAPProtocolEventDidUpdateSystem";

@interface TAPBluetoothLowEnergyCentral() <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) NSMutableArray *discoveredPeripherals;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property TAPBluetoothLowEnergyCentralScanMode scanMode;
@property TAPBluetoothLowEnergyCentralConnectMode connectMode;

@property (strong, nonatomic) NSDictionary *serviceInfo;
@property (strong, nonatomic) CBService* targetService;
@property (strong, nonatomic) CBPeripheral *targetPeripheral;

@property (strong, nonatomic) TAPOperationQueue *operationQueue;
@property (strong, nonatomic) TAPOperation *currentOperation;

@property (strong, nonatomic) id<TACommand> currentCommand;

@property BOOL notificationEnabled;

//counting how many services are ready to be read/write
@property NSInteger readyServicesCount;


@end


@implementation TAPBluetoothLowEnergyCentral

- (NSArray*)services
{
    return [[TAPBluetoothLowEnergyDefaults sharedDefaults] serviceUuids];
}

/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)startScanWithOptions:(NSDictionary*)options
{
    [self.centralManager scanForPeripheralsWithServices:[self services] options:options];
    DDLogInfo(@"Scanning started");
}

- (void)stopScan
{
    [self.centralManager stopScan];
    DDLogInfo(@"Scanning stopped");
    
    //Clean up for the possible next scan
    [self.discoveredPeripherals removeAllObjects];
}


- (id) initWithDelegate:(id<TAPBluetoothLowEnergyCentralDelegate>)delegate serviceInfo:(NSDictionary*)serviceInfo scanMode:(TAPBluetoothLowEnergyCentralScanMode)scanMode connectMode:(TAPBluetoothLowEnergyCentralConnectMode)connectMode
{
    self.delegate = delegate;
    self.tpServiceUuid = TP_SERVICE;
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    if(serviceInfo)
    {
        [[TAPBluetoothLowEnergyDefaults sharedDefaults] createDefault:serviceInfo];
        self.serviceInfo = serviceInfo;
    }else{
        self.serviceInfo = [[TAPBluetoothLowEnergyDefaults sharedDefaults] serviceInfo];
    }
    
    self.scanMode = scanMode;
    self.connectMode = connectMode;

    //no notification by default
    self.notificationEnabled = NO;
    
    self.discoveredPeripherals = [[NSMutableArray alloc] init];
    self.operationQueue = [[TAPOperationQueue alloc] init];
    //suspend it first
    [self.operationQueue suspend];
    
    return self;
}

- (id) initWithDelegate:(id<TAPBluetoothLowEnergyCentralDelegate>)delegate
{
    NSDictionary* serviceInfo = [[TAPBluetoothLowEnergyDefaults sharedDefaults] serviceInfo];
    
    self = [self initWithDelegate:delegate serviceInfo:serviceInfo scanMode:TAPBluetoothLowEnergyCentralScanModeManual connectMode:TAPBluetoothLowEnergyCentralConnectModeManual];
    return self;
}

- (void)connectDevice:(CBPeripheral *)device
{
    DDLogInfo(@"Connecting to peripheral %@", device);
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

- (void)subscribeCharacteristic:(TAPBluetoothLowEnergyCharacteristicType)type
{
    //[self subscribeCharacteristic:type device:nil];
}

- (void)subscribeCharacteristic:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral
{
    // we loop through the array, just in case.
    NSString *idString = characteristicId;
    NSString *serviceId = [[TAPBluetoothLowEnergyDefaults sharedDefaults] serviceUuidFromCharacteristicUuid:idString];
    DDLogDebug(@"idString, %@",idString);
    
    CBService* service = [TAPBluetoothLowEnergyCentral serviceWithPeripheral:targetPeripheral uuidString:serviceId];
    
    if(service)
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            NSString* characteristicUuid = [TAPBluetoothLowEnergyUtils stringOfUUID:characteristic.UUID];
            
            // And check if it's the right one
            DDLogDebug(@"characteristic.uuid = %@", characteristicUuid);
            if ([characteristicUuid isEqualToString:idString])
            {
                // If it is, subscribe to it
                
                if(targetPeripheral)
                {
                    TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : [NSNumber numberWithInteger:TAPBluetoothLowEnergyCentralOperationSubscribe], @"peripheral" : targetPeripheral, @"characteristic" : characteristic}];
                    
                    [self.operationQueue addOperation:operation];
                    
                    break;
                    
                }else{
                    
                    NSArray* connected = [self connectedPeripherals];
                    
                    for(CBPeripheral* peripheral in connected)
                    {
                        TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : [NSNumber numberWithInteger:TAPBluetoothLowEnergyCentralOperationSubscribe], @"peripheral" : peripheral, @"characteristic" : characteristic}];
                        
                        [self.operationQueue addOperation:operation];
                    }
                }
            }
        }
    }
}

- (void)unsubscribeCharacteristic:(TAPBluetoothLowEnergyCharacteristicType)type
{
    //[self unsubscribeCharacteristic:type device:nil];
}

- (void)unsubscribeCharacteristic:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral
{
    
    NSString *idString = characteristicId;
    NSString *serviceId = [[TAPBluetoothLowEnergyDefaults sharedDefaults] serviceUuidFromCharacteristicUuid:idString];

    // we loop through the array, just in case.
    CBService* service = [TAPBluetoothLowEnergyCentral serviceWithPeripheral:targetPeripheral uuidString:serviceId];
    
    if(service)
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            NSString* characteristicUuid = [TAPBluetoothLowEnergyUtils stringOfUUID:characteristic.UUID];
            
            // And check if it's the right one
            if ([characteristicUuid isEqualToString:idString])
            {
                // If it is, subscribe to it
                
                if(targetPeripheral)
                {
                    TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : [NSNumber numberWithInteger:TAPBluetoothLowEnergyCentralOperationUnsubscribe], @"peripheral" : targetPeripheral, @"characteristic" : characteristic}];
                    
                    [self.operationQueue addOperation:operation];

                    
                }else{
                    
                    NSArray* connected = [self connectedPeripherals];
                    
                    for(CBPeripheral* peripheral in connected)
                    {
                        TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : [NSNumber numberWithInteger:TAPBluetoothLowEnergyCentralOperationUnsubscribe], @"peripheral" : peripheral, @"characteristic" : characteristic}];
                        
                        [self.operationQueue addOperation:operation];
                    }
                }
            }
        }        
    }
}

- (void) writeData:(NSData*)data forCharacteristic:(TAPBluetoothLowEnergyCharacteristicType)type
{
    //[self writeData:data forCharacteristic:type device:nil];
}

- (void) writeData:(NSData*)data characteristicId:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral
{
    NSString *uuidString = characteristicId;
    NSString *serviceId = [[TAPBluetoothLowEnergyDefaults sharedDefaults] serviceUuidFromCharacteristicUuid:uuidString];
    
    CBService* service = [TAPBluetoothLowEnergyCentral serviceWithPeripheral:targetPeripheral uuidString:serviceId];
    
    if(service)
    {
        // we loop through the array, just in case.
        if (service.characteristics == nil)
        {
            DDLogVerbose(@"characteristic is empty");
        }
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            NSString* characteristicUuid = [TAPBluetoothLowEnergyUtils stringOfUUID:characteristic.UUID];
            
            // And check if it's the right one
            if ([characteristicUuid isEqualToString:uuidString])
            {
                CBCharacteristicWriteType type = CBCharacteristicWriteWithoutResponse;
                
                if(characteristic.properties & CBCharacteristicPropertyWrite)
                {
                    type = CBCharacteristicWriteWithResponse;
                }
                
                if(targetPeripheral)
                {
                    //write to target peripheral
                    TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : [NSNumber numberWithInteger:TAPBluetoothLowEnergyCentralOperationWrite], @"peripheral" : targetPeripheral, @"data" : data, @"characteristic" : characteristic, @"type" : [NSNumber numberWithInteger:type]}];
                    
                    [self.operationQueue addOperation:operation];

                    
                }else{
                    
                    //TODO: We need further study on how we could send to 3 connected peripheral at a time
                    
                    //write to every peripherals if no target device
                    NSArray* connected = [self connectedPeripherals];
                    
                    for(CBPeripheral* peripheral in connected)
                    {
                        //[peripheral writeValue:data forCharacteristic:characteristic type:type];
                        
                        //NSLog(@"Write %@ to %@ %@", characteristic.UUID, peripheral.name, peripheral.identifier.UUIDString);
                        
                        TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : [NSNumber numberWithInteger:TAPBluetoothLowEnergyCentralOperationWrite], @"peripheral" : peripheral, @"data" : data, @"characteristic" : characteristic, @"type" : [NSNumber numberWithInteger:type]}];
                        
                        [self.operationQueue addOperation:operation];
                    }
                }
            }
        }
        
    }else{
        
        [self notifyNoSerivceForEvent:TAPProtocolEventDidWriteValue commandType:[self.currentCommand type] peripheral:targetPeripheral];
    }
}

- (void)readDataForCharacteristic:(TAPBluetoothLowEnergyCharacteristicType)type
{
    //[self readDataForCharacteristic:type device:nil];
}

- (void)readDataForCharacteristic:(NSString*)characteristicId device:(CBPeripheral*)targetPeripheral
{
    NSString *uuidString = characteristicId;
    NSString *serviceId = [[TAPBluetoothLowEnergyDefaults sharedDefaults] serviceUuidFromCharacteristicUuid:uuidString];
    
    if(targetPeripheral)
    {
        //if a target periperhal
        CBService* service = [TAPBluetoothLowEnergyCentral serviceWithPeripheral:targetPeripheral uuidString:serviceId];
        
        if(service)
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                NSString* characteristicUuid = [TAPBluetoothLowEnergyUtils stringOfUUID:characteristic.UUID];
                
                if ([characteristicUuid isEqualToString:uuidString])
                {
                    //[targetPeripheral readValueForCharacteristic:characteristic];
                    
                    TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : [NSNumber numberWithInteger:TAPBluetoothLowEnergyCentralOperationRead], @"peripheral" : targetPeripheral, @"characteristic" : characteristic}];
                    
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
                    TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : [NSNumber numberWithInteger:TAPBluetoothLowEnergyCentralOperationRead], @"peripheral" : targetPeripheral, @"uuid" : uuidString}];
                    
                    [self.operationQueue addOperation:operation];
                    
                }
                
            }

            [self notifyNoSerivceForEvent:TAPProtocolEventDidUpdateValue commandType:[self.currentCommand type] peripheral:targetPeripheral];
        }
        
    }else{
        
        //TODO: We need further testing on: if it works, how it works or even if it's feasible
        
        //read from every peripherals if no target device
        NSArray* connected = [self connectedPeripherals];
        
        for(CBPeripheral* peripheral in connected)
        {
            CBService* service = [TAPBluetoothLowEnergyCentral serviceWithPeripheral:peripheral uuidString:serviceId];
            
            if(service)
            {
                for (CBCharacteristic *characteristic in service.characteristics)
                {
                    NSString* characteristicUuid = [TAPBluetoothLowEnergyUtils stringOfUUID:characteristic.UUID];
                    
                    if ([characteristicUuid isEqualToString:uuidString])
                    {
                        TAPOperation* operation = [[TAPOperation alloc] initWithDelegate:self methodInfo:@{@"method" : [NSNumber numberWithInteger:TAPBluetoothLowEnergyCentralOperationRead], @"peripheral" : peripheral, @"characteristic" : characteristic}];
                        
                        [self.operationQueue addOperation:operation];
                    }
                }
            }else{
               
                [self notifyNoSerivceForEvent:TAPProtocolEventDidUpdateValue commandType:[self.currentCommand type] peripheral:targetPeripheral];
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
    TAPBluetoothLowEnergyCentralState state = TAPBluetoothLowEnergyCentralStateUnknown;

    NSLog(@"BT state:%ld",state);

    
    switch(central.state)
    {
        case CBCentralManagerStatePoweredOn:

            //Queue start operating
            [self.operationQueue restart];
            
            if(self.scanMode == TAPBluetoothLowEnergyCentralScanModeAuto)
            {
                [self startScanWithOptions:nil];
            }
            
            state = TAPBluetoothLowEnergyCentralStatePowerOn;
            
            break;
            
        case CBCentralManagerStatePoweredOff:
        {

            //suspend the queue
            [self.operationQueue suspend];
            
            state = TAPBluetoothLowEnergyCentralStatePowerOff;
        }
            break;
            
        case CBCentralManagerStateResetting:
        {
            state = TAPBluetoothLowEnergyCentralStateResetting;
        }
            break;
            
        case CBCentralManagerStateUnauthorized:
        {
            state = TAPBluetoothLowEnergyCentralStateUnauthorized;
        }
            break;
            
        case CBCentralManagerStateUnsupported:
        {
            state = TAPBluetoothLowEnergyCentralStateUnsupported;
        }
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
        if(self.connectMode == TAPBluetoothLowEnergyCentralConnectModeAuto)
        {
            DDLogInfo(@"Connecting to peripheral %@", peripheral);
            [self.centralManager connectPeripheral:peripheral options:nil];
        }
    }
    
    if(self.delegate  && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidDiscoverDevice:RSSI:)]){
        [self.delegate bluetoothLowEnergyCentralDidDiscoverDevice:peripheral RSSI:RSSI];
    }
}

/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DDLogInfo(@"Peripheral:%@ (error=%@)", peripheral, [error localizedDescription]);
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
    DDLogInfo(@"Peripheral: %@", [peripheral description]);
    
    //Stop scanning if we are in auto scan mode
    if(self.scanMode == TAPBluetoothLowEnergyCentralScanModeAuto)
    {
        [self.centralManager stopScan];
        DDLogInfo(@"Scanning stopped");
    }
    
    self.targetPeripheral = peripheral;
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    DDLogInfo(@"Discovered Service: %@", [peripheral.services description]);
    
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
    DDLogDebug(@"did discover tym rc service  on %@. ", peripheral);
    if (error)
    {
        DDLogError(@"Error discovering services: %@ at device %@", [error localizedDescription], peripheral);
        [self cleanupDevice:peripheral];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidFailToConnectDevice:error:)])
        {
            [self.delegate bluetoothLowEnergyCentralDidFailToConnectDevice:peripheral error:error];
        }
        
        // [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
        return;
    }
    
    // Discover the characteristic we want...
    
    DDLogInfo(@"Discovered Service: %@", [peripheral.services description]);
    
    for (CBService* service in peripheral.services)
    {
        if([[TAPBluetoothLowEnergyDefaults sharedDefaults] hasService:service])
        {
            NSString* serviceUuid = [TAPBluetoothLowEnergyUtils stringOfUUID:service.UUID];
            
            [peripheral discoverCharacteristics:[[TAPBluetoothLowEnergyDefaults sharedDefaults] characteristicUuidsOfServiceUuid:serviceUuid] forService:service];
        }
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    DDLogDebug(@"did discover tym rc characteristic  on %@. ", peripheral);
    
    if (error)
    {
        DDLogError(@"Error discovering characteristics: %@", [error localizedDescription]);

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
    
    DDLogDebug(@"characteristic.uuid: %@",characteristic.UUID);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:error:)]&& peripheral == self.targetPeripheral){
        [self.delegate bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:characteristic error:error];
    }
    
    [self.currentOperation finish];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DDLogDebug(@"peripheral name: %@", peripheral.name);
    
    if(error)
    {
        DDLogError(@"Received error in writing: %@", [error localizedDescription]);
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
    DDLogDebug(@"char UUID: %@", characteristic.UUID);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:error:)]){
        [self.delegate bluetoothLowEnergyCentralDidUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
    
    if (error)
    {
        DDLogError(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Notification has started
    if (characteristic.isNotifying)
    {
        DDLogDebug(@"Notification start on %@", characteristic);
    }
    else
    {
        DDLogDebug(@"Notification terminate on %@", characteristic);
    }
    
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DDLogError(@"Peripheral Disconnected with Error: %@", [error description]);

    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidDisconnectPeripheral:error:)]){
        [self.delegate bluetoothLowEnergyCentralDidDisconnectPeripheral:peripheral error:error];
    }
    
    //flush all the cannot complete task
    [self.operationQueue flush];

    // We're disconnected, so start scanning again
    if(self.scanMode == TAPBluetoothLowEnergyCentralScanModeAuto)
    {
        [self startScanWithOptions:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict
{
    DDLogError(@"Will Restore with State: %@", [dict description]);
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    DDLogDebug(@"did update name  on %@. ", peripheral);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidUpdatePeripheral:)]){
        [self.delegate bluetoothLowEnergyCentralDidUpdatePeripheral:peripheral];
    }
}


#pragma mark - TAPOperationDelegate method

- (void)execute:(TAPOperation*)operation methodInfo:(NSDictionary*)methodInfo
{
    TAPBluetoothLowEnergyCentralOperation method = [[methodInfo objectForKey:@"method"] integerValue];
    
    CBPeripheral* peripheral = [methodInfo objectForKey:@"peripheral"];
    CBCharacteristic* characteristic = [methodInfo objectForKey:@"characteristic"];
    CBCharacteristicWriteType type = [[methodInfo objectForKey:@"type"] integerValue];
    NSData* data = [methodInfo objectForKey:@"data"];
    
    switch (method) {
            
        case TAPBluetoothLowEnergyCentralOperationWrite:
        {
            self.currentOperation = operation; //queue responsible to control
            
            if(characteristic)
            {
                [peripheral writeValue:data forCharacteristic:characteristic type:type];
                
                DDLogDebug(@"Write %@ %@ to %@ %@", characteristic.UUID, [data description], peripheral.name, peripheral.identifier.UUIDString);
                
                if(type == CBCharacteristicWriteWithoutResponse){
                    
                    [self.currentOperation finish];
                    
                    if(self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)]){
                        [self.delegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:nil];
                    }
                    
                }
                
            }else{
                
                DDLogDebug(@"Failed to write %@ to %@ %@ as not supported", [data description], peripheral.name, peripheral.identifier.UUIDString);
                
                NSError* error = [TAPError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeNotSupported userInfo:methodInfo];
                
                [self.currentOperation finish];
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)]){
                    [self.delegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
                }
                
            }
            
            
        }
            break;
            
        case TAPBluetoothLowEnergyCentralOperationRead:
        {
            self.currentOperation = operation; //queue responsible to control
            
            //with target characteristic
            if(characteristic)
            {
                [peripheral readValueForCharacteristic:characteristic];
                
                DDLogDebug(@"Read %@ from %@ %@", characteristic.UUID, peripheral.name, peripheral.identifier.UUIDString);
            }else{
                
                //without target characteristic
                
                //TODO: evaluate if we ever successfully read a value from this! otherwise, should simply do an error reporting
                if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:error:)]){
                    CBMutableCharacteristic* characteristic = nil;
                    
#if TARGET_OS_IOS
                    NSString* uuid = [methodInfo objectForKey:@"uuid"];
                    NSData* name = [peripheral.name dataUsingEncoding:NSUTF8StringEncoding];
                    
                    characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:uuid] properties:CBCharacteristicPropertyRead value:name permissions:CBAttributePermissionsReadable];
#endif
                    
                    [self.delegate bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:characteristic error:nil];
                }
                
                [self.currentOperation finish];
            }
        }
            break;
            
        case TAPBluetoothLowEnergyCentralOperationSubscribe:
        {
            self.currentOperation = operation; //queue responsible to control
        
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            [self.currentOperation finish];
        }
            break;
            
        case TAPBluetoothLowEnergyCentralOperationUnsubscribe:
        {
            self.currentOperation = operation; //queue responsible to control
            
            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
            
            [self.currentOperation finish];
        }
            break;
            
        default:
            break;
    }

}

#pragma mark - TAPProtocol method

- (CBCentralManagerState)state
{
    return self.centralManager.state;
}

- (void)scan
{
    [self startScanWithOptions:nil];
}

- (void)connectSystem:(id)system
{
    [self connectDevice:system];
}

- (void)disconnectSystem:(id)system
{
    [self disconnectDevice:system];
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
        
        NSString* serviceUuid = [TAPBluetoothLowEnergyUtils stringOfUUID:service.UUID];
        
        //always come with uppercase
        if ([serviceUuid isEqualToString:[uuidString uppercaseString]])
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
    NSArray* array = [self.centralManager retrievePeripheralsWithIdentifiers:@[[[NSUUID alloc] initWithUUIDString:uuidString]]];
    
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
    DDLogDebug(@"No service discovered for peripheral %@", [peripheral name]);
    
    if(self.notificationEnabled)
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:actionType object:self userInfo:@{ TAPProtocolKeyCommand : commandType, TAPProtocolKeyTargetSystem : peripheral, TAPProtocolKeyError : [NSError errorWithDomain:TAPProtocolErrorDomainService code:TAPProtocolErrorDomainServiceNotFound userInfo:nil]}];
    }
}


@end
