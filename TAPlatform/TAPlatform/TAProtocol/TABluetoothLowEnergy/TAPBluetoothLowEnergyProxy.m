//
//  TAPBluetoothLowEnergyProxy.m
//  TAPProtocol
//
//  Created by Lam Yick Hong on 29/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPBluetoothLowEnergyProxy.h"
#import "TAPBluetoothLowEnergyDefaults.h"
#import "TAPropertyFactory.h"
#import "TAPSystem.h"
#import "TAPError.h"
#import "TAPDataUtils.h"

#import "TPSignalConfig.h"

#import "TAPBluetoothLowEnergyUtils.h"

#define kMethodRead @"readDataForCharacteristic:device:"
#define kMethodWrite @"writeDataForCharacteristic:device:"

#define kTPBleDataLimit 20
#define kNumOfEQAllSettings 26 // this number suppose to be how much we should support

NSString * const TAPBluetoothLowEnergyModeTPSignalKey      =   @"tp-signal";
NSString * const TAPBluetoothLowEnergyModeStandardKey      =   @"standard";

@interface TAPBluetoothLowEnergyProxy()

@property (nonatomic, strong) TAPBluetoothLowEnergyCentral* bleCentral;
@property TAPBluetoothLowEnergyMode defaultMode; //generally, the Proxy object runs in this default mode. However, there are some exceptions that the Proxy object would run the method call in another mode even it's suppose to be this default mode.
@property TAPBluetoothLowEnergyMode lastMode; //when leave DFU mode, the Proxy object switch to last BLE mode.
@property (strong, nonatomic) TAPOperationQueue *operationQueue;
@property (strong, nonatomic) TAPOperation *currentOperation;

@property (strong, nonatomic) TPSignal* signal;

@end

@implementation TAPBluetoothLowEnergyProxy

- (id)initWithConfig:(NSDictionary*)config
{
    if(self = [super init])
    {
        [TAPLogger sharedLogger];
        
        NSDictionary* serviceInfo = [config objectForKey:@"serviceInfo"];
        
        self.bleCentral = [[TAPBluetoothLowEnergyCentral alloc] initWithDelegate:self serviceInfo:serviceInfo scanMode:TAPBluetoothLowEnergyCentralConnectModeManual connectMode:TAPBluetoothLowEnergyCentralConnectModeManual];
        
        if([[serviceInfo objectForKey:@"mode"] isEqualToString:TAPBluetoothLowEnergyModeTPSignalKey])
        {
            self.defaultMode = TAPBluetoothLowEnergyModeTPSignal;
            
        }else if([[serviceInfo objectForKey:@"mode"] isEqualToString:TAPBluetoothLowEnergyModeStandardKey])
        {
            self.defaultMode = TAPBluetoothLowEnergyModeStandard;
            
        }else{
            self.defaultMode = TAPBluetoothLowEnergyModeUnknown;
        }
        self.lastMode = self.defaultMode;
        
        //init other class members
        self.operationQueue = [[TAPOperationQueue alloc] init];
        self.signal = [[TPSignal alloc] initWithDelegate:self];
        
        
        return self;
    }
    
    return nil;
}

- (TAPProtocolState)state
{
    TAPProtocolState state = TAPProtocolStateUnknown;
    
    switch([self.bleCentral state])
    {
        case CBCentralManagerStatePoweredOn:
            
            state = TAPProtocolStateOn;
            break;
            
        case CBCentralManagerStatePoweredOff:
            
            state = TAPProtocolStateOff;
            break;
            
        case CBCentralManagerStateResetting:
            
            state = TAPProtocolStateOff; //Should we need a specific protocol state for it?
            break;
            
        case CBCentralManagerStateUnauthorized:
            
            state = TAPProtocolStateUnauthorized;
            break;
            
        case CBCentralManagerStateUnsupported:
            
            state = TAPProtocolStateUnsupported;
            break;
            
        case CBCentralManagerStateUnknown:
            
            state = TAPProtocolStateUnknown;
            break;
            
        default:
            break;
    }
    
    return state;
}

- (TAPDataFormat)dataFormat
{
    //currently, same as the TAPBluetoothLowEnergyMode
    return self.defaultMode;
}

- (void)isDFUMode:(BOOL)fire
{
    if (fire) {
        self.defaultMode = TAPBluetoothLowEnergyModeDFU;
    }else{
        self.defaultMode = self.lastMode;
    }
}

#pragma mark - TAProtocolAdaptor methods

- (void)read:(TAPSystem*)system type:(TAPropertyType)type
{
    [self checkInstanceOfSystem:system];
    
    if(self.defaultMode == TAPBluetoothLowEnergyModeTPSignal)
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
            
        }else if(type == TAPropertyTypeAvailableFeatures){
            
            data = [self.signal featuresReadSignal];
            
        }else if(type == TAPropertyTypeSoftwareVersion){
            
            data = [self.signal softwareVersionSignal];
            
        }else if (type == TAPropertyTypeProductName){
         
            data = [self.signal productNameSignal];
            
        }else if(type == TAPropertyTypeDFU){
            
            data = [self.signal enterDFUModeSignal];
            
        }else{
            
            data = [self.signal settingReadSignalWithType:TPSignalTypeVolumeSetting];
        }
        
        if(data)
        {
            [self writeTPSignal:data peripheral:system];
            
        }else{
            
            //not supported
            DDLogError(@"The specific property is incorrect and not supported");
            
            NSError* error = [TAPError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeNotSupported userInfo:@{ @"system" : system, @"data" : data }];
            
            [self bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:nil error:error];
        }
        
    }else if(self.defaultMode == TAPBluetoothLowEnergyModeStandard){
     
        //common        
        NSString* uuid = [self uuidFromType:type];
        
        if(uuid)
        {
            [self.bleCentral readDataForCharacteristic:uuid device:[system instance]];
            
        }else{
            
            //cannot tranlates to a UUID, not supported property
            DDLogError(@"The specific property is incorrect and not supported");
            
            NSError* error = [TAPError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeNotSupported userInfo:@{ @"system" : system}];
            
            [self bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:nil error:error];
        }
        
        
        
    }else{
        //instantiated a not supported mode
        DDLogError(@"The specific BLE mode is incorrect and not supported");
        
        //TODO: throw exception?
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The specific BLE mode is incorrect and not supported" userInfo:@{@"Error" : [self unsupportedErrorWithInfo:nil] }];
        
    }
}


- (void)write:(TAPSystem*)system type:(TAPropertyType)type data:(id)data
{
    [self checkInstanceOfSystem:system];
    
    TAPBluetoothLowEnergyMode dataMode = self.defaultMode;
    
    if(type == TAPropertyTypeDeviceName)
    {
        //Due to the device name in GAP service in iOS cannot be rewritten at Core Bluetooth, we need the BT module to do it for us. Even if the data mode is TPSignal, we talk to the Custom Device Name service, not the TP Service.
        dataMode = TAPBluetoothLowEnergyModeStandard;
    }
    
    
    if(dataMode == TAPBluetoothLowEnergyModeTPSignal || dataMode ==  TAPBluetoothLowEnergyModeDFU)
    {
        //TP Signal
        NSData* value = data;
        NSData* signal = nil;
        
        if(data && [data isKindOfClass:[NSData class]])
        {
            //TODO: examine if this step is really necessary
            value = [TAPDataUtils reverse:data];
        }
        
        //TODO: make it an encoder class for each type to get rid of this switch case
        switch (type) {
            case TAPropertyTypeVolume:
            {
                
                NSString* inputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                if(inputString && [inputString isEqualToString:@"up"])
                {
                    signal = [self.signal keySignalWithKeyIdData:[TPSignalConfig dataForVolumeUp] type:TPSignalTypeKey];
                    
                }else if(inputString && [inputString isEqualToString:@"down"])
                {
                    signal = [self.signal keySignalWithKeyIdData:[TPSignalConfig dataForVolumeDown] type:TPSignalTypeKey];
                    
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
            case TAPropertyTypeTuning:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeTuningSetting];
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
            case TAPropertyTypeBrightness:
            {
                signal = [self.signal settingWriteSignalWithData:value type:TPSignalTypeBrightnessSetting];
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
                    
                    value = [TPSignalConfig dataForLoadPresetOne];
                    
                }else if([presetId isEqualToString:@"2"]){

                    value = [TPSignalConfig dataForLoadPresetTwo];
                    
                }else if([presetId isEqualToString:@"3"]){
                    
                    value = [TPSignalConfig dataForLoadPresetThree];
                    
                }else if([presetId isEqualToString:@"4"]){
                    
                    value = [TPSignalConfig dataForLoadPresetDefault];
                    
                }
                
                signal = [self.signal keySignalWithKeyIdData:value type:TPSignalTypeKey];
            }
                break;
                
            case TAPropertyTypePresetSaving:
            {
                NSString* presetId = (NSString*)data;
                
                NSData* value = nil;
                
                if([presetId isEqualToString:@"1"]){
                    
                    value = [TPSignalConfig dataForSavePresetOne];
                    
                }else if([presetId isEqualToString:@"2"]){
                    
                    value = [TPSignalConfig dataForSavePresetTwo];
                    
                }else if([presetId isEqualToString:@"3"]){
                    
                    value = [TPSignalConfig dataForSavePresetThree];
                    
                }
                
                signal = [self.signal keySignalWithKeyIdData:value type:TPSignalTypeKey];
            }
                break;
            case TAPropertyTypeFactoryReset:
            {
                signal = [self.signal keySignalWithKeyIdData:[TPSignalConfig dataForFactoryReset] type:TPSignalTypeKey];
            }
                break;
            case TAPropertyTypeScreenOnOff:
            {
                data = [TPSignalConfig dataForToggleScreen];
                
                signal = [self.signal keySignalWithKeyIdData:data type:TPSignalTypeKey];
            }
                break;
            case TAPropertyTypeDisplayLock:
            {
                data = [TPSignalConfig dataForDisplayLock];
                
                signal = [self.signal keySignalWithKeyIdData:data type:TPSignalTypeKey];
            }
                break;
            case TAPropertyTypeBootloaderCommand:
            {
                signal = data;
            }
            default:
                break;
        }
        
        if(signal)
        {
            [self writeTPSignal:signal peripheral:system];
            
        }else{
            
            //not supported
            DDLogError(@"The specific property is incorrect and not supported");
            
            NSError* error = [TAPError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeNotSupported userInfo:@{ @"system" : system}];
            
            [self peripheral:[system instance] didWriteValueForCharacteristic:nil error:error];
        }
        
    }else if(dataMode == TAPBluetoothLowEnergyModeStandard)
    {
        //common
        NSString* uuid = [self uuidFromType:type];
        
        if(uuid)
        {
            [self.bleCentral writeData:data characteristicId:uuid device:[system instance]];
            
        }else{
         
            //cannot tranlates to a UUID, not supported property
            DDLogError(@"The specific property is incorrect and not supported");

            NSError* error = [TAPError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeNotSupported userInfo:@{ @"system" : system}];
            
            [self peripheral:[system instance] didWriteValueForCharacteristic:nil error:error];
            
        }
        
    }else{
        //instantiated a not supported mode
        DDLogError(@"The specific BLE mode is incorrect and not supported");
    }
    
    
}

- (void)reset:(TAPSystem*)system type:(TAPropertyType)type
{
    [self checkInstanceOfSystem:system];
    
    if(self.defaultMode == TAPBluetoothLowEnergyModeTPSignal)
    {
        TAProperty* property = [TAPropertyFactory createPropertyWithType:type];
        
        TPSignalType signalType = [property signalType];
        
        NSData* signal = [self.signal resetSignalWithType:signalType];
        
        if(signal)
        {
            [self writeTPSignal:signal peripheral:system];
            
        }else{
            
            //not supported
            DDLogError(@"The specific property is incorrect and not supported");
            
            NSError* error = [TAPError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeNotSupported userInfo:@{ @"system" : system}];
            
            [self peripheral:[system instance] didWriteValueForCharacteristic:nil error:error];
        }
        
    }else if(self.defaultMode == TAPBluetoothLowEnergyModeStandard){
        
        //common
        DDLogError(@"Reset not supported");
        
    }else{
        //instantiated a not supported mode
        DDLogError(@"The specific BLE mode is incorrect and not supported");
    }
    
}

- (void)subscribe:(TAPSystem*)system type:(TAPropertyType)type
{
    if(self.defaultMode == TAPBluetoothLowEnergyModeTPSignal)
    {
        //TP Signal
        
    }else if(self.defaultMode == TAPBluetoothLowEnergyModeStandard){
        
        //common
        NSString* uuid = [self uuidFromType:type];
        [self.bleCentral subscribeCharacteristic:uuid device:[system instance]];
        
    }else{
        //instantiated a not supported mode
        DDLogError(@"The specific BLE mode is incorrect and not supported");
    }
}

- (void)unsubscribe:(TAPSystem*)system type:(TAPropertyType)type
{
    [self checkInstanceOfSystem:system];
    
    if(self.defaultMode == TAPBluetoothLowEnergyModeTPSignal)
    {
        //TP Signal
        //Nothing we need to do here
        
    }else if(self.defaultMode == TAPBluetoothLowEnergyModeStandard){
        
        //common
        NSString* uuid = [self uuidFromType:type];
        [self.bleCentral unsubscribeCharacteristic:uuid device:[system instance]];
        
    }else{
        //instantiated a not supported mode
        DDLogError(@"The specific BLE mode is incorrect and not supported");
    }
}

- (void)startScanWithOptions:(NSDictionary*)options
{
    NSMutableDictionary *bleScanOptions = [NSMutableDictionary new];
    if ([options.allKeys containsObject:@"CBCentralManagerScanOptionAllowDuplicatesKey"]) {
        [bleScanOptions setValue:options[@"CBCentralManagerScanOptionAllowDuplicatesKey"] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
        }
    [self.bleCentral startScanWithOptions:bleScanOptions];
}


- (void)stopScan
{
    [self.bleCentral stopScan];
}

- (void)connectSystem:(TAPSystem*)system
{
    [self.bleCentral connectDevice:[system instance]];
}

- (void)disconnectSystem:(TAPSystem*)system
{
    [self.bleCentral disconnectDevice:[system instance]];
}

- (NSDictionary*)perform:(NSDictionary*)operationInfo
{
    NSString* operation = [operationInfo objectForKey:@"operation"];
    NSString* property = [operationInfo objectForKey:@"property"];
    TAPSystem* system = [operationInfo objectForKey:@"system"];
    
    if(!operation || !property)
    {
        return @{@"error" : [NSError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeInvalidOperation userInfo:operationInfo]};
    }
    
    if(system && [operation isEqualToString:@"read"] && [[system instance] isKindOfClass:[CBPeripheral class]])
    {
        if(self.defaultMode != TAPBluetoothLowEnergyModeTPSignal)
        {
            //only support TP SIgnal for now
            return @{@"error" : [NSError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeNotSupported userInfo:operationInfo]};
        }
        
        TPSignalType startType = TPSignalTypeTotalNumber;
        int size = 0;
        
        if([property isEqualToString:@"eq-all"])
        {
            startType = TPSignalTypeDisplaySetting;
            size = kNumOfEQAllSettings * 2;
        }
        else if([property isEqualToString:@"settings-all"])
        {
            startType = TPSignalTypeDisplaySetting;
            size = 6;
        }

        
        //TP Signal. Definitely need to update the type if the setting table first item has changed.
        NSData* signal = [self.signal settingReadSignalWithType:startType size:size];

        [self writeTPSignal:signal peripheral:system];
        
        
    }else if([operation isEqualToString:@"retreive"] && [property isEqualToString:@"systems"]){
        
        NSString* identifier = [operationInfo objectForKey:@"identifier"];
        
        CBPeripheral* device = [self.bleCentral retreivePeripheral:identifier];
        
        NSMutableArray* systems = [[NSMutableArray alloc] init];
        
        if(device)
        {
            TAPSystem* system = [[TAPSystem alloc] initWithSystem:device];
            
            [systems addObject:system];
        }
        
        return @{@"systems" : systems};
        
    }else{
        
        return @{@"error" : [self unsupportedErrorWithInfo:operationInfo]};
    }
    
    return nil;
}

#pragma mark - TAPBluetoothLowEnergyCentralDelegate method

- (void)bluetoothLowEnergyCentralDidUpdateState:(TAPBluetoothLowEnergyCentralState)state
{
    //Notify System Service
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithInteger:[self state]] forKey:TAPProtocolKeyState];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAPProtocolEventDidUpdateState object:self userInfo:userInfo];
}

- (void) bluetoothLowEnergyCentralDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
        if (self.defaultMode == TAPBluetoothLowEnergyModeDFU) {
            [self postNotification:TAPProtocolEventDidUpdateValue type:TAPropertyTypeBootloaderCommand uuid:nil value:characteristic.value error:error];

        }else if(self.defaultMode == TAPBluetoothLowEnergyModeTPSignal) {
            if(characteristic)
            {
                //TP Signal mode
                NSData* value = characteristic.value;
                
                DDLogDebug(@"Value length %lu: %@", (unsigned long)[value length] , [value description]);
                
                if (error)
                {
                    DDLogError(@"Received error in reading: %@", [error localizedDescription]);
                }
                
                //Need to parse before notify the service
                [self.signal parseTPSignalPacket:value];
                
            }else{
                
                //fail to read
                [self postNotification:TAPProtocolEventDidUpdateValue type:TAPropertyTypeUnknown uuid:nil value:nil error:error];
            }
            
        }else if(self.defaultMode == TAPBluetoothLowEnergyModeStandard) {
            
            if(characteristic)
            {
                //standard mode
                NSData* value = characteristic.value;
                
                NSString* uuid = [TAPBluetoothLowEnergyUtils stringOfUUID:characteristic.UUID];
                TAPropertyType type = [self typeFromUuid:uuid];
                
                [self postNotification:TAPProtocolEventDidUpdateValue type:type uuid:uuid value:value error:error];
                
            }else{
                
                //fail to read
                [self postNotification:TAPProtocolEventDidUpdateValue type:TAPropertyTypeUnknown uuid:nil value:nil error:error];
            }
        }

}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(self.defaultMode == TAPBluetoothLowEnergyModeTPSignal)
    {
        //TP Signal mode
        
        if(characteristic)
        {
            NSData* value = characteristic.value;
            
            NSString* uuid = [characteristic.UUID UUIDString];
            
            DDLogDebug(@"Value length %lu: %@", (unsigned long)[value length] , [value description]);
            
            if (error)
            {
                DDLogError(@"Received error in reading: %@", [error localizedDescription]);
            }
            
            //Need to parse before notify the service
            [self postNotification:TAPProtocolEventDidWriteValue type:TAPropertyTypeUnknown uuid:uuid value:value error:error];
            
        }else{
            
            //failed to write
            [self postNotification:TAPProtocolEventDidWriteValue type:TAPropertyTypeUnknown uuid:nil value:nil error:error];
        }
        
    }else if(self.defaultMode == TAPBluetoothLowEnergyModeStandard){
        
        //standard mode
        
        if(characteristic)
        {
            NSData* value = characteristic.value;
            
            NSString* uuid = [characteristic.UUID UUIDString];
            TAPropertyType type = [self typeFromUuid:uuid];
            
            [self postNotification:TAPProtocolEventDidWriteValue type:type uuid:uuid value:value error:error];
            
        }else{
            
            //failed to write
            [self postNotification:TAPProtocolEventDidWriteValue type:TAPropertyTypeUnknown uuid:nil value:nil error:error];
        }
        
    }

}

- (void) bluetoothLowEnergyCentralDidDiscoverDevice:(CBPeripheral *)device RSSI:(NSNumber *)RSSI
{
    TAPSystem* system = [[TAPSystem alloc] initWithSystem:device];
    
    //Notify System Service. Should we do this in a delegate instead?
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:system forKey:TAPProtocolKeyTargetSystem];
    [userInfo setObject:RSSI forKey:@"TAPProtocolKeyRSSI"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAPProtocolEventDidDiscoverSystem object:self userInfo:userInfo];
}

- (void)bluetoothLowEnergyCentralDidConnectDevice:(CBPeripheral *)device didDiscoverCharacteristicsForService:(NSArray *)characteristics
{
    
    if(self.defaultMode == TAPBluetoothLowEnergyModeTPSignal)
    {
        //TP Signal mode - if this is TYM Service, we need to subscribe to it.
        
        for (CBService* service in device.services)
        {
            if([[service.UUID UUIDString] isEqualToString:[[TAPBluetoothLowEnergyDefaults sharedDefaults] uuidOfTpSignalService]])
            {
                //assume it always has one characteristic only
                CBCharacteristic* characteristic = [service.characteristics objectAtIndex:0];
                
                [device setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }else if (self.defaultMode == TAPBluetoothLowEnergyModeStandard){
        for (CBService* service in device.services)
        {
            for (CBCharacteristic* characteristic in service.characteristics) {
                [device setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
    
    TAPSystem* system = [[TAPSystem alloc] initWithSystem:device];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:system forKey:TAPProtocolKeyTargetSystem];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:TAPProtocolKeySuccess];
    
    //TODO: may need to pass this error from the delegate method as well
    /*if(error)
    {
        [userInfo setObject:error forKey:TAPProtocolKeyError];
    }*/
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAPProtocolEventDidConnectSystem object:self userInfo:userInfo];
}

- (void) bluetoothLowEnergyCentralDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    TAPSystem* system = [[TAPSystem alloc] initWithSystem:peripheral];
    
    //Notify System Service. Should we do this in a delegate instead?
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:system forKey:TAPProtocolKeyTargetSystem];
    if(error)
    {
        [userInfo setObject:error forKey:TAPProtocolKeyError];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TAPProtocolEventDidDisconnectSystem object:self userInfo:userInfo];
}

- (void) bluetoothLowEnergyCentralDidFailToConnectDevice:(CBPeripheral *)device error:(NSError *)error
{
    TAPSystem* system = [[TAPSystem alloc] initWithSystem:device];
    
    //Notify System Service. Should we do this in a delegate instead?
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:system forKey:TAPProtocolKeyTargetSystem];
    [userInfo setObject:[NSNumber numberWithBool:NO] forKey:TAPProtocolKeySuccess];
    
    if(error)
    {
        [userInfo setObject:error forKey:TAPProtocolKeyError];
    }
    
    [userInfo setObject:device forKey:TAPProtocolKeyTargetSystem];
    [[NSNotificationCenter defaultCenter] postNotificationName:TAPProtocolEventDidConnectSystem object:self userInfo:userInfo];
}

- (void)bluetoothLowEnergyCentralDidUpdatePeripheral:(CBPeripheral *)peripheral
{
    TAPSystem* system = [[TAPSystem alloc] initWithSystem:peripheral];
    
    //Notify System Service. Should we do this in a delegate instead?
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:system forKey:TAPProtocolKeyTargetSystem];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAPProtocolEventDidUpdateSystem object:self userInfo:userInfo];
}

#pragma mark - TPSignalDelegate method

- (void) didReceiveMessageItem:(NSData*)item type:(TPSignalType)sneakType
{
    id value;
    TAPropertyType type = TAPropertyTypeUnknown;
    
    if(item)
    {
        if(self.defaultMode == TAPBluetoothLowEnergyModeTPSignal)
        {
            if([item length] == 2 || sneakType == TPSignalTypeProductName)
            {
                value = item;
                
            }else if([item length] > 2){
                
                if(sneakType == TPSignalTypeFeatureList)
                {
                    value = [TAPDataUtils arrayOfDataFrom:item length:1 count:[item length]];
                    
                }else if(sneakType == TPSignalTypeSoftwareVersion || sneakType == TPSignalTypeProductName || sneakType == TPSignalTypeDFU)
                {
                    value = item;
                    
                }else{
                    
                    value = [TAPDataUtils arrayOfDataFrom:item length:2 count:[item length] / 2];
                }
            }
            
            
        }else{
            
            value = item;
        }
    }

    type = [self.signal propertyTypeFromSignalType:sneakType];
    
    [self postNotification:TAPProtocolEventDidUpdateValue type:type uuid:nil value:value error:nil];
    
}

- (void) didReceiveStringItem:(NSString*)item type:(TPSignalStringType)stringType
{
    DDLogDebug(@"message: %@", item);
    
    TAPropertyType type = [self propertyTypeFromSignalStringType:stringType];
    
    [self postNotification:TAPProtocolEventDidUpdateValue type:type uuid:nil value:item error:nil];
}

- (void) didFailToParseItem:(NSData*)item error:(NSError*)error
{
    [self postNotification:TAPProtocolEventDidUpdateValue type:TAPropertyTypeUnknown  uuid:nil value:item error:error];
}

#pragma mark - helper method

- (NSString*)uuidFromType:(TAPropertyType)type
{
    NSString *uuid = nil;
    
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
            if(self.defaultMode == TAPBluetoothLowEnergyModeStandard)
            {
                uuid = @"2A00";
                
            }else if(self.defaultMode == TAPBluetoothLowEnergyModeTPSignal)
            {
                uuid = @"7691B78A-9015-4367-9B95-FC631C412CC6";
            }
            
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
            uuid = @"95C09F26-95A4-4597-A798-B8E408F5CA66";
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
        
    }else if([uuid isEqualToString:@"2A00"] || [uuid isEqualToString:@"7691B78A-9015-4367-9B95-FC631C412CC6"])
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
        
    }else if([uuid isEqualToString:@"95C09F26-95A4-4597-A798-B8E408F5CA66"])
    {
        type = TAPropertyTypeTonescape;
        
    }
    
    return type;
}

- (TAPropertyType)propertyTypeFromSignalStringType:(TPSignalStringType)stringType
{
    TAPropertyType type = TAPropertyTypeUnknown;
    
    switch (stringType) {
        case TPSignalStringTypePreset1Name:
        {
            type = TAPropertyTypePresetName1;
        }
            break;
        case TPSignalStringTypePreset2Name:
        {
            type = TAPropertyTypePresetName2;
        }
            break;
        case TPSignalStringTypePreset3Name:
        {
            type = TAPropertyTypePresetName3;
        }
            break;
            
        default:
            break;
    }
    return type;
}

- (void)writeTPSignal:(NSData*)data peripheral:(TAPSystem*)system
{
    NSString* tpSignalCharacteristic = [[TAPBluetoothLowEnergyDefaults sharedDefaults] uuidOfTpSignalServiceCharacteristic];
    
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
        [userInfo setObject:uuid forKey:TAPProtocolKeyIdentifier];
    }
    
    [userInfo setObject:[NSNumber numberWithInteger:type] forKey:TAPProtocolPropertyType];
    
    if(value)
    {
        [userInfo setObject:@{@"value" : value} forKey:TAPProtocolKeyValue];
    }
    
    if(error)
    {
        [userInfo setObject:error forKey:TAPProtocolKeyError];
    }
    
    //notify the service
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
    
    return YES;
}

- (void)checkInstanceOfSystem:(TAPSystem*)system
{
    if(!system)
    {
        DDLogError(@"Calling a non nullable method with a nil TASystem object");
        
    }else if(![[system instance] isKindOfClass:[CBPeripheral class]]){
        
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"TAPSystem is not wrapping a CBPeripheral" userInfo:@{@"Error" : [TAPError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeIncorrectType userInfo:@{@"object" : system}]}];
    }
    
    
    
}

- (NSError*)unsupportedErrorWithInfo:(NSDictionary*)info
{
    //only support TP SIgnal for now
    return [NSError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeNotSupported userInfo:info];
}

@end
