//
//  SystemManager.h
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 16/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS

#import <TAPlatform/TAPDigitalSignalProcessingService.h>
#import <TAPlatform/TAPPlayControlService.h>
#import <TAPlatform/TAPSystemService.h>
#import <TAPlatform/TAPSystem.h>
#import <TAPlatform/TAPFirmwareOverTheAirUpdateService.h>

#elif TARGET_OS_TV

#import <TAPlatformTV/TAPDigitalSignalProcessingService.h>
#import <TAPlatformTV/TAPPlayControlService.h>
#import <TAPlatformTV/TAPSystemService.h>
#import <TAPlatformTV/TAPSystem.h>

#endif

#import "TASystemSettings.h"

FOUNDATION_EXPORT NSString * const SystemValueDidUpdate;
FOUNDATION_EXPORT NSString * const SystemStateDidUpdate;
FOUNDATION_EXPORT NSString * const SystemDiscoveredNewSystem;

typedef NS_ENUM (NSInteger, SystemBLEState)
{
    SystemBLEStateScanning = 0,
    SystemBLEStateConnected,
    SystemBLEStateStopped,
    SystemBLEStateUnknown
};

@interface SystemManager : NSObject <TAPSystemServiceDelegate, TAPPlayControlServiceDelegate, TAPDigitalSignalProcessingServiceDelegate, TAPFirmwareOverTheAirUpdateServiceDelegate>

@property SystemBLEState state;

@property (nonatomic, strong)NSMutableArray* discoveredSystems;
@property (nonatomic, strong)TAPSystem* connectedSystem;
@property (nonatomic, strong)NSMutableArray* connectedSystems;

@property (nonatomic, strong)TASystemSettings* systemSettings;

@property (strong, nonatomic) TAPSystemService *systemService;
@property (strong, nonatomic) TAPPlayControlService *playControlService;
@property (strong, nonatomic) TAPDigitalSignalProcessingService *dspService;
@property (strong, nonatomic) TAPFirmwareOverTheAirUpdateService *otaService;
@property BOOL isDFUMode;


+ (SystemManager *)sharedManager;
- (void)start;

- (void)saveValueFrom:(NSDictionary*)dictionary type:(NSString*)type;

@end
