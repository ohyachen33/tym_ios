//
//  SliderTableViewCell.m
//  TADemo
//
//  Created by Lam Yick Hong on 6/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "SliderTableViewCell.h"

@interface SliderTableViewCell()

@property NSDate* lastEventTimestamp;

@end

@implementation SliderTableViewCell

-(void)awakeFromNib
{
    self.interval = 0;
}

-(IBAction)onValueChanged:(id)sender
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
        [self fire];
    }
    
    
}

- (void)fire
{
    self.lastEventTimestamp = [NSDate date];
    
    if(self.delegate)
    {
        [self.delegate cell:self onValueChanged:self.slider];
    }
}

@end
