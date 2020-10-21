//
//  TAPlayControlService.h
//  TAPlayControlService
//
//  Created by Lam Yick Hong on 23/4/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAService.h"

enum{
    TAPlayControlServicePlayStatusPause = 0,
    TAPlayControlServicePlayStatusPlay,
    TAPlayControlServicePlayStatusStopped,
    TAPlayControlServicePlayStatusUnknown
};

typedef NSInteger TAPlayControlServicePlayStatus;


enum{
    TAPlayControlServiceAudioSourceNoSource = 0,
    TAPlayControlServiceAudioSourceAuxIn,
    TAPlayControlServiceAudioSourceUSB,
    TAPlayControlServiceAudioSourceBluetooth,
    TAPlayControlServiceAudioSourceUnknown
};

typedef NSInteger TAPlayControlServiceAudioSource;

enum{
    TAPlayControlServiceANCStatusOff = 0,
    TAPlayControlServiceANCStatusOn,
    TAPlayControlServiceANCStatusUnknown
};

typedef NSInteger TAPlayControlServiceANCStatus;


enum{
    TAPlayControlServiceTrueWirelessStatusDisconnected = 0,
    TAPlayControlServiceTrueWirelessStatusReconnecting,
    TAPlayControlServiceTrueWirelessStatusPairingMaster,
    TAPlayControlServiceTrueWirelessStatusPairingSlave,
    TAPlayControlServiceTrueWirelessStatusConnectedMaster,
    TAPlayControlServiceTrueWirelessStatusConnectedSlave,
    TAPlayControlServiceTrueWirelessStatusUnknown
};

typedef NSInteger TAPlayControlServiceTrueWirelessStatus;

enum{
    TAPlayControlServiceTrueWirelessCommandDisconnect = 0,
    TAPlayControlServiceTrueWirelessCommandPairingMaster,
    TAPlayControlServiceTrueWirelessCommandPairingSlave,
    TAPlayControlServiceTrueWirelessCommandUnknown
};

typedef NSInteger TAPlayControlServiceTrueWirelessCommand;


@protocol TAPlayControlServiceDelegate;

/*!
 *  @warning This is a prelimenary document. The TAP libraries and interfaces are under development and will have heavy changes along.
 *
 *  @interface TAPlayControlService
 *  @brief     TAP Service for controlling the audio play back. Any basic playback control will be provided here.
 *  @author    Hong Lam
 *  @date      23/4/15
 *  @copyright Tymphany Ltd.
 *
 *  @discussion {@link TAPlayControlService} objects are used to control the audio playback on the systems, including play, pause, next track, previous track, volume control and current playback info.
 *
 *  You should implement the {@link TAPlayControlServiceDelegate} and assign to the TAPlayControlService object to receive any status update of the audio playback.
 */
@interface TAPlayControlService : TAService

/*!
 *  @property   delegate
 *  @brief      A TAPlayControlService delegate object
 */
@property (nonatomic, strong) id<TAPlayControlServiceDelegate> delegate;

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
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE volume charateristic provided by the system in audio service. Whenever there's a volume update, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TAPlayControlService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TAPlayControlService} , {@link system:didUpdateVolume:} will be triggered and provide the response data.
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
- (void)system:(id)system playStatus:(void (^)(TAPlayControlServicePlayStatus))status;

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
- (void)system:(id)system audioSource:(void (^)(TAPlayControlServiceAudioSource))source;

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
- (void)system:(id)system anc:(void (^)(TAPlayControlServiceANCStatus))anc;

/*!
 *  @method system:trueWireless:
 *
 *  @param system           The target system
 *  @param config           The block which taking the TrueWireless status as a parameter
 *
 *  @brief                  Reads the current TrueWireless status of the target system
 */
- (void)system:(id)system trueWireless:(void (^)(TAPlayControlServiceTrueWirelessStatus))status;

/*!
 *  @method startMonitorPlayStatusOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Starts monitoring the play status of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE play status charateristic provided by the system in audio service. Whenever there's a status update, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TAPlayControlService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TAPlayControlService} , {@link system:didUpdatePlayStatus:} will be triggered and provide the response data.
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
- (void)system:(id)system play:(void (^)(TAPlayControlServicePlayStatus))complete;

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
- (void)system:(id)system pause:(void (^)(TAPlayControlServicePlayStatus))complete;

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
- (void)system:(id)system turnANC:(TAPlayControlServiceANCStatus)anc completion:(void (^)(id))complete;

/*!
 *  @method system:configTrueWireless:completion:
 *
 *  @param system           The target system
 *  @param command          The command of the target operation in TrueWireless
 *  @param completion       The completion block
 *
 *  @brief                  Sending TrueWireless command of the target system
 */
- (void)system:(id)system configTrueWireless:(TAPlayControlServiceTrueWirelessCommand)command completion:(void (^)(id))complete;

/*!
 *  @method startMonitorTrueWirelessConfigOfSystem:
 *
 *  @param system   The target system
 *
 *  @brief  Starts monitoring the TrueWireless Config of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE TrueWireless config charateristic provided by the system in audio service. Whenever there's a TrueWireless config change, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TASystemService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TASystemService} , {@link system:didUpdateTrueWirelessConfig:} will be triggered and provide the response data.
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
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE current track info charateristic provided by the system in audio service. Whenever there's a status update, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TAPlayControlService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TAPlayControlService} , {@link system:didUpdateCurrentTrackInfo:} will be triggered and provide the response data.
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
 *  @protocol TAPlayControlServiceDelegate
 *
 *  @brief    Delegate define methods for receive notifications from TAPlayControlService object.
 *
 */
@protocol TAPlayControlServiceDelegate <NSObject>

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
- (void)system:(id)system didUpdatePlayStatus:(TAPlayControlServicePlayStatus)status;

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

