/**************************************************************
 * Copyright (C) 2014, Qualcomm Connected Experiences, Inc.
 * All rights reserved. Confidential and Proprietary.
 **************************************************************/

#import <Foundation/Foundation.h>
#import "APPlayer.h"

@class APZoneData;
@class APMediaItem;
@class APPlaylist;

/**
 Represents a group of AllPlay players or an individual player. Your application should always interact with zones rather than players.
 */
@interface APZone : NSObject {
@private
	APZoneData * _data;
}
/** The display name of the zone. */
@property (nonatomic, readonly) NSString * displayName;
/** The unique zone ID. */
@property (nonatomic, readonly) NSString * zoneID;
/** The maximum possible volume of the zone. 
 The maximum volume of a zone is the average of all of the zone's players' maximum volumes.
 */
@property (nonatomic, readonly) int maxVolume;
/** The current volume of the zone. 
 The volume of a zone is the average of all of the zone's players' volumes. 
 */
@property (nonatomic, readonly) int volume;
/** YES if the zone supports audio. */
@property (nonatomic, readonly) BOOL isAudioSupported;
/** YES if the zone supports video. */
@property (nonatomic, readonly) BOOL isVideoSupported;
/** YES if the zone supports photos. */
@property (nonatomic, readonly) BOOL isPhotoSupported;
/** YES if the zone supports Party Mode (the grouping of multiple players into a zone). 
 A zone supports Party Mode if there is only 1 player in the zone, and that player supports Party Mode.
 */
@property (nonatomic, readonly) BOOL isPartyModeSupported;

/** The currently playing media item. */
@property (nonatomic, readonly) APMediaItem * currentItem;
/** The media item that will play next. */
@property (nonatomic, readonly) APMediaItem * nextItem;
/** The index in the playlist of the media item that is currently playing. */
@property (nonatomic, readonly) int indexPlaying;
/** The index in the playlist of the media item that will play next. */
@property (nonatomic, readonly) int nextIndex;
/** The current player state of the zone. */
@property (nonatomic, readonly) APPlayerState playerState;

/** The position within the zone's currently playing media item, in milliseconds. */
@property (nonatomic, readonly) int playerPosition;
/** The zone's current loop mode. */
@property (nonatomic, readonly) APLoopMode loopMode;
/** The zone's current shuffle mode. */
@property (nonatomic, readonly) APShuffleMode shuffleMode;
/** The zone's current playlist. */
@property (nonatomic, readonly) APPlaylist * playlist;
/** An array of the APPlayers in this zone. */
@property (nonatomic, readonly) NSArray * players;
/** The lead player of the zone */
@property (nonatomic, readonly) APPlayer * leadPlayer;
/** An array of the slave APPlayers in this zone. */
@property (nonatomic, readonly) NSArray * slavePlayers;

/**
 Used to determine the order in which two zones should be displayed in a list.
 @param zone An instance of an APZone.
 @return An NSComparisonResult, an object indicating the relative values of the zones.
 */
- (NSComparisonResult)compare:(APZone *)zone;

/**
 Tests to see if another AllPlay zone is the same as this zone.
 @param zone An instance of an APZone.
 @return YES if this zone is the same as the zone parameter.
 */
- (BOOL)isEqualToZone:(APZone *)zone;

/**
 Sets the volume of all of the players in the zone.
 This sends a network request to the each player. This call is blocking.
 @param volume The volume to set. 0 will mute it. The volume shouldn’t be bigger than maxVolume.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)setVolume:(int)volume error:(NSError **)error;

/**
 Sets the position within the zone's currently playing media item, in milliseconds. Equivalent to seek.
 This sends a network request to the zone. This call is blocking.
 @param position The desired position, in milliseconds
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)setPlayerPosition:(int)position error:(NSError **)error;

/**
 Sets the zone's loop mode.
 This sends a network request to the zone. This call is blocking.
 @param loopMode The desired loop mode.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)setLoopMode:(APLoopMode)loopMode error:(NSError **)error;

/**
 Sets the zone's shuffle mode.
 This sends a network request to the zone. This call is blocking.
 @param shuffleMode The desired shuffle mode.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)setShuffleMode:(APShuffleMode)shuffleMode error:(NSError **)error;

/**
 Updates the zone's playlist. 
 
 This is usefull for adding new items to the current playlist while not interrupting playback.
 If you want to a play a completely new playlist, please use playPlaylist.
 
 This sends a network request to the zone. This call is blocking.
 @param playlist The updated playlist.
 @param playIndex The index of the currently playing item in the new playlist.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)updatePlaylist:(APPlaylist *)playlist playIndex:(int)playIndex error:(NSError **)error;

/**
 Plays a media item on the zone.
 This sends a network request to the zone. This call is blocking.
 @param mediaItem The media item to play.
 @param startPosition The position within the media item from which to start playing, in milliseconds.
 @param shouldPause If true, the zone will queue up the item and pause it at the specified position.
 @param loopMode The desired loop mode.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)play:(APMediaItem *)mediaItem startPosition:(int)startPosition shouldPause:(BOOL)shouldPause
	loopMode:(APLoopMode)loopMode error:(NSError **)error;

/**
 Plays a new playlist on the zone.
 This sends a network request to the zone. This call is blocking.
 @param playlist The new playlist.
 @param startIndex The index of the media item in the playlist at which to start playing. If shuffleMode is set to APShuffleModeShuffle, use -1 to start playing the playlist at a random index.
 @param startPosition The position within the media item from which to start playing, in milliseconds.
 @param shouldPause If true, the zone will queue up the item and pause at the specified position.
 @param loopMode The desired loop mode.
 @param shuffleMode The desired shuffle mode.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)playPlaylist:(APPlaylist *)playlist startIndex:(int)startIndex startPosition:(int)startPosition shouldPause:(BOOL)shouldPause loopMode:(APLoopMode)loopMode shuffleMode:(APShuffleMode)shuffleMode error:(NSError **)error;


/**
 Plays a media item in the current playlist.
 This sends a network request to the zone. This call is blocking.
 @param playIndex The index of the media item to be played.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)playIndex:(int)playIndex error:(NSError **)error;

/**
 Play the current media item. Usually called after pauseWithError or stopWithError.
 This sends a network request to the zone. This call is blocking.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
@return YES if the request succeeded.
 */
- (BOOL)playWithError:(NSError **)error;

/**
 Pauses playback on the zone.
 This sends a network request to the zone. This call is blocking.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)pauseWithError:(NSError **)error;

/**
 Plays the next media item in the zone's playlist.
 This sends a network request to the zone. This call is blocking.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)nextWithError:(NSError **)error;

/**
 Plays the previous media item in the zone's playlist.  If the playback has passed 5 secs, it will restart the playback
 This sends a network request to the zone. This call is blocking.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)previousWithError:(NSError **)error;

/**
 Force plays the previous media item in the zone's playlist.
 This sends a network request to the zone. This call is blocking.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)forcePreviousWithError:(NSError **)error;

/**
 Stops playback on the zone.
 This sends a network request to the zone. This call is blocking.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 @return YES if the request succeeded.
 */
- (BOOL)stopWithError:(NSError**)error;

@end
