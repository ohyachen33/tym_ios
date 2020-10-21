//
//  GetAccessTokenDelegate.m
//  AVSObjcFTW
//
//  Created by Luis Castillo on 5/9/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "AlexaGetAccessTokenDelegate.h"

@implementation AlexaGetAccessTokenDelegate

#pragma mark - results

-(void)requestDidSucceed:(APIResult *)apiResult
{
    if (apiResult.result) {
        [self.delegate alexa_accessTokenResult:YES accessToken:apiResult.result error:nil];
    }else{
        NSString *error = @"un-able to retrieve access token. unknown error";
        [self.delegate alexa_accessTokenResult:NO accessToken:nil error:error];
    }
}//eom

-(void)requestDidFail:(APIError *)errorResponse
{
    NSString *error = [NSString stringWithFormat:@"user not authorize. error:%@",errorResponse.error.message];
    [self.delegate alexa_accessTokenResult:NO accessToken:nil error:error];
}


@end
