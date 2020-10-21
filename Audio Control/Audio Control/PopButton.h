//
//  PopButton.h
//  CustomButtonTest
//
//  Created by Alain Hsu on 7/12/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "PopItemButton.h"

@import UIKit;
@import QuartzCore;
@import AudioToolbox;

@class PopButton;

typedef NS_ENUM(NSUInteger, PopButtonBloomDirection) {
    
    PopButtonBloomDirectionTop = 1,
    PopButtonBloomDirectionTopLeft = 2,
    PopButtonBloomDirectionLeft = 3,
    PopButtonBloomDirectionBottomLeft = 4,
    PopButtonBloomDirectionBottom = 5,
    PopButtonBloomDirectionBottomRight = 6,
    PopButtonBloomDirectionRight = 7,
    PopButtonBloomDirectionTopRight = 8,
    
};

@protocol PopButtonDelegate <NSObject>

- (void)popButton:(PopButton *)popButton clickItemButtonAtIndex:(NSUInteger)itemButonIndex;

@optional
- (void)willPresentPopButtonItems:(PopButton *)popButton;
- (void)didPresentPopButtonItems:(PopButton *)popButton;

- (void)willDismissPopButtonItems:(PopButton *)popButton;
- (void)didDismissPopButtonItems:(PopButton *)popButton;

@end




@interface PopButton : UIView<UIGestureRecognizerDelegate>

@property (weak,nonatomic) id<PopButtonDelegate> delegate;

@property (assign, nonatomic) NSTimeInterval basicDuration;
@property (assign, nonatomic) BOOL allowSubItemRotation;

@property (assign, nonatomic) CGFloat bloomRadius;
@property (assign, nonatomic) CGFloat bloomAngel;
@property (assign, nonatomic) CGPoint buttonCenter;

@property (assign, nonatomic) BOOL allowSounds;

@property (copy, nonatomic) NSString *bloomSoundPath;
@property (copy, nonatomic) NSString *foldSoundPath;
@property (copy, nonatomic) NSString *itemSoundPath;

@property (assign, nonatomic) BOOL allowCenterButtonRotation;

@property (strong, nonatomic) UIColor *bottomViewColor;

@property (assign, nonatomic) PopButtonBloomDirection bloomDirection;

-(instancetype)initWithFrame:(CGRect)frame
                 centerImage:(UIImage *)centerImage
            highlightedImage:(UIImage *)centerHighlightedImage;

-(instancetype)initWithCenterImage:(UIImage *)centerImage
                  highlightedImage:(UIImage *)centerHighlightedImage;

-(instancetype)initWithFrame:(CGRect)frame
                      tittle:(NSString *)tittle
                 tittleColor:(UIColor *)color;

- (void)addPathItems:(NSArray *)pathItemButtons;

- (void)setTittle:(NSString *)tittle andTittleColor:(UIColor *)color;

@end
