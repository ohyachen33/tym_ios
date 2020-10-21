/**************************************************************
 * Copyright (C) 2014, Qualcomm Connected Experiences, Inc.
 * All rights reserved. Confidential and Proprietary.
 **************************************************************/

#import <Foundation/Foundation.h>

/**
 Enumeration of AllPlay player states.
 */
typedef enum {
    /** The AllPlay player is stopped. */
	APPlayerStateStopped = 0,
    /** The AllPlay player is playing. */
	APPlayerStatePlaying,
    /** The AllPlay player is loading a new stream. */
	APPlayerStateTransitioning,
    /** The AllPlay player is paused. */
	APPlayerStatePaused,
    /** The AllPlay player is buffering. */
	APPlayerStateBuffering
} APPlayerState;

/**
 Enumeration of AllPlay player loop modes.
 */
typedef enum {
    /** Do not loop: playback stops at the end of the playlist. */
	APLoopModeNone = 0,
    /** Loop one: keep replaying the current media item. */
	APLoopModeOne,
    /** Loop all: repeat the entire playlist. */
	APLoopModeAll
} APLoopMode;

/**
 Enumeration of AllPlay player shuffle modes.
 */
typedef enum {
    /** Media items are played in the order of the playlist. */
	APShuffleModeLinear = 0,
    /** Media items are played in random order. */
	APShuffleModeShuffle
} APShuffleMode;

/** 
 Enumeration of the AllPlay player error codes.
 */
typedef enum {
    /** No error. */
	APPlayerErrorNone = 0,
	/** Unknown error.*/
	APPlayerErrorUnknown,
    /** Request failed. */
	APPlayerErrorRequest,
    /** Network error. */
	APPlayerErrorNetwork,
	/** Format error. */
	APPlayerErrorFormat,
	/** Stream error. */
	APPlayerErrorStream,
	/** Authentication error. */
	APPlayerErrorAuthentication,
	/** Media rules error. */
	APPlayerErrorMediaRulesEngine,
    /** Invalid device. */
	APPlayerErrorInvalidPlayer
} APPlayerError;

/**
 Enumeration of the AllPlay player network interface
 */
typedef enum {
	/** Not connected */
	APNetworkInterfaceNone = 0,
	/** Connected to wifi */
	APNetworkInterfaceWifi,
	/** Connected to ethernet */
	APNetworkInterfaceEthernet
} APNetworkInterface;

/**
 Enumeration of the AllPlay player update status
*/
typedef enum {
    /** Update successful */
    APUpdateStatusSuccessful = 0,
    /** Update not needed */
    APUpdateStatusNotNeeded,
    /** Update failed */
    APUpdateStatusFailed,
	/** Updating */
	APUpdateStatusUpdating
} APUpdateStatus;

/**
 Error domain for APPlayer.
 */
extern NSString * const APPlayerErrorDomain;


@class APPlayerData;
@class APMediaItem;

/**
 Represents an AllPlay player on the network.
 
 You should never create an instance of this class directly.
 See APPlayerManager.
 */
@interface APPlayer : NSObject {
@private
	APPlayerData * _data;
}

/**
 The display name of the player.
 */
@property (nonatomic, readonly) NSString * displayName;
/**
 The player's unique player ID.
 */
@property (nonatomic, readonly) NSString * playerID;
/**
 The player's maximum volume.
 */
@property (nonatomic, readonly) int maxVolume;
/**
 The player's current volume.
 */
@property (nonatomic, readonly) int volume;
/**
 The player network interface connection
 */
@property (nonatomic, readonly) APNetworkInterface networkInterface;
/**
 The player's wifi IP address.
 */
@property (nonatomic, readonly) NSString * wifiIPAddress;
/**
 The player's wifi Mac address.
 */
@property (nonatomic, readonly) NSString * wifiMacAddress;
/**
 The player's ethernet IP address.
 */
@property (nonatomic, readonly) NSString * ethernetIPAddress;
/**
 The player's ethernet Mac address.
 */
@property (nonatomic, readonly) NSString * ethernetMacAddress;
/**
 The player's firmware version.
 */
@property (nonatomic, readonly) NSString * firmwareVersion;
/**
 The SSID of the Wi-Fi network to which the player is connected.
 */
@property (nonatomic, readonly) NSString * wifiSSID;
/**
 The player's Wi-Fi quality.
 */
@property (nonatomic, readonly) int wifiQuality;
/**
 YES if the player will auto update
 */
@property (nonatomic, readonly) BOOL isAutoUpdate;
/**
 YES if the player have new firmware for update
 */
@property (nonatomic, readonly) BOOL haveNewFirmware;
/**
 The player's new firmware version
 */
@property (nonatomic, readonly) NSString * newFirmwareVersion;
/**
 The player's new firmware url
 */
@property (nonatomic, readonly) NSString * newFirmwareUrl;
/**
 The player's manufacturer
 */
@property (nonatomic, readonly) NSString * manufacturer;
/**
 The player's model number
 */
@property (nonatomic, readonly) NSString * modelNumber;
/**
 YES if the player supports audio.
 */
@property (nonatomic, readonly) BOOL isAudioSupported;
/**
 YES if the player supports video.
 */
@property (nonatomic, readonly) BOOL isVideoSupported;
/**
 YES if the player supports photos.
 */
@property (nonatomic, readonly) BOOL isPhotoSupported;
/**
 YES if the player supports Party Mode.
 */
@property (nonatomic, readonly) BOOL isPartyModeSupported;
/**
 The player's update status
 */
@property (nonatomic, readonly) APUpdateStatus updateStatus;

/**
 Used to determine the order in which two AllPlay players should be displayed in a list.
 @param player The player to compare to this one.
 @return An NSComparisonResult, an object indicating the relative values of the players.
 */
- (NSComparisonResult)compare:(APPlayer *)player;

/**
 Tests to see if another AllPlay player is the same as this player.
 @param player The player to compare to this one.
 @return YES if this player is the same as the other player.
 */
- (BOOL)isEqualToPlayer:(APPlayer *)player;

/**
 Sets the volume of the AllPlay player.
  This method sends a network request to the AllPlay player. This call is blocking.
 @param volume The volume to set. 0 will mute it. The volume shouldn't be bigger than maxVolume.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)setVolume:(int)volume error:(NSError **)error;

/**
 Sets the display name of the AllPlay player.
 This method sends a network request to the AllPlay player. This call is blocking.
 @param displayName The new display name.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)setDisplayName:(NSString *)displayName error:(NSError **)error;

/**
 Reboot the AllPlay player.
 This method sends a network request to the AllPlay player. This call is blocking.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)reboot:(NSError **)error;

/**
 Update the player to the latest firmware.  Usually called if confirmed there is a firmware update with getNewFirmwareInfoWithError.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded
 */
- (BOOL)updateFirmware:(NSError **)error;

/**
 Update the player to a firmware via url.  
 @param url url to the firmware
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded
 */
- (BOOL)updateFirmwareFromUrl:(NSString *)url error:(NSError **)error;

/**
 Set the player to auto update firmware.
 @param autoUpdate YES to enable auto update, NO to disable auto update.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded
 */
- (BOOL)setAutoUpdate:(BOOL)autoUpdate error:(NSError **)error;

/**
 Update the player device info
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded
 */
- (BOOL)updateDeviceInfo:(NSError **)error;

/**
 Ask the player to check for new firmware.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded
 */
- (BOOL)checkForNewFirmware:(NSError **)error;

@end
