/**************************************************************
 * Copyright (C) 2014, Qualcomm Connected Experiences, Inc.
 * All rights reserved. Confidential and Proprietary.
 **************************************************************/

#import "APZone.h"

@class APRequest;

/**
 The APZoneDelegate protocol declares the interface that an APZone delegate must adopt, in order to be notified of the completion of asynchronous APzone requests.
 */
@protocol APZoneDelegate <NSObject>

@optional

/**
 Called when a requested operation has started.
 @param zone The APZone instance.
 @param request The APRequest that has started.
 */
- (void)zone:(APZone *)zone requestDidStart:(APRequest *)request;

/**
 Called when a requested operation has been canceled.
 @param zone The APZone instance.
 @param request The APRequest that has been canceled.
 */
- (void)zone:(APZone *)zone requestDidCancel:(APRequest *)request;

/**
 Called when a requested operation has finished.
 @param zone The APZone instance.
 @param request The APRequest that has finished.
 */
- (void)zone:(APZone *)zone requestDidFinish:(APRequest *)request;

/**
 Called when a requested operation has failed.
 @param zone The APZone instance.
 @param request The APRequest that has failed.
 @param error The reason for the failure.
 */
- (void)zone:(APZone *)zone request:(APRequest *)request didFailWithError:(NSError *)error;

@end


/**
 * The APZone class has an asynchronous interface for APZone blocking methods.
 */
@interface APZone (Async)

/** 
 Access the set delegate object.
 @return Delegate object
 */
- (id<APZoneDelegate>)getDelegate;

/** 
 The delegate object that will receive the events. 
 @param delegate The APZoneDelegate object
 */
- (void)setDelegate:(id<APZoneDelegate>)delegate;

/**
 Sets the volume of all of the players in the zone.
 This call returns immediately.
 @param volume The volume to set. 0 will mute it. The volume shouldn’t be bigger than maxVolume.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)setVolume:(int)volume;

/**
 Sets the position within the zone's currently playing media item, in milliseconds. Equivalent to seek.
 This call returns immediately.
 @param position The desired new position within the stream.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)setPlayerPosition:(int)position;

/**
 Sets the zone's loop mode.
 This call returns immediately.
 @param loopMode The desired loop mode.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)setLoopMode:(APLoopMode)loopMode;

/**
 Sets the zone's shuffle mode.
 This call returns immediately.
 @param shuffleMode The desired shuffle mode.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)setShuffleMode:(APShuffleMode)shuffleMode;

/**
 Updates the zone's playlist.
 
 This is usefull for adding new items to the current playlist while not interrupting playback.
 If you want to a play a completely new playlist, please use playPlaylist.
 
 This call returns immediately.
 @param playlist The updated playlist.
 @param playIndex The index of the currently playing item in the new playlist.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)updatePlaylist:(APPlaylist *)playlist playIndex:(int)playIndex;

/**
 Plays a media item on the zone.
 This call returns immediately.
 @param mediaItem The media item to play.
 @param startPosition The position within the media item from which to start playing, in milliseconds.
 @param shouldPause If true, the zone will queue up the item and pause it at the specified position.
 @param loopMode The desired loop mode.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)play:(APMediaItem *)mediaItem startPosition:(int)startPosition shouldPause:(BOOL)shouldPause
	loopMode:(APLoopMode)loopMode;

/**
 Plays a new playlist on the zone.
 This call returns immediately.
 @param playlist The new playlist.
 @param startIndex The index of the media item in the playlist at which to start playing. If shuffleMode is set to APShuffleModeShuffle, use -1 to start playing the playlist at a random index.
 @param startPosition The position within the media item from which to start playing, in milliseconds.
 @param shouldPause If true, the zone will queue up the item and pause at the specified position.
 @param loopMode The desired loop mode.
 @param shuffleMode The desired shuffle mode.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)playPlaylist:(APPlaylist *)playlist startIndex:(int)startIndex startPosition:(int)startPosition shouldPause:(BOOL)shouldPause loopMode:(APLoopMode)loopMode shuffleMode:(APShuffleMode)shuffleMode;

/**
 Plays a media item in the current playlist.
 This call returns immediately.
 @param playIndex The index of the media item to be played.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)playIndex:(int)playIndex;

/**
 Play the current media item. Usually called after pause or stop.
 This call returns immediately.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)play;

/**
 Pauses playback on the zone.
 This call returns immediately.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)pause;

/**
 Plays the next media item in the zone's playlist.
 This call returns immediately.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)next;

/**
 Plays the previous media item in the zone's playlist.  If the playback has passed 5 secs, it will restart the playback
 This call returns immediately.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)previous;

/**
 Force plays the previous media item in the zone's playlist.
 This call returns immediately.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)forcePrevious;

/**
 Stops playback on the zone.
 This call returns immediately.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its finished state (finished, canceled or failed).
 */
- (APRequest *)stop;

@end
