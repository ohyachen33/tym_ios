//
//  TABluetoothLowEnergyDefaults.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 27/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TABluetoothLowEnergyDefaults.h"
#import "TABluetoothLowEnergyService.h"
#import "TABluetoothLowEnergyCentral.h"

#import "TADocumentUtils.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface TABluetoothLowEnergyDefaults()

@property (nonatomic,strong) NSDictionary* serviceInfo;

@end

#define kTymphanyServices @"TymphanyServices"

@implementation TABluetoothLowEnergyDefaults

+ (TABluetoothLowEnergyDefaults*)sharedDefaults
{
    static TABluetoothLowEnergyDefaults* sharedDefaults = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[TABluetoothLowEnergyDefaults alloc] init];
        
    });
    return sharedDefaults;
}

- (id)init
{
    if(self = [super init])
    {
        self.serviceInfo = [TADocumentUtils dictionaryFromResources:kTymphanyServices];
    }
    
    return self;
}

- (void)createDefault:(NSDictionary*)serviceInfo;
{
    
    self.serviceInfo = serviceInfo;
}

- (TABluetoothLowEnergyCharacteristicType)typeByCharacteristicId:(NSString*)characteristicId
{
    //TODO: tempt code for demo. make a mapping here.
    if([characteristicId isEqualToString:@"2A19"])
    {
        return TABluetoothLowEnergyCharacteristicTypeBatteryRead;
        
    }else if([characteristicId isEqualToString:@"2A26"])
    {
        return TABluetoothLowEnergyCharacteristicTypeSoftwareVersion;
        
    }else if([characteristicId isEqualToString:@"44FA50B2-D0A3-472E-A939-D80CF17638BB"])
    {
        return TABluetoothLowEnergyCharacteristicTypeVolumeControl;
        
    }
    
    return TABluetoothLowEnergyCharacteristicTypeSoftwareVersion;
}

- (NSString*)characteristicIdFromCommandType:(NSString*)commandType
{
    if([commandType isEqualToString:TAProtocolReadVolume]       ||
       [commandType isEqualToString:TAProtocolWriteVolume]      ||
       [commandType isEqualToString:TAProtocolWriteVolumeUp]    ||
       [commandType isEqualToString:TAProtocolWriteVolumeDown])
    {
        return @"44FA50B2-D0A3-472E-A939-D80CF17638BB";
        
    }else if([commandType isEqualToString:TAProtocolReadBatteryLevel] ||
             [commandType isEqualToString:TAProtocolSubscribeBatteryStatus] ||
             [commandType isEqualToString:TAProtocolUnsubscribeBatteryStatus] )
    {
        return @"2A19";
        
    }else if([commandType isEqualToString:TAProtocolReadSoftwareVersion])
    {
        return @"2A26";
        
    }
    
    return nil;
}

- (NSString*)commandTypeOfReadingFromCharacteristicId:(NSString*)characteristicId
{
    if([characteristicId isEqualToString:@"44FA50B2-D0A3-472E-A939-D80CF17638BB"])
    {
        return TAProtocolReadVolume;
        
    }else if([characteristicId isEqualToString:@"2A19"])
    {
        return TAProtocolReadBatteryLevel;
        
    }else if([characteristicId isEqualToString:@"2A26"])
    {
        return TAProtocolReadSoftwareVersion;
        
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

- (BOOL)hasService:(CBService*)service
{
    NSArray* services = [[self serviceInfo] objectForKey:@"services"];
    
    for(NSDictionary* serviceInfo in services)
    {
        if([[serviceInfo objectForKey:@"identifier"] isEqualToString:service.UUID.UUIDString])
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
