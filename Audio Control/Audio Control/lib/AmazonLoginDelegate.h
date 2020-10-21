//
//  AmazonLoginDelegate.h
//  Alexa
//
//  Created by Alain Hsu on 9/12/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LoginWithAmazon/LoginWithAmazon.h>
#import "AlexaAuthorizeUserDelegate.h"
#import "AlexaGetAccessTokenDelegate.h"
#import "AlexaLogOutDelegate.h"
#import "AmazonLoginProtocol.h"
#import "AmazonLoginResultsProtocol.h"

@interface AmazonLoginDelegate : NSObject<AmazonLoginDelegate>{
    AlexaAuthorizeUserDelegate *_delegate_AlexaAuthorize;
    AlexaGetAccessTokenDelegate *_delegate_accessToken;
    AlexaLogOutDelegate *_delegate_logout;
    
    NSString *productID;
    NSString *uniqueDeviceSerialNumber;
    NSArray *alexa_requestScope;
    NSDictionary *alexa_options;
}

@property (nonatomic, weak) id<AmazonLoginResultsDelegate> delegate;

+(instancetype)sharedInstance;

- (void)checkAlexaUserStatus;

- (void)requestALEXAauth;

- (void)requestLogOut;

@end
