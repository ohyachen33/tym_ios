//
//  AlexaHTTPRequest.h
//  Alexa
//
//  Created by Alain Hsu on 9/10/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseObject.h"

typedef void(^httpSuccess)(id responseObj);
typedef void(^httpFailure)(NSError *error);

@interface AlexaHTTPRequest : NSObject<NSURLSessionTaskDelegate,NSURLSessionDelegate,NSURLConnectionDataDelegate>{
    NSURLSessionDataTask *dataTask;
}
@property (nonatomic, strong) NSMutableData *fileData;

+(instancetype)shareInstance;

- (void)cancelDataTask;

- (void)establishDownchannelStream:(httpSuccess)success failure:(httpFailure)failure;

- (void)getServerStatus:(httpSuccess)success failure:(httpFailure)failure;

- (void)postTonescapeStatus:(NSDictionary*)status success:(httpSuccess)success failure:(httpFailure)failure;

- (void)postPlayingItem:(NSDictionary*)item success:(httpSuccess)success failure:(httpFailure)failure;

- (void)requestSynchronizeState:(httpSuccess)success failure:(httpFailure)failure;

- (void)requestSpeechrecognizerwithAudio:(NSData*)audioData success:(httpSuccess)success failure:(httpFailure)failure;

- (void)requestSpeechSynthesizer:(NSString*)name token:(NSString*)token success:(httpSuccess)success failure:(httpFailure)failure;

@end
