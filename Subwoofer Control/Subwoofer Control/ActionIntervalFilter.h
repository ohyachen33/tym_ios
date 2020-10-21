//
//  ActionIntervalFilter.h
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 16/12/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ActionIntervalFilterDelegate

- (void)action:(NSDictionary*)userInfo;
- (void)filtered:(NSDictionary*)userInfo;

@end

@interface ActionIntervalFilter : NSObject

@property NSTimeInterval interval;

- (id)initWithDelegate:(id<ActionIntervalFilterDelegate>)delegate;
- (void)event:(NSDictionary*)userInfo;

@end
