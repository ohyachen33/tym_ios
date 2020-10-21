//
//  AmazonLoginDelegate.m
//  Alexa
//
//  Created by Alain Hsu on 9/12/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "AmazonLoginDelegate.h"

@implementation AmazonLoginDelegate

+(instancetype)sharedInstance
{
    static AmazonLoginDelegate *delegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [[AmazonLoginDelegate alloc]init];
    });
    return delegate;

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegate_AlexaAuthorize = [AlexaAuthorizeUserDelegate new];
        _delegate_accessToken = [AlexaGetAccessTokenDelegate new];
        _delegate_logout = [AlexaLogOutDelegate new];
        _delegate_AlexaAuthorize.delegate = self;
        _delegate_accessToken.delegate = self;
        _delegate_logout.delegate = self;
        
        productID = @"com_tymphany_audio_control"; /* can be obtained at amazon developer website, the Device Type ID of the app */
        alexa_requestScope = [NSArray arrayWithObjects:@"alexa:all", nil];
        uniqueDeviceSerialNumber = [[NSUUID UUID]UUIDString];
        
        NSString *scopeData = [NSString stringWithFormat:@"{\"alexa:all\":{\"productID\":\"%@\", "
                               "\"productInstanceAttributes\":{\"deviceSerialNumber\":\"%@\"}}}",
                               productID, uniqueDeviceSerialNumber];
        alexa_options = @{kAIOptionScopeData:scopeData};
        
    }
    return self;
}

- (void)checkAlexaUserStatus
{
    [self requestAlexaAccessTokens];
}

- (void)requestAlexaAccessTokens
{
    [AIMobileLib getAccessTokenForScopes:alexa_requestScope withOverrideParams:nil delegate:_delegate_accessToken];
}

- (void)requestALEXAauth
{
    [AIMobileLib authorizeUserForScopes:alexa_requestScope delegate:_delegate_AlexaAuthorize options:alexa_options];
}

- (void)requestLogOut
{
    [AIMobileLib clearAuthorizationState:_delegate_logout];
}

#pragma mark -AmazonLoginDelegate

- (void)alexa_accessTokenResult:(BOOL)success accessToken:(NSString *)accessToken error:(NSString *)error
{
    [self.delegate authorizationResult:success accessToken:accessToken error:error];
}

- (void)alexa_authorizationResult:(BOOL)success error:(NSString *)error
{
    if (success) {
        [self requestAlexaAccessTokens];
    }else{
        [self.delegate authorizationResult:NO accessToken:nil error:error];
    }
}

-(void)logOutResult:(BOOL)success error:(NSString *)error
{
    [self.delegate logOutResult:success error:error];
}

@end
