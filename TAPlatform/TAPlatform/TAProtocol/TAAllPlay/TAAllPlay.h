//
//  TAAllPlay.h
//  TAAllPlay
//
//  Created by Lam Yick Hong on 2/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AllPlayControllerSDK/APPlayerManager.h>

@interface TAAllPlay : NSObject <APPlayerManagerDelegate>

/** Initializes and returns a newly allocated HTTP Server wrapper object with the specified config.
 
 @param delegate a object that implement the APPlayerManagerDelegate to receive callback.
 @return An initialized AllPlay wrapper object or nil if the object couldn't be created.
 */
- (id)initWithDelegate:(id<APPlayerManagerDelegate>)delegate;

- (void)start;
- (void)stop;

@end
