/**************************************************************
 * Copyright (C) 2014, Qualcomm Connected Experiences, Inc.
 * All rights reserved. Confidential and Proprietary.
 **************************************************************/

#import <Foundation/Foundation.h>

@class APMediaItemData;

/**
  Represents an AllPlay media item, including its associated metadata.
 */
@interface APMediaItem : NSObject <NSCoding> {
@private
	APMediaItemData * _data;
}
/**
 YES if this media item is empty.
 */
@property (nonatomic, readonly) BOOL isEmpty;
/**
 The stream URL of the media item.
 */
@property (nonatomic, copy) NSString * streamURL;
/**
 The title of the media item.
 */
@property (nonatomic, copy) NSString * title;
/**
 The subtitle of the media item.
 */
@property (nonatomic, copy) NSString * subTitle;
/**
 The artist name of the media item.
 */
@property (nonatomic, copy) NSString * artist;
/**
 The album name of the media item.
 */
@property (nonatomic, copy) NSString * album;
/**
 The genre of the media item.
 */
@property (nonatomic, copy) NSString * genre;
/**
 The country of the media item.
 */
@property (nonatomic, copy) NSString * country;
/**
 The channel of the media item.
 */
@property (nonatomic, copy) NSString * channel;
/**
 The description of the media item.
 */
@property (nonatomic, copy) NSString * itemDescription;
/**
 The thumbnail URL of the media item. 
 */
@property (nonatomic, copy) NSString * thumbnailUrl;
/**
 The duration of the media item, in milliseconds.
 */
@property (nonatomic) int duration;
/**
 User-defined data for the media item.
 */
@property (nonatomic, copy) NSString * userData; /**< User defined data */
/**
 The content source of the media item.
 */
@property (nonatomic, copy) NSString * contentSource;
/**
 The medium description of the media item.
 */
@property (nonatomic, copy) NSString * mediumDescription;

/**
 Initializes a media item.
 @param title The media item's title.
 @param streamURL The media item's stream URL.
 */
- (id)initWithTitle:(NSString *)title streamURL:(NSString *)streamURL;

/**
 Returns YES if this MediaItem is equivalent to the other MediaItem.
 @param other The MediaItem to compare to this media item.
 */
- (BOOL)isEqualToItem:(APMediaItem *)other;

/**
 Returns an APMediaItem initialized from the data in the coder. (This method is required to implement the NSCoding protocol.)
 @param coder An unarchiver object.
 */
- (id)initWithCoder:(NSCoder *)coder;

/**
 Encodes an APMediaItem using the specified archiver. (This method is required to implement the NSCoding protocol.)
 @param coder An archiver object.
 */
- (void)encodeWithCoder:(NSCoder *)coder;

@end
