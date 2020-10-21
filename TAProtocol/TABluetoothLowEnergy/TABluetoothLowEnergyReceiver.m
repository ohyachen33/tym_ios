//
//  TABluetoothLowEnergyReceiver.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 9/4/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TABluetoothLowEnergyReceiver.h"
#import "TABluetoothLowEnergyCentral.h"
#import "TABluetoothLowEnergyDefaults.h"
#import "TPSignal.h"
#import "Crc16.h"

#define GET_MSB(x) (((x)>>8)&0xFF)
#define GET_LSB(x) ((x)&0xFF)

#define kTPBleDataLimit 20

@implementation TABluetoothLowEnergyReceiver

+ (void)execute:(id<TACommand>)command protocol:(TABluetoothLowEnergyCentral*)central
{
    CBPeripheral* peripheral = [command targetSystem];
    
    //check if the target system input is correct
    if(peripheral && ![peripheral isKindOfClass:[CBPeripheral class]])
    {
        //TODO: throw exception
        NSLog(@"only support CBPeripheral");
        return;
    }
    
    //check if TP Service exist
    CBService* tpService = [TABluetoothLowEnergyCentral serviceWithPeripheral:peripheral uuidString:central.tpServiceUuid];
    if(tpService)
    {
        [TABluetoothLowEnergyReceiver executeTPCommand:command protocol:central];
        
    }else{
        
        [TABluetoothLowEnergyReceiver executeCommand:command protocol:central];
    }
    
}

+ (void)executeCommand:(id<TACommand>)command protocol:(TABluetoothLowEnergyCentral*)central
{
    NSString* commandType = [command type];
    CBPeripheral* peripheral = [command targetSystem];
    NSData* value = command.value;
    NSString* characteristicId = [[TABluetoothLowEnergyDefaults sharedDefaults] characteristicIdFromCommandType:commandType];
    
    //TODO: determine the operation. going to refactor these if else. why we need TABluetooth type and TAProtocol command type?
    //Maybe we have to think about generate code to do those enum and event type mapping.
    if([commandType isEqualToString:TAProtocolReadSoftwareVersion])
    {
        [central readDataForCharacteristic:characteristicId device:peripheral];
        
    }else if([commandType isEqualToString:TAProtocolReadBatteryLevel])
    {
        [central readDataForCharacteristic:characteristicId device:peripheral];
        
    }else if([commandType isEqualToString:TAProtocolReadVolume])
    {
        [central readDataForCharacteristic:characteristicId device:peripheral];
        
    }else if([commandType isEqualToString:TAProtocolWriteVolume])
    {
        [central writeData:value characteristicId:characteristicId device:peripheral];
        
    }else if([commandType isEqualToString:TAProtocolWriteVolumeUp])
    {
        //TODO: real implementation
        [central writeData:[NSData data] characteristicId:characteristicId device:peripheral];
        
    }else if([commandType isEqualToString:TAProtocolWriteVolumeDown])
    {
        //TODO: real implementation
        [central writeData:[NSData data] characteristicId:characteristicId device:peripheral];
        
    }else if([commandType isEqualToString:TAProtocolSubscribeBatteryStatus])
    {
        [central subscribeCharacteristic:characteristicId device:peripheral];
        
    }else if([commandType isEqualToString:TAProtocolUnsubscribeBatteryStatus])
    {
        [central unsubscribeCharacteristic:characteristicId device:peripheral];
        
    }else{
        
        NSLog(@"Unsupported command");
    }
}

+ (void)executeTPCommand:(id<TACommand>)command protocol:(TABluetoothLowEnergyCentral*)central
{
    NSString* commandType = [command type];
    CBPeripheral* peripheral = [command targetSystem];
    NSData* data;
    
    TPSignal *tpSignal = [[TPSignal alloc] init];
    
    //TODO: construct the correct TP_SNEAK data
    if([commandType isEqualToString:TAProtocolReadSoftwareVersion])
    {
        data = [NSData data];
        
    }else if([commandType isEqualToString:TAProtocolReadBatteryLevel])
    {
        data = [NSData data];
        
    }else if([commandType isEqualToString:TAProtocolSubscribeBatteryStatus])
    {
        data = [NSData data];
        
    }else if([commandType isEqualToString:TAProtocolUnsubscribeBatteryStatus])
    {
        data = [NSData data];
        
    }else if([commandType isEqualToString:TAProtocolReadVolume])
    {
        data = [tpSignal settingReadSignalWithType:TPSignalTypeVolumeSetting];
        
    }else if([commandType isEqualToString:TAProtocolWriteVolume])
    {
        // button packet
        Byte byte[4] = {0x04,0x00,0x00,0x00};
        NSData *value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
        data = [tpSignal keySignalWithKeyIdData:value type:TPSignalTypeKey];
        
        //TODO: testing code. to be verified and finished with correct implementation
        //Byte byte[2] = {0x10, 0x00};
        //NSData *value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
        //data = [TPSignal settingWriteSignalWithData:value type:TPSignalTypeVolumeSetting];
        
    }else if([commandType isEqualToString:TAProtocolWriteVolumeUp])
    {
        // button packet
        Byte byte[4] = {0x05,0x00,0x00,0x00};
        NSData *value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
        data = [tpSignal keySignalWithKeyIdData:value type:TPSignalTypeKey];
        
    }else if([commandType isEqualToString:TAProtocolWriteVolumeDown])
    {
        // button packet
        Byte byte[4] = {0x04,0x00,0x00,0x00};
        NSData *value = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
        data = [tpSignal keySignalWithKeyIdData:value type:TPSignalTypeKey];
        
    }else{
        
        NSLog(@"Unsupported command");
    }
    
    [TABluetoothLowEnergyReceiver protocol:central writeTPSignal:data peripheral:peripheral];
}

+ (void)protocol:(TABluetoothLowEnergyCentral*)central writeTPSignal:(NSData*)data peripheral:(CBPeripheral*)peripheral
{
    NSString* tpSignalCharacteristic = @"2D73";
    
    NSInteger loc = 0;
    while (true) {
        
        if([data length] > loc + kTPBleDataLimit)
        {
            //The data is longer than limit
            NSData* segment = [data subdataWithRange:NSMakeRange(loc, kTPBleDataLimit)];
            [central writeData:segment characteristicId:tpSignalCharacteristic device:peripheral];
            
            loc += kTPBleDataLimit;
            
        }else{
            
            //The data is equal or shorter than limit
            
            NSInteger length = [data length] - loc;
            
            NSData* segment = [data subdataWithRange:NSMakeRange(loc, length)];
            [central writeData:segment characteristicId:tpSignalCharacteristic device:peripheral];
            
            //finished
            break;
        }        
    }
}

@end
