/**************************************************************
 * Copyright (C) 2014, Qualcomm Connected Experiences, Inc.
 * All rights reserved. Confidential and Proprietary.
 **************************************************************/

#import <Foundation/Foundation.h>
#import "APMediaItem.h"

@class APPlaylistData;

/**
 Represents a playlist of AllPlay media items.
 */
@interface APPlaylist : NSObject <NSCoding> {
@private
	APPlaylistData * _data;
}
/**
 YES if the playlist was sent to the zone by you, based on your user data and your application name.
 */
@property (nonatomic, readonly) BOOL isMine;
/**
 The number of media items in this playlist.
 */
@property (nonatomic, readonly) int size;

/**
 A string for user data.
 */
@property (nonatomic, copy) NSString * userData;

/**
 Appends an APMediaItem to the end of the playlist.
 @param mediaItem The APMediaItem to append.
 */
- (void)appendMediaItem:(APMediaItem *)mediaItem;

/**
 Appends an APPlaylist to the end of the playlist.
 @param playlist The APPlaylist to append.
 */
- (void)appendPlaylist:(APPlaylist *)playlist;

/**
 Gets the APMediaItem at the specified index in the playlist.
 @param index The index of the APMediaItem to retrieve.
 @return The APMediaItem at the requested index.
 */
- (APMediaItem *)getMediaItemAtIndex:(int)index;

/**
 Inserts an APMediaItem into the playlist at the specified index.
 @param mediaItem The APMediaItem to insert.
 @param index The index at which to insert the APMediaItem.
 @return YES if insertion was successful.
 */
- (BOOL)insertMediaItem:(APMediaItem *)mediaItem atIndex:(int)index;

/**
 Inserts an APPlaylist into the playlist at the specified index.
 @param playlist The APPlaylist to insert
 @param index The index at which to insert the APPlaylist.
 @return YES if insertion was successful.
 */
- (BOOL)insertPlaylist:(APPlaylist *)playlist atIndex:(int)index;

/**
 Removes an APMediaItem from the playlist at the specified index.
 @param index The index of the APMediaItem to remove.
 @return YES if the item was removed successfully.
 */
- (BOOL)removeMediaItemAtIndex:(int)index;


/**
 Returns an APPlaylist initialized from the data in the coder. (This method is required to implement the NSCoding protocol.)
 @param coder An unarchiver object.
 */
- (id)initWithCoder:(NSCoder *)coder;

/**
 Encodes an APPlaylist using the specified archiver. (This method is required to implement the NSCoding protocol.)
 @param coder An archiver object.
 */
- (void)encodeWithCoder:(NSCoder *)coder;

@end
