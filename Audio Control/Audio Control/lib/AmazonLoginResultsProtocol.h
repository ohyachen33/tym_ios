//
//  AmazonLoginResultsDelegate.h
//  Alexa
//
//  Created by Alain Hsu on 9/12/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//
#import <Foundation/Foundation.h>
#ifndef AmazonLoginResultsDelegate_h
#define AmazonLoginResultsDelegate_h


#endif /* AmazonLoginResultsDelegate_h */
@protocol AmazonLoginResultsDelegate <NSObject>;

- (void)authorizationResult:(BOOL)success accessToken:(NSString*)accessToken error:(NSString*)error;
- (void)logOutResult:(BOOL)success error:(NSString*)error;

@end