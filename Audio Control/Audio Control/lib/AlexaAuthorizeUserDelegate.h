//
//  AuthorizeUserDelegate.h
//  AVSObjcFTW
//
//  Created by Luis Castillo on 5/9/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LoginWithAmazon/LoginWithAmazon.h>
#import "AmazonLoginProtocol.h"


@interface AlexaAuthorizeUserDelegate : NSObject<AIAuthenticationDelegate>

@property (nonatomic, weak) id<AmazonLoginDelegate> delegate;

@end
