//
//  TAAllPlay.m
//  TAAllPlay
//
//  Created by Lam Yick Hong on 2/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAAllPlay.h"

@implementation TAAllPlay

- (id)initWithDelegate:(id<APPlayerManagerDelegate>)delegate
{
    if(self = [super init])
    {
        [playerManager setDelegate:delegate];
    }
    return self;
}

- (void)start
{
    APPlayerManager* playerManager = [self playerManager];
    
    [playerManager start];
}

- (void)stop
{
    APPlayerManager* playerManager = [self playerManager];
    [playerManager stop];
}


#pragma APPlayerManagerDelegate function

- (void)playerManager:(APPlayerManager *)manager player:(APPlayer *)player autoUpdateChanged:(BOOL)autoUpdate
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)playerManager:(APPlayerManager *)manager player:(APPlayer *)player displayNameChanged:(NSString *)displayName
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)playerManager:(APPlayerManager *)manager player:(APPlayer *)player volumeStateChanged:(int)volume
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    //[[NSNotificationCenter defaultCenter] postNotificationName:TYMAllPlayVolumeStateChanged object:self userInfo:@{@"id" : player.playerID, @"type" : TYMAllPlayNotificationEntityPlayer , @"volume" : [NSNumber numberWithInt:volume]}];
}

- (void)playerManager:(APPlayerManager *)manager playerUpdateStarted:(APPlayer *)player
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)playerManager:(APPlayerManager *)manager zone:(APZone *)zone loopStateChanged:(APLoopMode)loopMode
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)playerManager:(APPlayerManager *)manager zone:(APZone *)zone playStateChanged:(APPlayerState)state
{
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:TYMAllPlayPlayStateChanged object:self userInfo:@{@"id" : zone.zoneID, @"zone" : [[TYMZone alloc] initWithZone:zone], @"type" : TYMAllPlayNotificationEntityZone , @"state" : [NSNumber numberWithInt:state]}];
    
    
    switch (state) {
        case APPlayerStateStopped:
        {
            NSLog(@"%@ - %@", NSStringFromSelector(_cmd), @"APPlayerStateStopped");
        }
            break;
        case APPlayerStatePlaying:
        {
            NSLog(@"%@ - %@", NSStringFromSelector(_cmd), @"APPlayerStatePlaying");
        }
            break;
        case APPlayerStateTransitioning:
        {
            NSLog(@"%@ - %@", NSStringFromSelector(_cmd), @"APPlayerStateTransitioning");
        }
            break;
        case APPlayerStatePaused:
        {
            NSLog(@"%@ - %@", NSStringFromSelector(_cmd), @"APPlayerStatePaused");
        }
            break;
        case APPlayerStateBuffering:
        {
            NSLog(@"%@ - %@", NSStringFromSelector(_cmd), @"APPlayerStateBuffering");
        }
            break;
            
        default:
            break;
    }
}

- (void)playerManager:(APPlayerManager *)manager zone:(APZone *)zone playbackErrorInIndex:(int)index error:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:TYMAllPlayPlaybackError object:self userInfo:@{@"id" : zone.zoneID, @"zone" : [[TYMZone alloc] initWithZone:zone], @"type" : TYMAllPlayNotificationEntityZone, @"index" : [NSNumber numberWithInt:index], @"error" : error}];
}

- (void)playerManager:(APPlayerManager *)manager zone:(APZone *)zone playlistChanged:(APPlaylist *)playlist
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:TYMAllPlayPlayListChanged object:self userInfo:@{@"id" : zone.zoneID, @"zone" : [[TYMZone alloc] initWithZone:zone], @"type" : TYMAllPlayNotificationEntityZone , @"playlist" : [[TYMPlaylist alloc] initWithPlaylist:playlist], @"zones" : [self zonesOfPlayerManager]}];
    
}

- (void)playerManager:(APPlayerManager *)manager zone:(APZone *)zone shuffleStateChanged:(APShuffleMode)shuffleMode
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)playerManager:(APPlayerManager *)manager zoneAdded:(APZone *)zone
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:TYMAllPlayZoneAdded object:self userInfo:@{@"id" : zone.zoneID, @"zone" : [[TYMZone alloc] initWithZone:zone], @"type" : TYMAllPlayNotificationEntityZone, @"zones" : [self zonesOfPlayerManager]}];
}

- (void)playerManager:(APPlayerManager *)manager zonePlayersListChanged:(APZone *)zone
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:TYMAllPlayZonePlayersListChanged object:self userInfo:@{@"id" : zone.zoneID, @"zone" : [[TYMZone alloc] initWithZone:zone], @"type" : TYMAllPlayNotificationEntityZone, @"zones" : [self zonesOfPlayerManager]}];
}

- (void)playerManager:(APPlayerManager *)manager zoneRemoved:(APZone *)zone
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:TYMAllPlayZoneRemoved object:self userInfo:@{@"id" : zone.zoneID, @"zone" : [[TYMZone alloc] initWithZone:zone], @"type" : TYMAllPlayNotificationEntityZone, @"zones" : [self zonesOfPlayerManager]}];
}

- (void)playerManager:(APPlayerManager *)manager zoneWithNewID:(APZone *)zone oldZoneID:(NSString *)oldZoneID
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


#pragma helper function

- (APPlayerManager*)playerManager
{
    NSString* applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    return [APPlayerManager sharedManagerWithApplicationName:applicationName];
}

@end
