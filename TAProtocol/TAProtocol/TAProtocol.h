//
//  TAProtocol.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 26/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

//The target protocol key to be used for service-protocol communication
FOUNDATION_EXPORT NSString * const TAProtocolKeyCommand;
FOUNDATION_EXPORT NSString * const TAProtocolKeyTargetSystem;
FOUNDATION_EXPORT NSString * const TAProtocolKeyValue;
FOUNDATION_EXPORT NSString * const TAProtocolKeyCompleteBlock;
FOUNDATION_EXPORT NSString * const TAProtocolKeyError;
FOUNDATION_EXPORT NSString * const TAProtocolKeyState;
FOUNDATION_EXPORT NSString * const TAProtocolKeySuccess;
FOUNDATION_EXPORT NSString * const TAProtocolKeyIdentifier;
FOUNDATION_EXPORT NSString * const TAProtocolPropertyType;

//The target protocol value to be used for service-protocol communication
FOUNDATION_EXPORT NSString * const TAProtocolReadSoftwareVersion;
FOUNDATION_EXPORT NSString * const TAProtocolReadBatteryLevel;
FOUNDATION_EXPORT NSString * const TAProtocolSubscribeBatteryStatus;
FOUNDATION_EXPORT NSString * const TAProtocolUnsubscribeBatteryStatus;
FOUNDATION_EXPORT NSString * const TAProtocolReadEqualizer;
FOUNDATION_EXPORT NSString * const TAProtocolWriteEqualizer;
FOUNDATION_EXPORT NSString * const TAProtocolReadVolume;
FOUNDATION_EXPORT NSString * const TAProtocolWriteVolume;
FOUNDATION_EXPORT NSString * const TAProtocolWriteVolumeUp;
FOUNDATION_EXPORT NSString * const TAProtocolWriteVolumeDown;

//The target protocol callback even to be used for service-protocol communication
FOUNDATION_EXPORT NSString * const TAProtocolEventDidUpdateState;
FOUNDATION_EXPORT NSString * const TAProtocolEventDidUpdateValue;
FOUNDATION_EXPORT NSString * const TAProtocolEventDidWriteValue;
FOUNDATION_EXPORT NSString * const TAProtocolEventDidUpdateNotification;
FOUNDATION_EXPORT NSString * const TAProtocolEventDidDiscoverSystem;
FOUNDATION_EXPORT NSString * const TAProtocolEventDidConnectSystem;
FOUNDATION_EXPORT NSString * const TAProtocolEventDidDisconnectSystem;

FOUNDATION_EXPORT NSString * const TAProtocolErrorDomainService;
FOUNDATION_EXPORT NSString * const TAProtocolErrorDomainProtocol;

@interface TAProtocol : NSObject

@end

@protocol TACommand <NSObject>

@required

- (NSString*)type;
- (id)targetSystem;
- (void (^)(id, NSError*))completeBlock;

@property (nonatomic, strong)NSData* value;

@end

@protocol TAProtocol <NSObject>

@required

/*!
 *  @method scan:
 *
 *  @brief	Start scan for system
 */
- (void)scan;

/*!
 *  @method execute:
 *  @param info An info dictionary that encapsulate all information that the protocol will need to understand how to operate
 *
 *  @brief	This method is providing a one-function-for-all-features interface.
 */
- (void)execute:(id<TACommand>)command;

//TODO: how this should be done? This property can be set by 2 different services and the setting can be contradicting to each others. We may need another mechanism to enable notification when it's necessary
- (void)enableNotification:(BOOL)enable;

@optional

/*!
 *  @method connectSystem:
 *
 *  @param system   The target system
 *
 *  @brief Connects to target system
 *
 */
- (void)connectSystem:(id)system;

/*!
 *  @method disconnectSystem:
 *
 *  @param system   The target system
 *
 *  @brief Disconnects to target system
 *
 */
- (void)disconnectSystem:(id)system;

@end

