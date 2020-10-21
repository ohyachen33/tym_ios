//
//  RequestBody.h
//  Alexa
//
//  Created by Alain Hsu on 9/12/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AlexaVoiceServiceAPI) {
    AVSSpeechRecognizerAPI = 0,
    AVSSynchronizeStateAPI,
    AVSSpeechSynthesizerAPI,
    AVSAlertsAPI,
    AVSAudioPlayerAPI,
    AVSPlaybackControllerAPI,
    AVSSpeakerAPI,
    AVSSystemAPI
};


@interface RequestBody : NSObject

+ (NSData*)deployRequestBody:(AlexaVoiceServiceAPI)api audioData:(NSData*)audioData boundary:(NSString*)boundary;

+ (NSData*)deployRequestBody:(AlexaVoiceServiceAPI)api name:(NSString*)name token:(NSString*)token boundary:(NSString*)boundary;


@end
