//
//  ThemeUtils.h
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 28/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kColorMain [UIColor colorWithRed:252.0/255 green:37.0/255 blue:79.0/255 alpha:1.0]

@class IntervalSlider;
@class UnitLabel;
@protocol IntervalSliderDelegate;
@interface ThemeUtils : NSObject

+ (void)startTheme;

+ (void)themeUnitLabel:(UnitLabel*)label unit:(NSString*)unit;
+ (void)themeIntervalSlider:(IntervalSlider*)slider delegate:(id<IntervalSliderDelegate>)delegate;

+ (void)roundCorner:(UIView*)view;

@end
