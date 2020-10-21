//
//  TPSignalReceiver.h
//  TPSignal
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TPSignalReceiverDelegate;

@interface TPSignalReceiver : NSObject

@property (nonatomic, strong) id delegate;

- (id) initWithDelegate:(id<TPSignalReceiverDelegate>)delegate;

- (void)pushRawData:(NSData *)raw_data;

- (int)integerFromReveresedData:(NSData*)data;
- (void)parseCompletePacket:(NSData *)complete_packet;

@end

@protocol TPSignalReceiverDelegate <NSObject>

@required

- (void)didParseDataPacket:(NSData*)data_packet type:(Byte)type;
- (void)didFailToParseDataPackage:(NSData*)data error:(NSError*)error;

@optional

@end