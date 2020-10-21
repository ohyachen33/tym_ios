//
//  SystemManager.h
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 16/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <TAPlatform/TAPPlayControlService.h>
#import <TAPlatform/TAPSystemService.h>
#import <TAPlatform/TAPSystem.h>

#import "TASystemSettings.h"

FOUNDATION_EXPORT NSString * const SystemValueDidUpdate;
FOUNDATION_EXPORT NSString * const SystemStateDidUpdate;
FOUNDATION_EXPORT NSString * const SystemDiscoveredNewSystem;
FOUNDATION_EXPORT NSString * const DidConnectedToSystem;
FOUNDATION_EXPORT NSString * const PowerStateDidUpdate;
FOUNDATION_EXPORT NSString * const PlayStateDidUpdate;


typedef NS_ENUM (NSInteger, SystemBLEState)
{
    SystemBLEStateScanning = 0,
    SystemBLEStateConnected,
    SystemBLEStateStopped,
    SystemBLEStateUnknown
};

@interface SystemManager : NSObject <TAPSystemServiceDelegate, TAPPlayControlServiceDelegate>

@property SystemBLEState state;

@property (nonatomic, strong) NSMutableArray* discoveredSystems;
@property (nonatomic, strong) TAPSystem* connectedSystem;
@property (nonatomic, strong) TASystemSettings* systemSettings;
@property (nonatomic, strong) NSDictionary* model;
@property (nonatomic, strong) NSString* type;
@property (strong, nonatomic) TAPSystemService *systemService;
@property (strong, nonatomic) TAPPlayControlService *playControlService;


+ (SystemManager *)sharedManager;
- (void)start;

@end
