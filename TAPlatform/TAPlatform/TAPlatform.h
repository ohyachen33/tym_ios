//
//  TAPlatform.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 26/8/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>

#if TARGET_OS_IOS
//! Project version number for TAPlatform.
FOUNDATION_EXPORT double TAPlatformVersionNumber;

//! Project version string for TAPlatform.
FOUNDATION_EXPORT const unsigned char TAPlatformVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TAPlatform/PublicHeader.h>

//Service Layer
#import <TAPlatform/TAPSystemService.h>
#import <TAPlatform/TAPPlayControlService.h>
#import <TAPlatform/TAPDigitalSignalProcessingService.h>
#import <TAPlatform/TAPFirmwareOverTheAirUpdateService.h>

//Protocol Layer
#import <TAPlatform/TAPBluetoothLowEnergyProxy.h>
#import <TAPlatform/TAPSystem.h>
#import <TAPlatform/TAPDocumentUtils.h>
#import <TAPlatform/TAPDataUtils.h>

#import <TAPlatform/TPSignal.h>

#elif TARGET_OS_TV

//! Project version number for TAPlatformTV.
FOUNDATION_EXPORT double TAPlatformTVVersionNumber;

//! Project version string for TAPlatformTV.
FOUNDATION_EXPORT const unsigned char TAPlatformTVVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TAPlatformTV/PublicHeader.h>

#import <TAPlatformTV/TAPSystemService.h>
#import <TAPlatformTV/TAPPlayControlService.h>
#import <TAPlatformTV/TAPDigitalSignalProcessingService.h>

//Protocol Layer
#import <TAPlatformTV/TAPBluetoothLowEnergyProxy.h>
#import <TAPlatformTV/TAPSystem.h>
#import <TAPlatformTV/TAPDocumentUtils.h>
#import <TAPlatformTV/TAPDataUtils.h>

#import <TAPlatformTV/TPSignal.h>

#endif
