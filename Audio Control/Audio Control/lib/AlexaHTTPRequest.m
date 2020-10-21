//
//  AlexaHTTPRequest.m
//  Alexa
//
//  Created by Alain Hsu on 9/10/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "AlexaHTTPRequest.h"
#import "RequestBody.h"
#import <AFNetworking.h>
#import "HTTPManager.h"

#define DIRECTIVES          @"https://avs-alexa-na.amazon.com/v20160207/directives"
#define EVENTS              @"https://avs-alexa-na.amazon.com/v20160207/events"

#define SERVER_EQ_CLIENT    @"http://52.196.210.42:8080/DemoWebServer/eq/client"
#define SERVER_EQ_STATUS    @"http://52.196.210.42:8080/DemoWebServer/eq/status"
#define SERVER_EQ_ASK       @"http://52.196.210.42:8080/DemoWebServer/eq/ask"
#define SERVER_MUSIC_INFO   @"http://52.196.210.42:8080/DemoWebServer/music/status"

@implementation AlexaHTTPRequest

+(instancetype)shareInstance
{
    static AlexaHTTPRequest *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AlexaHTTPRequest alloc]init];
    });
    return manager;
}

-(NSMutableData *)fileData{
    if (!_fileData) {
        _fileData = [[NSMutableData alloc]init];
    }
    return _fileData;
}

//- (void)establishDownchannelStream:(httpSuccess)success failure:(httpFailure)failure
//{
//    NSString *authCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"userToken"];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:DIRECTIVES]
//                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
//                                                       timeoutInterval:10000.0];
//    [request setHTTPMethod:@"GET"];
//    [request setHTTPShouldHandleCookies:NO];
//    [request setValue:[NSString stringWithFormat:@"Bearer %@", authCode] forHTTPHeaderField:@"Authorization"];
//    
//    
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
//                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                                    NSLog(@"downchannel error:%@",error);
//                                                    NSLog(@"downchannel response == %@",response);
//
//                                                }];
//    
//    [dataTask resume];
//}

- (void)cancelDataTask {
    [dataTask cancel];
}


- (void)establishDownchannelStream:(httpSuccess)success failure:(httpFailure)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:SERVER_EQ_CLIENT]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10000.0];
    [request setHTTPMethod:@"GET"];
    
    dataTask = [[HTTPManager manager] dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"cancelled"]) {
                return ;
            }
            NSLog(@"downchannel error:%@",error);

        }else if(responseObject){
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            success(dic);
        }
        [self establishDownchannelStream:success failure:failure];
    }];
    [dataTask resume];
}

- (void)getServerStatus:(httpSuccess)success failure:(httpFailure)failure {
    [[HTTPManager manager] GET:SERVER_EQ_ASK parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        success(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)postTonescapeStatus:(NSDictionary*)status success:(httpSuccess)success failure:(httpFailure)failure {
    
//    AFHTTPSessionManager *AFSession = [AFHTTPSessionManager manager];
//    AFSession.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [[HTTPManager manager] POST:SERVER_EQ_STATUS parameters:status progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        success(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)postPlayingItem:(NSDictionary*)item success:(httpSuccess)success failure:(httpFailure)failure {
    
    [[HTTPManager manager] POST:SERVER_MUSIC_INFO parameters:item progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


- (void)requestSynchronizeState:(httpSuccess)success failure:(httpFailure)failure
{
    NSString *authCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"userToken"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:EVENTS]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", authCode] forHTTPHeaderField:@"Authorization"];
    NSString *boundary = [[NSUUID UUID] UUIDString];
    NSString *contenType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contenType forHTTPHeaderField:@"Content-Type"];
    
    NSData *postData = [RequestBody deployRequestBody:AVSSynchronizeStateAPI audioData:nil boundary:boundary];
    [request setHTTPBody:postData];
    
    NSURLSessionUploadTask *uploadTask = [[HTTPManager manager] uploadTaskWithRequest:request fromData:postData progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (error) {
                    failure(error);
                }else{
                    NSLog(@"Synchronize response==%@",response);
                    success(responseObject);
                }
    }];
    [uploadTask resume];
    
}


- (void)requestSpeechrecognizerwithAudio:(NSData *)audioData success:(httpSuccess)success failure:(httpFailure)failure
{
    NSString *authCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"userToken"];
    NSString *boundary = [[NSUUID UUID] UUIDString];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:EVENTS]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", authCode] forHTTPHeaderField:@"Authorization"];
    NSString *contenType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contenType forHTTPHeaderField:@"Content-Type"];
    
    NSData *postData = [RequestBody deployRequestBody:AVSSpeechRecognizerAPI audioData:audioData boundary:boundary];
    
    [request setHTTPBody:postData];
    
    
    NSURLSessionTask *uploadTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failure(error);
        }else{
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299) {
                    NSString *boundary2;
                    NSString *contentTypeHeader = httpResponse.allHeaderFields[@"Content-Type"];
                    NSRange ctbRange = [contentTypeHeader rangeOfString:@"boundary=.*?;" options:NSRegularExpressionSearch];
                    if (ctbRange.location != NSNotFound) {
                        NSString *boundaryNSS = [contentTypeHeader substringWithRange:ctbRange];
                        boundary2 = [boundaryNSS substringWithRange:NSMakeRange(9, boundaryNSS.length - 10)];
                    }
                    
                    if (boundary2) {
                        
                        ResponseObject *responseObj = [ResponseObject new];
                        [responseObj parseResponseData:data boundary:boundary2];
                        
                        success(responseObj);
                        
                    }else{
                        NSLog(@"data=%@\nresponse=%@\nerror=%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding],response,error);
                        
                        NSError *error2 = [NSError errorWithDomain:@"com.Alexa.Amazon" code:2 userInfo:@{NSLocalizedDescriptionKey:@"please speak more distinctly."}];
                        failure(error2);
                    }
                    
                }else{
                    NSError *error3 = [NSError errorWithDomain:@"com.Alexa.Amazon" code:2 userInfo:@{NSLocalizedDescriptionKey:@"request failed"}];
                    failure(error3);
                }
                
            }
        }
 
    }];
    
    [uploadTask resume];
}

- (void)requestSpeechSynthesizer:(NSString*)name token:(NSString*)token success:(httpSuccess)success failure:(httpFailure)failure
{
    NSString *authCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"userToken"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:EVENTS]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", authCode] forHTTPHeaderField:@"Authorization"];
    NSString *boundary = [[NSUUID UUID] UUIDString];
    NSString *contenType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contenType forHTTPHeaderField:@"Content-Type"];
    
    NSData *postData = [RequestBody deployRequestBody:AVSSpeechSynthesizerAPI name:name token:token boundary:boundary];
    [request setHTTPBody:postData];
    
    NSURLSessionUploadTask *uploadTask = [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"SpeechSynthesizer response:%@",response);
    }];
    [uploadTask resume];

}

//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
//    NSLog(@"session did receive challenge");
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        //        if ([trustedHosts containsObject:challenge.protectionSpace.host])
//        NSLog(@"equal; using credentials");
//        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//    }
//    //    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
//}
//
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *) task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
//    NSLog(@"in here task");
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        //        if ([trustedHosts containsObject:challenge.protectionSpace.host])
//        NSLog(@"equal; using credentials");
//        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//    }
//    //    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
//}

- (void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    //Without setting your completion handler to allow responses, you will not listen for responses. This is important.
    completionHandler(NSURLSessionResponseAllow);
    
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    //parse downchannel directives here.
}
@end
