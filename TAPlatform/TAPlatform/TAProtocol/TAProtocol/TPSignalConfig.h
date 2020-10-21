//
//  TPSignalConfig.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 24/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPSignalConfig : NSObject

+ (NSData*)dataForVolumeUp;
+ (NSData*)dataForVolumeDown;

+ (NSData*)dataForLoadPresetOne;
+ (NSData*)dataForLoadPresetTwo;
+ (NSData*)dataForLoadPresetThree;
+ (NSData*)dataForLoadPresetDefault;

+ (NSData*)dataForSavePresetOne;
+ (NSData*)dataForSavePresetTwo;
+ (NSData*)dataForSavePresetThree;

+ (NSData*)dataForFactoryReset;

+ (NSData*)dataForToggleScreen;

+ (NSData*)dataForDisplayLock;
@end
