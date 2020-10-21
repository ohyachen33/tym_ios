//
//  IntervalSlider.h
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 26/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IntervalSliderDelegate;

@interface IntervalSlider : UISlider

@property NSTimeInterval interval;

@property (nonatomic, strong)id<IntervalSliderDelegate> delegate;

@end


@protocol IntervalSliderDelegate

- (void)onValueChanged:(id)sender;

@end
