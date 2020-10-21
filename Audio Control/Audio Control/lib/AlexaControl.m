//
//  AlexaControl.m
//  Alexa
//
//  Created by Alain Hsu on 9/10/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "AlexaControl.h"

@implementation AlexaControl

+(instancetype)shareInstance
{
    static AlexaControl *control = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        control = [AlexaControl new];
    });
    return control;
}

- (void)start:(httpSuccess)result failure:(httpFailure)error
{
    [[AlexaHTTPRequest shareInstance] establishDownchannelStream:^(id responseObj) {
        result(responseObj);
    } failure:^(NSError *err) {
        error(err);
    }];
    
    [[AlexaHTTPRequest shareInstance] requestSynchronizeState:^(id responseObj) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)stop
{
    [[AlexaHTTPRequest shareInstance] cancelDataTask];
}

- (void)speakToAlexa:(NSData *)record success:(httpSuccess)success failure:(httpFailure)failure
{
    [[AlexaHTTPRequest shareInstance] requestSpeechrecognizerwithAudio:record success:success failure:failure];
}


@end
