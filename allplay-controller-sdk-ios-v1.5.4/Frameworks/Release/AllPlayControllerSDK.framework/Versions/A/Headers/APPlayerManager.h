/**************************************************************
 * Copyright (C) 2014, Qualcomm Connected Experiences, Inc.
 * All rights reserved. Confidential and Proprietary.
 **************************************************************/

#import <Foundation/Foundation.h>
#import "APPlayer.h"
#import "APZone.h"

@class APPlayerManager;

/**
  The APPlayerManagerDelegate protocol declares the interface that an APPlayerManager delegate must adopt, in order to be notified of APPlayerManager events.
 */
@protocol APPlayerManagerDelegate <NSObject>

@optional

/**
 Called when a zone has been added.
 @param manager The APPlayerManager instance.
 @param zone The zone that was added.
 */
- (void)playerManager:(APPlayerManager *)manager zoneAdded:(APZone *)zone;

/**
 Called when a zone has been removed.
 @param manager The APPlayerManager instance.
 @param zone The zone that was removed.
 */
- (void)playerManager:(APPlayerManager *)manager zoneRemoved:(APZone *)zone;

/**
 Called when a zone's layer state has changed.
 @param manager The APPlayerManager instance.
 @param zone The zone.
 @param state The new state.
 */
- (void)playerManager:(APPlayerManager *)manager zone:(APZone *)zone playStateChanged:(APPlayerState)state;

/**
 Called when a zone's playlist has changed.
 @param manager The APPlayerManager instance.
  @param zone The zone.
 @param playlist The new playlist
 */
- (void)playerManager:(APPlayerManager *)manager zone:(APZone *)zone playlistChanged:(APPlaylist *)playlist;

/**
 Called when a player's volume has changed.
 @param manager The APPlayerManager instance.
 @param player The player.
 @param volume The new volume.
 */
- (void)playerManager:(APPlayerManager *)manager player:(APPlayer *)player volumeStateChanged:(int)volume;

/**
 Called when a zone's loop mode has changed.
 @param manager The APPlayerManager instance.
 @param zone The zone.
 @param loopMode The new loop mode.
 */
- (void)playerManager:(APPlayerManager *)manager zone:(APZone *)zone loopStateChanged:(APLoopMode)loopMode;

/**
 Called when a zone's shuffle mode has changed.
 @param manager The APPlayerManager instance.
 @param zone The zone.
 @param shuffleMode the new shuffle mode.
 */
- (void)playerManager:(APPlayerManager *)manager zone:(APZone *)zone shuffleStateChanged:(APShuffleMode)shuffleMode;

/**
 Called when a player's display name has changed.
 @param manager The APPlayerManager instance.
 @param player The player.
 @param displayName The new display name.
 */
- (void)playerManager:(APPlayerManager *)manager player:(APPlayer *)player displayNameChanged:(NSString *)displayName;

/**
 Called when a zone's players list has changed.
 @param manager The APPlayerManager instance.
 @param zone The zone.
 */
- (void)playerManager:(APPlayerManager *)manager zonePlayersListChanged:(APZone *)zone;

/**
 Called when a zone's ID has changed.
 @param manager The APPlayerManager instance.
 @param zone The zone with the new id.
 @param oldZoneID The old zone id.
 */
- (void)playerManager:(APPlayerManager *)manager zoneWithNewID:(APZone *)zone oldZoneID:(NSString *)oldZoneID;

/**
 Called when a player is starting to update.
 @param manager The APPlayerManager instance.
 @param player The player.
 */
- (void)playerManager:(APPlayerManager *)manager playerUpdateStarted:(APPlayer *)player;

/**
 Called when a player's auto update settings changed
 @param manager The APPlayerManager instance.
 @param player The player.
 @param autoUpdate The new auto update setting.
 */
- (void)playerManager:(APPlayerManager *)manager player:(APPlayer *)player autoUpdateChanged:(BOOL)autoUpdate;

/**
 Called when a player have an update available
 @param manager the APPlayerManager instance.
 @param player The player.
 */
- (void)playerManager:(APPlayerManager *)manager playerUpdateAvailable:(APPlayer *)player;

/**
 Called when a player have an update available
 @param manager The APPlayerManager instance.
 @param player The player.
 @param status The update status.
 */
- (void)playerManager:(APPlayerManager *)manager player:(APPlayer *)player updateStatusChanged:(APUpdateStatus)status;

/**
 Called when a zone has raised an error.
 @param manager The APPlayerManager instance.
 @param zone The zone.
 @param index The index in the playlist
 @param error The error
 */
- (void)playerManager:(APPlayerManager *)manager
				 zone:(APZone *)zone
 playbackErrorInIndex:(int)index
				error:(NSError *)error;

@end

@class APPlayerManagerData;

/**
 The APPlayerManager class manages the interactions between your application and the AllPlay Controller SDK.
 
 Use APPlayerManager to query about available players and zones and receive events when one is added, edited or removed.
 
 This class is a singleton.
 */
@interface APPlayerManager : NSObject {
@private
	APPlayerManagerData * _data;
}

/** The delegate object that will receive the events. */
@property (nonatomic, assign) id<APPlayerManagerDelegate> delegate;
/** An array of the available zones. */
@property (nonatomic, readonly) NSArray * zones;
/** An array of the AllPlay players that support Party Mode (i.e. can be grouped into a zone). */
@property (nonatomic, readonly) NSArray * partyModePlayers;
/** Check if the PlayerManager has already started. */
@property (nonatomic, readonly) BOOL isStarted;

/**
 Gets the APPlayerManager. APPlayerManager is a static singleton. If it doesn't exist yet, this method will create it.
 @param applicationName A unique string identifying your application.
 */
+ (APPlayerManager *)sharedManagerWithApplicationName:(NSString *)applicationName;

/**
 Creates a zone.
 @param leadPlayer The lead player of the zone.
 @param slavePlayers An array of slave players for the lead player.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 */
- (BOOL)createZone:(APPlayer *)leadPlayer withSlaves:(NSArray *)slavePlayers error:(NSError **)error;

/**
 Edits a zone.
 @param editZone The zone to edit.
 @param slavePlayers An array of slave players for the zone.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 */
- (BOOL)editZone:(APZone *)editZone withSlaves:(NSArray *)slavePlayers error:(NSError **)error;

/**
 Deletes a zone.
 @param deleteZone The zone to delete.
 @param error If an error occurs, upon return this parameter contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
 */
- (BOOL)deleteZone:(APZone *)deleteZone error:(NSError **)error;

/**
 Starts the detection of AllPlay players and events over the network.
 */
- (void)start;

/**
 Stops APPlayerManager.
 */
- (void)stop;

/**
 Refresh 
 */
- (void)refreshPlayerList;

@end
