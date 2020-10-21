//
//  AlexaControl.h
//  Alexa
//
//  Created by Alain Hsu on 9/10/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlexaHTTPRequest.h"

@interface AlexaControl : NSObject

+(instancetype)shareInstance;

- (void)start:(httpSuccess)result failure:(httpFailure)error;

- (void)stop;

- (void)speakToAlexa:(NSData*)record success:(httpSuccess)success failure:(httpFailure)failure;

@end
