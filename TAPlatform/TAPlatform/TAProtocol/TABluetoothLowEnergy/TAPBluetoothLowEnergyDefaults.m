//
//  TAPBluetoothLowEnergyDefaults.m
//  TAPProtocol
//
//  Created by Lam Yick Hong on 27/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPBluetoothLowEnergyDefaults.h"
#import "TAPBluetoothLowEnergyService.h"
#import "TAPBluetoothLowEnergyCentral.h"

#import "TAPBluetoothLowEnergyUtils.h"

#import "TAPDocumentUtils.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface TAPBluetoothLowEnergyDefaults()

@property (nonatomic,strong) NSDictionary* serviceInfo;

@end

#define kTymphanyServices @"TymphanyServices"

@implementation TAPBluetoothLowEnergyDefaults

+ (TAPBluetoothLowEnergyDefaults*)sharedDefaults
{
    static TAPBluetoothLowEnergyDefaults* sharedDefaults = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[TAPBluetoothLowEnergyDefaults alloc] init];
        
    });
    return sharedDefaults;
}

- (id)init
{
    if(self = [super init])
    {
        self.serviceInfo = [TAPDocumentUtils dictionaryFromResources:kTymphanyServices];
    }
    
    return self;
}

- (void)createDefault:(NSDictionary*)serviceInfo;
{
    
    self.serviceInfo = serviceInfo;
}

- (TAPBluetoothLowEnergyCharacteristicType)typeByCharacteristicId:(NSString*)characteristicId
{
    //TODO: tempt code for demo. make a mapping here.
    if([characteristicId isEqualToString:@"2A19"])
    {
        return TAPBluetoothLowEnergyCharacteristicTypeBatteryRead;
        
    }else if([characteristicId isEqualToString:@"2A26"])
    {
        return TAPBluetoothLowEnergyCharacteristicTypeSoftwareVersion;
        
    }else if([characteristicId isEqualToString:@"44FA50B2-D0A3-472E-A939-D80CF17638BB"])
    {
        return TAPBluetoothLowEnergyCharacteristicTypeVolumeControl;
        
    }
    
    return TAPBluetoothLowEnergyCharacteristicTypeSoftwareVersion;
}

- (NSString*)characteristicIdFromCommandType:(NSString*)commandType
{
    if([commandType isEqualToString:TAPProtocolReadVolume]       ||
       [commandType isEqualToString:TAPProtocolWriteVolume]      ||
       [commandType isEqualToString:TAPProtocolWriteVolumeUp]    ||
       [commandType isEqualToString:TAPProtocolWriteVolumeDown])
    {
        return @"44FA50B2-D0A3-472E-A939-D80CF17638BB";
        
    }else if([commandType isEqualToString:TAPProtocolReadBatteryLevel] ||
             [commandType isEqualToString:TAPProtocolSubscribeBatteryStatus] ||
             [commandType isEqualToString:TAPProtocolUnsubscribeBatteryStatus] )
    {
        return @"2A19";
        
    }else if([commandType isEqualToString:TAPProtocolReadSoftwareVersion])
    {
        return @"2A26";
        
    }
    
    return nil;
}

- (NSString*)commandTypeOfReadingFromCharacteristicId:(NSString*)characteristicId
{
    if([characteristicId isEqualToString:@"44FA50B2-D0A3-472E-A939-D80CF17638BB"])
    {
        return TAPProtocolReadVolume;
        
    }else if([characteristicId isEqualToString:@"2A19"])
    {
        return TAPProtocolReadBatteryLevel;
        
    }else if([characteristicId isEqualToString:@"2A26"])
    {
        return TAPProtocolReadSoftwareVersion;
        
    }
    
    return nil;
}


- (NSArray*)serviceUuids
{
    NSArray* services = [[self serviceInfo] objectForKey:@"services"];
    NSMutableArray* servicesIds = [[NSMutableArray alloc] init];
    
    for(NSDictionary* service in services)
    {
        //validate the identifier is correct UUID. for 128 bit UUID, string should be in 8-4-4-4-12 format
        CBUUID* uuid = [CBUUID UUIDWithString:[service objectForKey:@"identifier"]];
        if(uuid)
        {
            [servicesIds addObject:uuid];
            
        }else{
            
            //error. wrong uuid?
        }
        
    }
    
    return servicesIds;
}

- (NSArray*)characteristicUuidsOfServiceUuid:(NSString*)uuid
{
    return [self characteristicUuidOfServiceWithIdentifier:uuid];
}

- (NSString*)serviceUuidFromCharacteristicUuid:(NSString*)characteristicId
{
    NSArray* services = [[self serviceInfo] objectForKey:@"services"];
    
    for(NSDictionary* service in services)
    {
        for(NSString* characteristicUuid in [service objectForKey:@"characteristic"])
        {
            if([characteristicUuid isEqualToString:characteristicId])
            {
                return [service objectForKey:@"identifier"];
            }
        }
    }
    
    return nil;
}

- (NSString*)uuidOfTpSignalService
{
    NSArray* services = [[self serviceInfo] objectForKey:@"services"];
    
    for(NSDictionary* service in services)
    {
        NSString* mode = [service objectForKey:@"mode"];
        
        if(mode && [mode isEqualToString:@"TPSignal"])
        {
            return [service objectForKey:@"identifier"];
        }
    }
    
    return nil;
}

- (NSString*)uuidOfTpSignalServiceCharacteristic
{
    NSArray* services = [[self serviceInfo] objectForKey:@"services"];
    
    for(NSDictionary* service in services)
    {
        NSString* mode = [service objectForKey:@"mode"];
        
        if(mode && [mode isEqualToString:@"TPSignal"])
        {
            NSArray* characteristic = [service objectForKey:@"characteristic"];
            
            return [characteristic firstObject];
        }
    }
    
    return nil;
}

- (BOOL)hasService:(CBService*)service
{
    NSArray* services = [[self serviceInfo] objectForKey:@"services"];
    
    for(NSDictionary* serviceInfo in services)
    {
        NSString* serviceUuid = [TAPBluetoothLowEnergyUtils stringOfUUID:service.UUID];
        
        if([[serviceInfo objectForKey:@"identifier"] isEqualToString:serviceUuid])
        {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - helper method

- (NSArray*)characteristicUuidOfServiceWithIdentifier:(NSString*)uuidString
{
    NSArray* services = [[self serviceInfo] objectForKey:@"services"];
    NSMutableArray* characteristics = [[NSMutableArray alloc] init];
    
    NSArray* characteristicIdentifiers = nil;
    
    for(NSDictionary* service in services)
    {
        NSString* identifier = [service objectForKey:@"identifier"];
        if([identifier isEqualToString:uuidString])
        {
            characteristicIdentifiers = [service objectForKey:@"characteristic"];
            break;
        }
    }
    
    for(NSString* characteriscticIdentifier in characteristicIdentifiers)
    {
        [characteristics addObject:[CBUUID UUIDWithString:characteriscticIdentifier]];
    }
    
    return characteristics;
}

@end
