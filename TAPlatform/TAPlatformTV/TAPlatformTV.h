//
//  TAPlatformTV.h
//  TAPlatformTV
//
//  Created by Lam Yick Hong on 5/1/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for TAPlatformTV.
FOUNDATION_EXPORT double TAPlatformTVVersionNumber;

//! Project version string for TAPlatformTV.
FOUNDATION_EXPORT const unsigned char TAPlatformTVVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TAPlatformTV/PublicHeader.h>

#if TARGET_OS_IOS

//Service Layer
#import <TAPlatform/TAPSystemService.h>
#import <TAPlatform/TAPPlayControlService.h>
#import <TAPlatform/TAPDigitalSignalProcessingService.h>

//Protocol Layer
#import <TAPlatform/TAPBluetoothLowEnergyProxy.h>
#import <TAPlatform/TAPSystem.h>
#import <TAPlatform/TAPDocumentUtils.h>
#import <TAPlatform/TAPDataUtils.h>

#import <TAPlatform/TPSignal.h>

#elif TARGET_OS_TV

#import <TAPlatformTV/TAPSystemService.h>
#import <TAPlatformTV/TAPPlayControlService.h>
#import <TAPlatformTV/TAPDigitalSignalProcessingService.h>

//Protocol Layer
#import <TAPlatformTV/TAPBluetoothLowEnergyProxy.h>
#import <TAPlatformTV/TAPSystem.h>
#import <TAPlatformTV/TAPDocumentUtils.h>
#import <TAPlatformTV/TAPDataUtils.h>

#import <TAPlatformTV/TPSignal.h>
