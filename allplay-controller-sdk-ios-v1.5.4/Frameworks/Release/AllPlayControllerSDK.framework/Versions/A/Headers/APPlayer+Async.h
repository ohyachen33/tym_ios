/**************************************************************
 * Copyright (C) 2014, Qualcomm Connected Experiences, Inc.
 * All rights reserved. Confidential and Proprietary.
 **************************************************************/

#import "APPlayer.h"

@class APRequest;

/**
 The APPlayerDelegate protocol declares the interface that an APPlayer delegate must adopt, in order to be notified of the completion of asynchronous APPlayer requests.
 */
@protocol APPlayerDelegate <NSObject>

@optional
/** 
 Called when a requested operation has started.
 @param player The AllPlay player instance.
 @param request The APRequest that has started.
 */
- (void)player:(APPlayer *)player requestDidStart:(APRequest *)request;

/**
 Called when a requested operation has been canceled. 
 @param player The AllPlay player instance.
 @param request The APRequest that has been canceled.
 */
- (void)player:(APPlayer *)player requestDidCancel:(APRequest *)request;

/** 
 Called when a requested operation has finished. 
 @param player The AllPlay player instance.
 @param request The APRequest that has finished.
 */
- (void)player:(APPlayer *)player requestDidFinish:(APRequest *)request;

/** 
 Called when a requested operation has failed. 
 @param player The AllPlay player instance.
 @param request The APRequest that has failed.
 @param error The reason for the failure.
 */
- (void)player:(APPlayer *)player request:(APRequest *)request didFailWithError:(NSError *)error;

@end


/**
 The APPlayer class has an asynchronous interface for APPlayer blocking methods.
 */
@interface APPlayer (Async)

/** 
 Access the set delegate object.
 @return Delegate object
 */
- (id<APPlayerDelegate>)getDelegate;

/** 
 The delegate object that will receive the events.
 @param delegate The APPlayerDelegate object.
 */
- (void)setDelegate:(id<APPlayerDelegate>)delegate;

/**
 Sets the volume of the AllPlay player.
 This call returns immediately. 
 @param volume The volume to set. 0 will mute it. The volume shouldn't be bigger than maxVolume.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its final state (finished, canceled or failed).
 */
- (APRequest *)setVolume:(int)volume;

/**
 Sets the display name of the AllPlay player.
 This call returns immediately.
 @param displayName The new dispaly name.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its final state (finished, canceled or failed).
 */
- (APRequest *)setDisplayName:(NSString *)displayName;

/**
 Reboot the AllPlay player.
 This call returns immediately.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its final state (finished, canceled or failed). 
 */
- (APRequest *)reboot;

/**
 Update the player to the latest firmware. Usually called after confirmed with getNewFirmwareInfoWithError
 This call returns immediately.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its final state (finished, canceled or failed).
 */
- (APRequest *)updateFirmware;

/**
 Update the player to the a firmware via url
 This call returns immediately.
 @param url The url to the firmware.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its final state (finished, canceled or failed).
 */
- (APRequest *)updateFirmwareFromUrl:(NSString *)url;

/**
 Set the player to auto update firmware.
 This call returns immediately.
 @param autoUpdate YES to enable auto update, NO to disable auto update.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its final state (finished, canceled or failed).
 */
- (APRequest *)setAutoUpdate:(BOOL)autoUpdate;

/**
 Update the player's device info
 This call returns immediately.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its final state (finished, canceled or failed).
 */
- (APRequest *)updateDeviceInfo;

/**
 Ask the player to check for new firmware
 This call returns immediately.
 @return An APRequest instance. Retain this instance if you want to know what request completed.
 If you don't retain the instance it will be released once it has dispatched its final state (finished, canceled or failed).
 */
- (APRequest *)checkForNewFirmware;

@end
