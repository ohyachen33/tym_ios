//
//  TAPPlayControlService.h
//  TAPPlayControlService
//
//  Created by Lam Yick Hong on 23/4/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPService.h"

enum{
    TAPPlayControlServicePlayStatusPlay = 0,
    TAPPlayControlServicePlayStatusPause,
    TAPPlayControlServicePlayStatusStopped,
    TAPPlayControlServicePlayStatusUnknown
};

typedef NSInteger TAPPlayControlServicePlayStatus;


enum{
    TAPPlayControlServiceAudioSourceNoSource = 0,
    TAPPlayControlServiceAudioSourceAuxIn,
    TAPPlayControlServiceAudioSourceUSB,
    TAPPlayControlServiceAudioSourceBluetooth,
    TAPPlayControlServiceAudioSourceUnknown
};

typedef NSInteger TAPPlayControlServiceAudioSource;

enum{
    TAPPlayControlServiceANCStatusOff = 0,
    TAPPlayControlServiceANCStatusOn,
    TAPPlayControlServiceANCStatusUnknown
};

typedef NSInteger TAPPlayControlServiceANCStatus;


enum{
    TAPPlayControlServiceTrueWirelessStatusDisconnected = 0,
    TAPPlayControlServiceTrueWirelessStatusReconnecting,
    TAPPlayControlServiceTrueWirelessStatusPairingMaster,
    TAPPlayControlServiceTrueWirelessStatusPairingSlave,
    TAPPlayControlServiceTrueWirelessStatusConnectedMaster,
    TAPPlayControlServiceTrueWirelessStatusConnectedSlave,
    TAPPlayControlServiceTrueWirelessStatusUnknown
};

typedef NSInteger TAPPlayControlServiceTrueWirelessStatus;

enum{
    TAPPlayControlServiceTrueWirelessCommandDisconnect = 0,
    TAPPlayControlServiceTrueWirelessCommandPairingMaster,
    TAPPlayControlServiceTrueWirelessCommandPairingSlave,
    TAPPlayControlServiceTrueWirelessCommandUnknown
};

typedef NSInteger TAPPlayControlServiceTrueWirelessCommand;


@protocol TAPPlayControlServiceDelegate;

/*!
 *  @warning This is a prelimenary document. The TAP libraries and interfaces are under development and will have heavy changes along.
 *
 *  @interface TAPPlayControlService
 *  @brief     TAP Service for controlling the audio play back. Any basic playback control will be provided here.
 *  @author    Hong Lam
 *  @date      23/4/15
 *  @copyright Tymphany Ltd.
 *
 *  @discussion {@link TAPPlayControlService} objects are used to control the audio playback on the systems, including play, pause, next track, previous track, volume control and current playback info.
 *
 *  You should implement the {@link TAPPlayControlServiceDelegate} and assign to the TAPPlayControlService object to receive any status update of the audio playback.
 */
@interface TAPPlayControlService : TAPService

/*!
 *  @property   delegate
 *  @brief      A TAPPlayControlService delegate object
 */
@property (nonatomic, strong) id<TAPPlayControlServiceDelegate> delegate;

/*!
 *  @method system:volume:
 *
 *  @param system           The target system
 *  @param volume           The block which taking the volume as a parameter
 *
 *  @brief                  Reads the volume from the target system
 *
 *  @discussion On BLE, the complete block will return an NSString object which presenting the currnet volume in text form.
 */
- (void)system:(id)system volume:(void (^)(NSString*))volume;

/*!
 *  @method system:writeVolume:completion:
 *
 *  @param system           The target system
 *  @param volume           The target volume
 *  @param completion       The completion block
 *
 *  @brief                  Writes the volume to the target system
 *
 *  @discussion On BLE, the complete block will return the BLE response. An NSError object otherwise.
 */
- (void)system:(id)system writeVolume:(NSInteger)volume completion:(void (^)(id))complete;

/*!
 *  @method volumeUpSystem:completion:
 *
 *  @param system           The target system
 *  @param completion       The completion block
 *
 *  @brief                  Up volume by one step to the target system
 *
 *  @discussion On BLE, the complete block will return the BLE response. An NSError object otherwise.
 */
- (void)volumeUpSystem:(id)system completion:(void (^)(id))complete;

/*!
 *  @method volumeDownSystem:completion:
 *
 *  @param system           The target system
 *  @param completion       The completion block
 *
 *  @brief                  Up volume by one step to the target system
 *
 *  @discussion On BLE, the complete block will return the BLE response. An NSError object otherwise.
 */
- (void)volumeDownSystem:(id)system completion:(void (^)(id))complete;

/*!
 *  @method startMonitorVolumeOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Starts monitoring the volume of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE volume charateristic provided by the system in audio service. Whenever there's a volume update, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TAPPlayControlService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TAPPlayControlService} , {@link system:didUpdateVolume:} will be triggered and provide the response data.
 *
 *  @see {@link system:didUpdateVolume:}
 */
- (void)startMonitorVolumeOfSystem:(id)system;

/*!
 *  @method stopMonitorVolumeOfSystem:
 *
 *  @param system           The target system
 *
 *  @brief  Stops monitoring the volume of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App unsubscripe to the BLE volume charateristic provided by the system in audio service.
 *  @see {@link startMonitorVolumeOfSystem:}
 */
- (void)stopMonitorVolumeOfSystem:(id)system;

/*!
 *  @method system:playStatus:
 *
 *  @param system           The target system
 *  @param status           The block which taking the status as a parameter
 *
 *  @brief                  Read the status from the target system
 *
 *
 */
- (void)system:(id)system playStatus:(void (^)(TAPPlayControlServicePlayStatus))status;

/*!
 *  @method system:audioSource:
 *
 *  @param system           The target system
 *  @param source           The block which taking the audioSource as a parameter
 *
 *  @brief                  Read the current audio source from the target system
 *
 *
 */
- (void)system:(id)system audioSource:(void (^)(TAPPlayControlServiceAudioSource))source;

/*!
 *  @method system:anc:
 *
 *  @param system           The target system
 *  @param anc              The block which taking the anc as a parameter
 *
 *  @brief                  Read the ANC from the target system
 *
 *
 */
- (void)system:(id)system anc:(void (^)(TAPPlayControlServiceANCStatus))anc;

/*!
 *  @method system:trueWireless:
 *
 *  @param system           The target system
 *  @param config           The block which taking the TrueWireless status as a parameter
 *
 *  @brief                  Reads the current TrueWireless status of the target system
 */
- (void)system:(id)system trueWireless:(void (^)(TAPPlayControlServiceTrueWirelessStatus))status;

/*!
 *  @method startMonitorPlayStatusOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Starts monitoring the play status of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE play status charateristic provided by the system in audio service. Whenever there's a status update, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TAPPlayControlService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TAPPlayControlService} , {@link system:didUpdatePlayStatus:} will be triggered and provide the response data.
 *
 *  @see {@link system:didUpdatePlayStatus:}
 */
- (void)startMonitorPlayStatusOfSystem:(id)system;

/*!
 *  @method stopMonitorPlayStatusOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Stops monitoring the play status of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App unsubscribe to the BLE play status charateristic provided by the system in audio service.
 *  @see {@link startMonitorPlayStatusOfSystem:}
 */
- (void)stopMonitorPlayStatusOfSystem:(id)system;

/*!
 *  @method system:play:
 *
 *  @param system           The target system
 *  @param complete         The block which taking the status as a parameter of the resultant status
 *
 *  @brief                  Plays audio of the target system
 *
 *
 */
- (void)system:(id)system play:(void (^)(TAPPlayControlServicePlayStatus))complete;

/*!
 *  @method system:pause:
 *
 *  @param system           The target system
 *  @param complete         The block which taking the status as a parameter of the resultant status
 *
 *  @brief                  Pauses audio of the target system
 *
 *
 */
- (void)system:(id)system pause:(void (^)(TAPPlayControlServicePlayStatus))complete;

/*!
 *  @method system:next:
 *
 *  @param system           The target system
 *  @param complete         The block which taking the status as a parameter
 *
 *  @brief                  Skips to next track
 *
 *
 */
- (void)system:(id)system next:(void (^)(id))complete;

/*!
 *  @method system:previous:
 *
 *  @param system           The target system
 *  @param complete         The block which taking the status as a parameter
 *
 *  @brief                  Skips to previous track
 *
 *
 */
- (void)system:(id)system previous:(void (^)(id))complete;

/*!
 *  @method system:tonescape:
 *
 *  @param system           The target system
 *  @param tonescape        The block which taking the EQ as a parameter
 *
 *  @brief                  Reads the EQ from the target system
 *
 *
 */
- (void)system:(id)system tonescape:(void (^)(id))complete;

/*!
 *  @method system:datapacket:tonescape:
 *
 *  @param system           The target system
 *  @param datapacket       The EQ data
 *  @param tonescape        The block which taking the EQ as a parameter
 *
 *  @brief                  Write EQ to the target system
 *
 *
 */
- (void)system:(id)system datapacket:(NSData*)data tonescape:(void (^)(id))complete;

/*!
 *  @method system:previous:
 *
 *  @param system           The target system
 *  @param anc              The ANC status
 *  @param complete         The block which taking the ANC Status as a parameter
 *
 *  @brief                  Skips to previous track
 *
 *
 */
- (void)system:(id)system turnANC:(TAPPlayControlServiceANCStatus)anc completion:(void (^)(id))complete;

/*!
 *  @method system:configTrueWireless:completion:
 *
 *  @param system           The target system
 *  @param command          The command of the target operation in TrueWireless
 *  @param completion       The completion block
 *
 *  @brief                  Sending TrueWireless command of the target system
 */
- (void)system:(id)system configTrueWireless:(TAPPlayControlServiceTrueWirelessCommand)command completion:(void (^)(id))complete;

/*!
 *  @method startMonitorTrueWirelessConfigOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Starts monitoring the TrueWireless Config of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE TrueWireless config charateristic provided by the system in audio service. Whenever there's a TrueWireless config change, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TAPSystemService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TAPSystemService} , {@link system:didUpdateTrueWirelessConfig:} will be triggered and provide the response data.
 *
 *  @see {@link system:didUpdateTrueWirelessConfig:}
 */
- (void)startMonitorTrueWirelessConfigOfSystem:(id)system;

/*!
 *  @method stopMonitorTrueWirelessConfigOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Stops monitoring the battery status of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App unsubscripe to the BLE TrueWireless config charateristic provided by the system in audio service.
 *  @see {@link startMonitorTrueWirelessConfigOfSystem:}
 */
- (void)stopMonitorTrueWirelessConfigOfSystem:(id)system;

/*!
 *  @method system:currentTrackInfo:
 *
 *  @param system           The target system
 *  @param complete         The block which taking the current track info as a parameter
 *
 *  @brief                  Retreives the current track info
 *
 *
 */
- (void)system:(id)system currentTrackInfo:(void (^)(NSDictionary*))complete;

/*!
 *  @method startMonitorCurrentTrackInfoOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Starts monitoring the current track info of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE current track info charateristic provided by the system in audio service. Whenever there's a status update, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TAPPlayControlService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TAPPlayControlService} , {@link system:didUpdateCurrentTrackInfo:} will be triggered and provide the response data.
 *
 *  @see {@link system:didUpdateCurrentTrackInfo:}
 */
- (void)startMonitorCurrentTrackInfoOfSystem:(id)system;

/*!
 *  @method stopMonitorCurrentTrackInfoOfSystem:
 *
 *  @param system           The target system
 *
 *  @brief  Stops monitoring the current track info of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App unsubscribe to the BLE play status charateristic provided by the system in audio service.
 *  @see {@link startMonitorCurrentTrackInfoOfSystem:}
 */
- (void)stopMonitorCurrentTrackInfoOfSystem:(id)system;

@end

/*!
 *  @protocol TAPPlayControlServiceDelegate
 *
 *  @brief    Delegate define methods for receive notifications from TAPPlayControlService object.
 *
 */
@protocol TAPPlayControlServiceDelegate <NSObject>

@required

@optional

/*!
 *  @method system:didUpdateVolume:
 *
 *  @param system       The system which has this update
 *  @param volume       The new volume value
 *
 *  @brief              Invoked when a the system has a volume update
 */
- (void)system:(id)system didUpdateVolume:(NSString*)volume;

/*!
 *  @method system:didUpdatePlayStatus:
 *
 *  @param system       The system which has this update
 *  @param status       The new play status
 *
 *  @brief              Invoked when a the system has a play status update
 */
- (void)system:(id)system didUpdatePlayStatus:(TAPPlayControlServicePlayStatus)status;

/*!
 *  @method system:didUpdatePlayStatus:
 *
 *  @param system       The system which has this update
 *  @param status       The new audio source
 *
 *  @brief              Invoked when a the system has a audio source update
 */
- (void)system:(id)system didUpdateAudioSource:(TAPPlayControlServiceAudioSource)audioSource;

/*!
 *  @method system:didUpdateCurrentTrackInfo:
 *
 *  @param system       The system which has this update
 *  @param config       The new track info
 *
 *  @brief              Invoked when a the system has a track info update
 */
- (void)system:(id)system didUpdateCurrentTrackInfo:(NSDictionary*)trackInfo;

@end

