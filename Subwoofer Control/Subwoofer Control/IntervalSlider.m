//
//  IntervalSlider.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 26/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "IntervalSlider.h"

@interface IntervalSlider()

@property NSDate* lastEventTimestamp;

@end

@implementation IntervalSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib
{
    self.interval = 0;
    [super addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)onValueChanged:(id)sender
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
        [self.delegate onValueChanged:self];
    }
}

@end
