//
//  ActionIntervalFilter.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 16/12/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "ActionIntervalFilter.h"

@interface ActionIntervalFilter()

@property (strong, nonatomic) NSDate* lastEventTimestamp;
@property (strong, nonatomic) id<ActionIntervalFilterDelegate> delegate;

@end

@implementation ActionIntervalFilter

- (id)initWithDelegate:(id<ActionIntervalFilterDelegate>)delegate
{
    if(self = [super init])
    {
        self.interval = 0;
        self.delegate = delegate;
    }
    
    return self;
}

- (void)event:(NSDictionary*)userInfo
{
    BOOL fire = NO;
    
    if(!self.lastEventTimestamp)
    {
        self.lastEventTimestamp = [NSDate date];
        fire = YES;
    }
    else{
        
        if(self.interval <= 0)
        {
            fire = YES;
            
        }else{
            
            NSDate* now = [NSDate date];
            NSTimeInterval diff =  [now timeIntervalSince1970] - [self.lastEventTimestamp timeIntervalSince1970];
            if(diff >= self.interval)
            {
                fire = YES;
            }
        }
    }
    
    if(fire)
    {
        [self fire:userInfo];
        
    }else{
        
        if(self.delegate)
        {
            [self.delegate filtered:userInfo];
        }
    }
}

- (void)fire:(NSDictionary*)userInfo
{
    self.lastEventTimestamp = [NSDate date];
    
    if(self.delegate)
    {
        [self.delegate action:userInfo];
    }
}

@end
