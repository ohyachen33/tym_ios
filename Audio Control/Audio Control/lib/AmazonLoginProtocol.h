//
//  LoginProtocol.h
//  Alexa
//
//  Created by Alain Hsu on 9/12/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef LoginProtocol_h
#define LoginProtocol_h


#endif /* LoginProtocol_h */
@protocol AmazonLoginDelegate <NSObject>;

- (void)alexa_authorizationResult:(BOOL)success error:(NSString*)error;
- (void)alexa_accessTokenResult:(BOOL)success accessToken:(NSString*)accessToken error:(NSString*)error;
- (void)logOutResult:(BOOL)success error:(NSString*)error;

@end
