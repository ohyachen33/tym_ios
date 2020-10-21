//
//  PopItemButton.m
//  CustomButtonTest
//
//  Created by Alain Hsu on 7/12/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "PopItemButton.h"

@interface PopItemButton ()

@property (strong,nonatomic) UIImageView *backgroundImageView;
@property (strong,nonnull) UILabel *backgroundLabel;

@end

@implementation PopItemButton

-(instancetype)initWithImage:(UIImage *)image
            highlightedImage:(UIImage *)highlightedImage
             backgroundImage:(UIImage *)backgroundImage
  backgroundHighlightedImage:(UIImage *)backgroundHighlightedImage
{
    if (self = [super init]) {
        CGRect itemFrame = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height);
        
        if (!backgroundImage || !backgroundHighlightedImage) {
            itemFrame = CGRectMake(0, 0, image.size.width, image.size.height);
        }
        self.frame = itemFrame;
        
        [self setImage:backgroundImage forState:UIControlStateNormal];
        [self setImage:backgroundHighlightedImage forState:UIControlStateHighlighted];
        
        _backgroundImageView = [[UIImageView alloc]initWithImage:image
                                                highlightedImage:highlightedImage];
        
        _backgroundImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
        [self addSubview:_backgroundImageView];
        
        [self addTarget:_delegate action:@selector(itemButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(instancetype)initWithTittle:(NSString *)tittle
                  tittleColor:(UIColor *)color
              backgroundImage:(UIImage *)backgroundImage
   backgroundHighlightedImage:(UIImage *)backgroundHighlightedImage
{
    if (self = [super init]) {
        CGRect itemFrame = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height);
        
        if (!backgroundImage || !backgroundHighlightedImage) {
            itemFrame = CGRectMake(0, 0, 40, 40);
        }
        self.frame = itemFrame;
        
        [self setImage:backgroundImage forState:UIControlStateNormal];
        [self setImage:backgroundHighlightedImage forState:UIControlStateHighlighted];
        
        _backgroundLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40,40)];
        _backgroundLabel.backgroundColor = [UIColor lightGrayColor];
        _backgroundLabel.layer.cornerRadius = 20;
        _backgroundLabel.layer.masksToBounds = YES;
        _backgroundLabel.text = tittle;
        _backgroundLabel.textColor = color ?:[UIColor whiteColor];
        _backgroundLabel.textAlignment = NSTextAlignmentCenter;
        _backgroundLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_backgroundLabel];
        
        [self addTarget:_delegate action:@selector(itemButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


@end
