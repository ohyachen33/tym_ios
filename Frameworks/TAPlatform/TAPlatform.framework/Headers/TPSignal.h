//
//  TPSignalSVS.h
//  TPSignal
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TASignalType.h"

#import "TAPProtocolAdaptor.h"

@protocol TPSignalDelegate;

@interface TPSignal : NSObject
//{
   //  id <TPSignalSVSDelegate> _delegate;
//}

@property (nonatomic, strong) id delegate;


- (id) initWithDelegate:(id<TPSignalDelegate>)delegate;

- (void) parseTPSignalPacket:(NSData *)received_packet;

//key
- (NSData*)keySignalWithKeyIdData:(NSData*)data type:(TPSignalType)type;

//read setting
- (NSData*)settingReadSignalWithType:(TPSignalType)type;
- (NSData*)settingReadSignalWithType:(TPSignalType)type size:(NSInteger)size;

//write setting
- (NSData*)settingWriteSignalWithData:(NSData*)data type:(TPSignalType)type;

//read string
- (NSData*)stringReadSignalWithType:(TPSignalStringType)type;

//write string
- (NSData*)stringWriteSignalWithData:(NSData*)data type:(TPSignalStringType)type;

//read feature
- (NSData*)featuresReadSignal;

//reset
- (NSData*)resetSignalWithType:(TPSignalType)type;

//enter DFU mode
- (NSData*)enterDFUModeSignal;

//read software version
- (NSData*)softwareVersionSignal;

//read product name
- (NSData*)productNameSignal;

- (TAPropertyType)propertyTypeFromSignalType:(TPSignalType)signalType;

@end

@protocol TPSignalDelegate <NSObject>

@required

@optional

- (void) didReceiveMessageItem:(NSData*)item type:(TPSignalType)sneakType;
- (void) didReceiveStringItem:(NSString*)item type:(TPSignalStringType)stringType;
- (void) didFailToParseItem:(NSData*)item error:(NSError*)error;

@end
