//
//  TABluetoothLowEnergyProxy.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 29/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TABluetoothLowEnergyProxy.h"
#import "TABluetoothLowEnergyDefaults.h"
#import "TASystem.h"
#import "TADataUtils.h"

#define kMethodRead @"readDataForCharacteristic:device:"
#define kMethodWrite @"writeDataForCharacteristic:device:"

#define kTPBleDataLimit 20

@interface TABluetoothLowEnergyProxy()

@property (nonatomic, strong) TABluetoothLowEnergyCentral* bleCentral;
@property TABluetoothLowEnergyMode mode;

@property (strong, nonatomic) TAOperationQueue *operationQueue;
@property (strong, nonatomic) TAOperation *currentOperation;

@property (strong, nonatomic) TPSignal* signal;

@end

@implementation TABluetoothLowEnergyProxy

- (id)initWithConfig:(NSDictionary*)config
{
    if(self = [super init])
    {
        //TODO: grab all the config
        NSDictionary* serviceInfo = [config objectForKey:@"serviceInfo"];
        
        self.bleCentral = [[TABluetoothLowEnergyCentral alloc] initWithDelegate:self serviceInfo:serviceInfo scanMode:TABluetoothLowEnergyCentralConnectModeManual connectMode:TABluetoothLowEnergyCentralConnectModeManual];
        
        if([[serviceInfo objectForKey:@"mode"] isEqualToString:@"tp-signal"])
        {
            self.mode = TABluetoothLowEnergyModeTPSignal;
            
        }else if([[serviceInfo objectForKey:@"mode"] isEqualToString:@"standard"])
        {
            self.mode = TABluetoothLowEnergyModeStandard;
            
        }else{
            self.mode = TABluetoothLowEnergyModeUnknown;
        }
        
        
        //init other class members
        self.operationQueue = [[TAOperationQueue alloc] init];
        self.signal = [[TPSignal alloc] initWithDelegate:self];
        
        
        return self;
    }
    
    return nil;
}

- (TAProtocolState)state
{
    TAProtocolState state = TAProtocolStateUnknown;
    
    switch([self.bleCentral state])
    {
        case CBCentralManagerStatePoweredOn:
            
            state = TAProtocolStateReady;
            break;
            
        case CBCentralManagerStatePoweredOff:
            
            state = TAProtocolStateOff;
            break;
            
        case CBCentralManagerStateResetting:
            
            state = TAProtocolStateOff; //Should we need a specific protocol state for it?
            break;
            
        case CBCentralManagerStateUnauthorized:
            
            state = TAProtocolStateUnauthorized;
            break;
            
        case CBCentralManagerStateUnsupported:
            
            state = TAProtocolStateUnsupported;
            break;
            
        case CBCentralManagerStateUnknown:
            
            state = TAProtocolStateUnknown;
            break;
            
        default:
            break;
    }
    
    return state;
}

- (TADataFormat)dataFormat
{
    //currently, same as the TABluetoothLowEnergyMode
    return self.mode;
}

- (void)read:(TASystem*)system type:(TAPropertyType)type
{
    //TODO: check if system wrapping a CBPeripheral. If not, throw a CORRECT and DESIGNED exception
    
    if(self.mode == TABluetoothLowEnergyModeTPSignal)
    {
        NSData* data = nil;
        
        //TP Signal
        if(type == TAPropertyTypePresetName1 || type == TAPropertyTypePresetName2 || type == TAPropertyTypePresetName3)
        {
            TPSignalStringType stringType = TPSignalStringTypeUnknown;
            
            switch (type) {
                case TAPropertyTypePresetName1:
                {
                    stringType = TPSignalStringTypePreset1Name;
                }
                    break;
                case TAPropertyTypePresetName2:
                {
                    stringType = TPSignalStringTypePreset2Name;
                }
                    break;
                case TAPropertyTypePresetName3:
                {
                    stringType = TPSignalStringTypePreset3Name;
                }
                    break;
                    
                default:
                    break;
            }
            
            data = [self.signal stringReadSignalWithType:stringType];
            
        }else{
            
            data = [self.signal settingReadSignalWithType:TPSignalTypeVolumeSetting];
        }
        
        if(data)
        {
            [self writeTPSignal:data peripheral:system];
            
        }else{
            //not supported
        }
        
    }else if(self.mode == TABluetoothLowEnergyModeStandard){
     
        //common        
        NSString* uuid = [self uuidFromType:type];
        [self.bleCentral readDataForCharacteristic:uuid device:[system instance]];
        
    }else{
        //instantiated a not supported mode
        NSLog(@"Error: the specific BLE mode is incorrect and not supported");
        
        //TODO: throw exception?
    }
}


- (void)write:(TASystem*)system type:(TAPropertyType)type data:(id)data
{
    if(self.mode == TABluetoothLowEnergyModeTPSignal)
    {
        //TP Signal
        NSData* value = [TADataUtils reverse:data];
        NSData* signal;
        
        //TODO: make it an encoder class for each type to get rid of this switch case
        switch (type) {
            case TAPropertyTypeVolume:
            {
                
                NSString* inputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                if(inputString && [inputString isEqualToString:@"up"])
                {
                    Byte byte[4] = {0x05,0x00,0x00,0x00};
                    value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
                    signal = [self.signal keySignalWithKeyIdData:value type:TPSignalTypeKey];
                    
                }else if(inputString && [inputString isEqualToString:@"down"])
                {
                    Byte byte[4] = {0x04,0x00,0x00,0x00};
                    value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
                    signal = [self.signal keySignalWithKeyIdData:value type:TPSignalTypeKey];
                    
                }else{
                    
                    signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeVolumeSetting];
                }
            }
                break;
                
            case TAPropertyTypeLowPassOnOff:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeLPOnOffSetting];
            }
                break;
                
            case TAPropertyTypeLowPassFrequency:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeLowPassFrequencySetting];
            }
                break;
            case TAPropertyTypeLowPassSlope:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeLowPassSlopeSetting];
            }
                break;
            case TAPropertyTypeRGCOnOff:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeRGCOnOffSetting];
            }
                break;
            case TAPropertyTypeRGCFrequency:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeRGCFrequencySetting];
            }
                break;
            case TAPropertyTypeRGCSlope:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeRGCSlopeSetting];
            }
                break;
            case TAPropertyTypePhase:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypePhaseSetting];
            }
                break;
            case TAPropertyTypePolarity:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypePolaritySetting];
            }
                break;
            case TAPropertyTypeTunning:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeTunningSetting];
            }
                break;
            case TAPropertyTypeEQ1Boost:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeEQ1BoostSetting];
            }
                break;
            case TAPropertyTypeEQ1Frequency:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeEQ1FrequencySetting];
            }
                break;
            case TAPropertyTypeEQ1QFactor:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeEQ1QFactorSetting];
            }
                break;
            case TAPropertyTypeEQ2Boost:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeEQ2BoostSetting];
            }
                break;
            case TAPropertyTypeEQ2Frequency:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeEQ2FrequencySetting];
            }
                break;
            case TAPropertyTypeEQ2QFactor:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeEQ2QFactorSetting];
            }
                break;
            case TAPropertyTypeEQ3Boost:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeEQ3BoostSetting];
            }
                break;
            case TAPropertyTypeEQ3Frequency:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeEQ3FrequencySetting];
            }
                break;
            case TAPropertyTypeEQ3QFactor:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeEQ3QFactorSetting];
            }
                break;
            case TAPropertyTypePEQ1OnOff:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypePEQ1SaveLoadSetting];
            }
                break;
            case TAPropertyTypePEQ2OnOff:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypePEQ2SaveLoadSetting];
            }
                break;
            case TAPropertyTypePEQ3OnOff:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypePEQ3SaveLoadSetting];
            }
                break;
            case TAPropertyTypeDisplay:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeDisplaySetting];
            }
                break;
            case TAPropertyTypeStandby:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeStandbySetting];
            }
                break;
            case TAPropertyTypeTimeout:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeTimeoutSetting];
            }
                break;
            case TAPropertyTypePresetName1:
            {
                signal = [self.signal stringWriteSignalWithData:data type:TPSignalStringTypePreset1Name];
            }
                break;
            case TAPropertyTypePresetName2:
            {
                signal = [self.signal stringWriteSignalWithData:data type:TPSignalStringTypePreset2Name];
            }
                break;
            case TAPropertyTypePresetName3:
            {
                signal = [self.signal stringWriteSignalWithData:data type:TPSignalStringTypePreset3Name];
            }
                break;
            case TAPropertyTypePresetLoading:
            {
                NSString* presetId = (NSString*)data;
                
                NSData* value = nil;
                
                if([presetId isEqualToString:@"1"]){
                    
                    Byte byte[4] = {0x17,0x00,0x00,0x00};
                    value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
                    
                }else if([presetId isEqualToString:@"2"]){
                    
                    Byte byte[4] = {0x18,0x00,0x00,0x00};
                    value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
                    
                }else if([presetId isEqualToString:@"3"]){
                    
                    Byte byte[4] = {0x19,0x00,0x00,0x00};
                    value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
                    
                }
                
                signal = [self.signal keySignalWithKeyIdData:value type:TPSignalTypeKey];
            }
                break;
                
            case TAPropertyTypePresetSaving:
            {
                NSString* presetId = (NSString*)data;
                
                NSData* value = nil;
                
                if([presetId isEqualToString:@"1"]){
                    
                    Byte byte[4] = {0x1a,0x00,0x00,0x00};
                    value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
                    
                }else if([presetId isEqualToString:@"2"]){
                    
                    Byte byte[4] = {0x1b,0x00,0x00,0x00};
                    value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
                    
                }else if([presetId isEqualToString:@"3"]){
                    
                    Byte byte[4] = {0x1c,0x00,0x00,0x00};
                    value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
                    
                }
                
                signal = [self.signal keySignalWithKeyIdData:value type:TPSignalTypeKey];
            }
                break;
            case TAPropertyTypeFactoryReset:
            {
                Byte byte[4] = {0x22,0x00,0x00,0x00};
                value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
                
                signal = [self.signal keySignalWithKeyIdData:value type:TPSignalTypeKey];
            }
                
            default:
                break;
        }
        
        [self writeTPSignal:signal peripheral:system];
        
    }else if(self.mode == TABluetoothLowEnergyModeStandard)
    {
        //common
        NSString* uuid = [self uuidFromType:type];
        
        if(uuid)
        {
            [self.bleCentral writeData:data characteristicId:uuid device:[system instance]];
            
        }else{
         
            //cannot tranlates to a UUID, not supported property
            NSLog(@"Error: the specific property is incorrect and not supported");
        }
        
    }else{
        //instantiated a not supported mode
        NSLog(@"Error: the specific BLE mode is incorrect and not supported");
    }
    
    
}

- (void)subscribe:(TASystem*)system type:(TAPropertyType)type
{
    if(self.mode == TABluetoothLowEnergyModeTPSignal)
    {
        //TP Signal
        
    }else if(self.mode == TABluetoothLowEnergyModeStandard){
        
        //common
        NSString* uuid = [self uuidFromType:type];
        [self.bleCentral subscribeCharacteristic:uuid device:[system instance]];
        
    }else{
        //instantiated a not supported mode
        NSLog(@"Error: the specific BLE mode is incorrect and not supported");
    }
}

- (void)unsubscribe:(TASystem*)system type:(TAPropertyType)type
{
    if(self.mode == TABluetoothLowEnergyModeTPSignal)
    {
        //TP Signal
        //Nothing we need to do here
        
    }else if(self.mode == TABluetoothLowEnergyModeStandard){
        
        //common
        NSString* uuid = [self uuidFromType:type];
        [self.bleCentral unsubscribeCharacteristic:uuid device:[system instance]];
        
    }else{
        //instantiated a not supported mode
        NSLog(@"Error: the specific BLE mode is incorrect and not supported");
    }
}

- (void)startScan
{
    [self.bleCentral startScan];
}

- (void)stopScan
{
    [self.bleCentral stopScan];
}

- (void)connectSystem:(TASystem*)system
{
    [self.bleCentral connectDevice:[system instance]];
}

- (void)disconnectSystem:(TASystem*)system
{
    [self.bleCentral disconnectDevice:[system instance]];
}

- (NSError*)perform:(NSDictionary*)operationInfo
{
    NSString* operation = [operationInfo objectForKey:@"operation"];
    NSString* property = [operationInfo objectForKey:@"property"];
    TASystem* system = [operationInfo objectForKey:@"system"];
    
    if(!operation || !property || !system)
    {
        return [NSError errorWithDomain:TAProtocolErrorDomainService code:TAProtocolErrorDomainServiceInvalidOperation userInfo:operationInfo];
    }
    
    if([operation isEqualToString:@"read"] && [[system instance] isKindOfClass:[CBPeripheral class]])
    {
        if(self.mode != TABluetoothLowEnergyModeTPSignal)
        {
            //only support TP SIgnal for now
            return [NSError errorWithDomain:TAProtocolErrorDomainService code:TAProtocolErrorDomainServiceNotSupported userInfo:operationInfo];
        }
        
        TPSignalType startType = TPSignalTypeTotalNumber;
        int size = 0;
        
        if([property isEqualToString:@"eq-all"])
        {
            startType = TPSignalTypeDisplaySetting;
            size = 50;
        }
        else if([property isEqualToString:@"settings-all"])
        {
            startType = TPSignalTypeDisplaySetting;
            size = 6;
        }

        
        //TP Signal. Definitely need to update the type if the setting table first item has changed.
        NSData* signal = [self.signal settingReadSignalWithType:startType size:size];

        [self writeTPSignal:signal peripheral:system];
        
        
    }else{
        
        return [NSError errorWithDomain:TAProtocolErrorDomainService code:TAProtocolErrorDomainServiceNotSupported userInfo:operationInfo];
    }
    
    return nil;
}

#pragma mark - TABluetoothLowEnergyCentralDelegate method

- (void)bluetoothLowEnergyCentralDidUpdateState:(TABluetoothLowEnergyCentralState)state
{
    //Notify System Service
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithInteger:[self state]] forKey:TAProtocolKeyState];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAProtocolEventDidUpdateState object:self userInfo:userInfo];
}

- (void) bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(self.mode == TABluetoothLowEnergyModeTPSignal)
    {
        //TP Signal mode
        NSData* value = characteristic.value;
        
        NSLog(@"Value length %lu: %@", [value length] , [value description]);
        
        if (error)
        {
            NSLog(@"Received error in reading: %@", [error localizedDescription]);
        }

        //Need to parse before notify the service
        [self.signal parseTPSignalPacket:value];
        
    }else if(self.mode == TABluetoothLowEnergyModeStandard){
        
        //standard mode
        NSData* value = characteristic.value;
        
        NSString* uuid = [characteristic.UUID UUIDString];
        TAPropertyType type = [self typeFromUuid:uuid];

        [self postNotification:TAProtocolEventDidUpdateValue type:type uuid:uuid value:value error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    TASystem* system = [[TASystem alloc] initWithSystem:peripheral];
    
    NSData* data = characteristic.value;
    
    NSDictionary* value;
    //No value case. Dummy value to avoid crashing
    if(!data)
    {
        value = [NSDictionary dictionary];
    }else{
        value = @{@"value" : data};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAProtocolEventDidWriteValue object:self userInfo:@{ TAProtocolKeyCommand : TAProtocolWriteVolume, TAProtocolKeyTargetSystem : system, TAProtocolKeyValue : value}];
}

- (void) bluetoothLowEnergyCentralDidDiscoverDevice:(CBPeripheral *)device RSSI:(NSNumber *)RSSI
{
    TASystem* system = [[TASystem alloc] initWithSystem:device];
    
    //Notify System Service. Should we do this in a delegate instead?
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:system forKey:TAProtocolKeyTargetSystem];
    [userInfo setObject:RSSI forKey:@"TAProtocolKeyRSSI"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAProtocolEventDidDiscoverSystem object:self userInfo:userInfo];
}

- (void)bluetoothLowEnergyCentralDidConnectDevice:(CBPeripheral *)device didDiscoverCharacteristicsForService:(NSArray *)characteristics
{
    
    if(self.mode == TABluetoothLowEnergyModeTPSignal)
    {
        //TP Signal mode - if this is TYM Service, we need to subscribe to it.
        
        for (CBService* service in device.services)
        {
            if([[service.UUID UUIDString] isEqualToString:[[TABluetoothLowEnergyDefaults sharedDefaults] uuidOfTpSignalService]])
            {
                //assume it always has one characteristic only
                CBCharacteristic* characteristic = [service.characteristics objectAtIndex:0];
                
                [device setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
    
    TASystem* system = [[TASystem alloc] initWithSystem:device];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:system forKey:TAProtocolKeyTargetSystem];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:TAProtocolKeySuccess];
    
    //TODO: may need to pass this error from the delegate method as well
    /*if(error)
    {
        [userInfo setObject:error forKey:TAProtocolKeyError];
    }*/
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAProtocolEventDidConnectSystem object:self userInfo:userInfo];
}

- (void) bluetoothLowEnergyCentralDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    TASystem* system = [[TASystem alloc] initWithSystem:peripheral];
    
    //Notify System Service. Should we do this in a delegate instead?
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:system forKey:TAProtocolKeyTargetSystem];
    if(error)
    {
        [userInfo setObject:error forKey:TAProtocolKeyError];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TAProtocolEventDidDisconnectSystem object:self userInfo:userInfo];
}

- (void) bluetoothLowEnergyCentralDidFailToConnectDevice:(CBPeripheral *)device error:(NSError *)error
{
    TASystem* system = [[TASystem alloc] initWithSystem:device];
    
    //Notify System Service. Should we do this in a delegate instead?
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:system forKey:TAProtocolKeyTargetSystem];
    [userInfo setObject:[NSNumber numberWithBool:NO] forKey:TAProtocolKeySuccess];
    
    if(error)
    {
        [userInfo setObject:error forKey:TAProtocolKeyError];
    }
    
    [userInfo setObject:device forKey:TAProtocolKeyTargetSystem];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAProtocolEventDidConnectSystem object:self userInfo:userInfo];
}

#pragma mark - TPSignalDelegate method

- (void) didReceiveMessageItem:(NSData*)item type:(TPSignalType)sneakType
{
    id value;
    TAPropertyType type = TAPropertyTypeUnknown;
    
    if(item)
    {
        if(self.mode == TABluetoothLowEnergyModeTPSignal)
        {
            if([item length] == 2)
            {
                value = item;
                
            }else if([item length] > 2){
                
                value = [TADataUtils arrayOfDataFrom:item length:2 count:[item length] / 2];
            }
            
            
        }else{
            
            value = item;
        }
    }

    type = [self.signal propertyTypeFromSignalType:sneakType];
    
    [self postNotification:TAProtocolEventDidUpdateValue type:type uuid:nil value:value error:nil];
    
}

#pragma mark - helper method

- (NSString*)uuidFromType:(TAPropertyType)type
{
    NSString* uuid = nil;
    
    switch (type) {
        case TAPropertyTypeVolume:
        {
            uuid = @"44FA50B2-D0A3-472E-A939-D80CF17638BB";
        }
            break;
        case TAPropertyTypeModelNumber:
        {
            uuid = @"2A24";
        }
            break;
        case TAPropertyTypeSerialNumber:
        {
            uuid = @"2A25";
        }
            break;
        case TAPropertyTypeDeviceName:
        {
            uuid = @"2A00";
        }
            break;
        case TAPropertyTypeSoftwareVersion:
        {
            uuid = @"2A26";
        }
            break;
        case TAPropertyTypeHardwareNumber:
        {
            uuid = @"2A27";
        }
            break;
        case TAPropertyTypeBattery:
        {
            uuid = @"2A19";
        }
            break;
            
        case TAPropertyTypePowerStatus:
        {
            uuid = @"7DD2F744-16C4-4C58-88A4-0FAFECC78343";
        }
            break;
            
        case TAPropertyTypePlaybackStatus:
        {
            uuid = @"4446CF5F-12F2-4C1E-AFE1-B15797535BA8";
        }
            break;
        case TAPropertyTypeTrueWireless:
        {
            uuid = @"D5B5E4C2-D2A7-4EEC-A2D0-6225033A4CAF";
        }
            break;
        case TAPropertyTypeTonescape:
        {
            uuid = @"D5B5E4C2-D2A7-4EEC-A2D0-6225033A4CAF";
        }
            
        default:
            break;
    }
    
    return uuid;
}

- (TAPropertyType)typeFromUuid:(NSString*)uuid
{
    TAPropertyType type = TAPropertyTypeUnknown;
    
    if([uuid isEqualToString:@"44FA50B2-D0A3-472E-A939-D80CF17638BB"])
    {
        type = TAPropertyTypeVolume;
        
    }else if([uuid isEqualToString:@"2A00"])
    {
        type = TAPropertyTypeDeviceName;
        
    }else if([uuid isEqualToString:@"2A24"])
    {
        type = TAPropertyTypeModelNumber;
        
    }else if([uuid isEqualToString:@"2A25"])
    {
        type = TAPropertyTypeSerialNumber;
        
    }else if([uuid isEqualToString:@"2A26"])
    {
        type = TAPropertyTypeSoftwareVersion;
        
    }else if([uuid isEqualToString:@"2A27"])
    {
        type = TAPropertyTypeHardwareNumber;
        
    }else if([uuid isEqualToString:@"2A19"])
    {
        type = TAPropertyTypeBattery;
        
    }else if([uuid isEqualToString:@"7DD2F744-16C4-4C58-88A4-0FAFECC78343"])
    {
        type = TAPropertyTypePowerStatus;
        
    }else if([uuid isEqualToString:@"4446CF5F-12F2-4C1E-AFE1-B15797535BA8"])
    {
        type = TAPropertyTypePlaybackStatus;
        
    }else if([uuid isEqualToString:@"D5B5E4C2-D2A7-4EEC-A2D0-6225033A4CAF"])
    {
        type = TAPropertyTypeTrueWireless;
        
    }else if([uuid isEqualToString:@"D5B5E4C2-D2A7-4EEC-A2D0-6225033A4CAF"])
    {
        type = TAPropertyTypeTonescape;
        
    }
    
    return type;
}

- (TPSignalType)signalTypeFromType:(TAPropertyType)type
{
    TPSignalType signalType = TPSignalTypeTotalNumber;
    
    switch (type) {
        case TAPropertyTypeVolume:
        {
            signalType = TPSignalTypeVolumeSetting;
        }
            break;
        case TAPropertyTypeSoftwareVersion:
        {
            //TODO: not supported yet
        }
            break;
        case TAPropertyTypeBattery:
        {
            //TODO: not supported yet
        }
            break;
            
        default:
            break;
    }
    
    return signalType;
}

- (void)writeTPSignal:(NSData*)data peripheral:(TASystem*)system
{
    NSString* tpSignalCharacteristic = @"2D73";
    
    NSInteger loc = 0;
    while (true) {
        
        if([data length] > loc + kTPBleDataLimit)
        {
            //The data is longer than limit
            NSData* segment = [data subdataWithRange:NSMakeRange(loc, kTPBleDataLimit)];
            [self.bleCentral writeData:segment characteristicId:tpSignalCharacteristic device:[system instance]];
            
            loc += kTPBleDataLimit;
            
        }else{
            
            //The data is equal or shorter than limit
            
            NSInteger length = [data length] - loc;
            
            NSData* segment = [data subdataWithRange:NSMakeRange(loc, length)];
            [self.bleCentral writeData:segment characteristicId:tpSignalCharacteristic device:[system instance]];
            
            //finished
            break;
        }
    }
}

- (BOOL)postNotification:(NSString*)notificationName type:(TAPropertyType)type uuid:(NSString*)uuid value:(id)value error:(NSError*)error
{

    //construct the user info
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    
    if(uuid){
        [userInfo setObject:uuid forKey:TAProtocolKeyIdentifier];
    }
    
    [userInfo setObject:[NSNumber numberWithInteger:type] forKey:TAProtocolPropertyType];
    
    if(value)
    {
        [userInfo setObject:@{@"value" : value} forKey:TAProtocolKeyValue];
    }
    
    if(error)
    {
        [userInfo setObject:error forKey:TAProtocolKeyError];
    }
    
    //notify the service
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
    
    return YES;
}

@end
