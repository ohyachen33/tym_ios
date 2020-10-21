//
//  AlexaLogOutDelegate.m
//  AVSObjcFTW
//
//  Created by Luis Castillo on 6/7/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "AlexaLogOutDelegate.h"

@implementation AlexaLogOutDelegate

#pragma mark - results

-(void)requestDidSucceed:(APIResult *)apiResult
{
    if (apiResult.api == kAPIClearAuthorizationState) {
        [self.delegate logOutResult:YES error:nil];
    }else{
        NSString *error = apiResult.result;
        [self.delegate logOutResult:YES error:error];
    }
}//eom

-(void)requestDidFail:(APIError *)errorResponse
{
    NSString *error = errorResponse.description;
    [self.delegate logOutResult:NO error:error];
}

@end
