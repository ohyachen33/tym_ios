//
//  AuthorizeUserDelegate.m
//  AVSObjcFTW
//
//  Created by Luis Castillo on 5/9/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "AlexaAuthorizeUserDelegate.h"

@implementation AlexaAuthorizeUserDelegate


#pragma mark - results

-(void)requestDidSucceed:(APIResult *)apiResult
{
    if (apiResult.api == kAPIAuthorizeUser) {
        [self.delegate alexa_authorizationResult:YES error:nil];
    }else{
        NSString *error = @"un-able to authorize user";
        [self.delegate alexa_authorizationResult:NO error:error];
    }
}//eom

-(void)requestDidFail:(APIError *)errorResponse
{
    NSString *error = errorResponse.error.message;
    [self.delegate alexa_authorizationResult:NO error:error];
}//eom

@end
