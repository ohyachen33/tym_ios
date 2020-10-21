//
//  TAPProtocol.h
//  TAPProtocol
//
//  Created by Lam Yick Hong on 26/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

//The target protocol key to be used for service-protocol communication
FOUNDATION_EXPORT NSString * const TAPProtocolKeyCommand;
FOUNDATION_EXPORT NSString * const TAPProtocolKeyTargetSystem;
FOUNDATION_EXPORT NSString * const TAPProtocolKeyValue;
FOUNDATION_EXPORT NSString * const TAPProtocolKeyCompleteBlock;
FOUNDATION_EXPORT NSString * const TAPProtocolKeyError;
FOUNDATION_EXPORT NSString * const TAPProtocolKeyState;
FOUNDATION_EXPORT NSString * const TAPProtocolKeySuccess;
FOUNDATION_EXPORT NSString * const TAPProtocolKeyIdentifier;
FOUNDATION_EXPORT NSString * const TAPProtocolPropertyType;

//The target protocol value to be used for service-protocol communication
FOUNDATION_EXPORT NSString * const TAPProtocolReadSoftwareVersion;
FOUNDATION_EXPORT NSString * const TAPProtocolReadBatteryLevel;
FOUNDATION_EXPORT NSString * const TAPProtocolSubscribeBatteryStatus;
FOUNDATION_EXPORT NSString * const TAPProtocolUnsubscribeBatteryStatus;
FOUNDATION_EXPORT NSString * const TAPProtocolReadEqualizer;
FOUNDATION_EXPORT NSString * const TAPProtocolWriteEqualizer;
FOUNDATION_EXPORT NSString * const TAPProtocolReadVolume;
FOUNDATION_EXPORT NSString * const TAPProtocolWriteVolume;
FOUNDATION_EXPORT NSString * const TAPProtocolWriteVolumeUp;
FOUNDATION_EXPORT NSString * const TAPProtocolWriteVolumeDown;

//The target protocol callback even to be used for service-protocol communication
FOUNDATION_EXPORT NSString * const TAPProtocolEventDidUpdateState;
FOUNDATION_EXPORT NSString * const TAPProtocolEventDidUpdateValue;
FOUNDATION_EXPORT NSString * const TAPProtocolEventDidWriteValue;
FOUNDATION_EXPORT NSString * const TAPProtocolEventDidUpdateNotification;
FOUNDATION_EXPORT NSString * const TAPProtocolEventDidDiscoverSystem;
FOUNDATION_EXPORT NSString * const TAPProtocolEventDidConnectSystem;
FOUNDATION_EXPORT NSString * const TAPProtocolEventDidDisconnectSystem;
FOUNDATION_EXPORT NSString * const TAPProtocolEventDidUpdateSystem;

@interface TAPProtocol : NSObject

@end

@protocol TACommand <NSObject>

@required

- (NSString*)type;
- (id)targetSystem;
- (void (^)(id, NSError*))completeBlock;

@property (nonatomic, strong)NSData* value;

@end

@protocol TAPProtocol <NSObject>

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

