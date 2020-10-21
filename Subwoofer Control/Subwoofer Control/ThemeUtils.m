//
//  ThemeUtils.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 28/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeUtils.h"
#import "UnitLabel.h"
#import "IntervalSlider.h"

@implementation ThemeUtils

+ (void)startTheme
{
    [[UINavigationBar appearance] setTintColor:kColorMain];
    [[UIToolbar appearance] setTintColor:kColorMain];
    
    [[UISwitch appearance] setOnTintColor:kColorMain];
    [[UISwitch appearance] setTintColor:kColorMain];
    
    [[UISlider appearance] setTintColor:kColorMain];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"allplay_vol_controll_btn.png"] forState:UIControlStateNormal];
    [[UIProgressView appearance] setTintColor:kColorMain];
    [[UIButton appearance] setTintColor:kColorMain];
    
    [[UISegmentedControl appearance] setTintColor:kColorMain];
    [[UIStepper appearance] setTintColor:kColorMain];
}

+ (void)themeUnitLabel:(UnitLabel*)label unit:(NSString*)unit
{
    label.text = @"";
    
    label.valueFont = [UIFont systemFontOfSize:60];
    label.valueKern = 0;
    label.valueTextColor = [UIColor blackColor];
    
    label.unitFont = [UIFont systemFontOfSize:40];
    label.unitKern = 0;
    label.unitTextColor = [UIColor lightGrayColor];
    
    label.unit = unit;
}

+ (void)themeIntervalSlider:(IntervalSlider*)slider delegate:(id<IntervalSliderDelegate>)delegate
{
    slider.interval = 0.1;
    slider.delegate = delegate;
}

+ (void)roundCorner:(UIView*)view
{
    view.layer.cornerRadius = view.frame.size.width / 60.0;
}

@end
