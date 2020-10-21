//
//  PopItemButton.h
//  CustomButtonTest
//
//  Created by Alain Hsu on 7/12/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopItemButton;

@protocol PopItemButtonDelegate <NSObject>

- (void)itemButtonTapped:(PopItemButton *)itemButton;

@end

@interface PopItemButton : UIButton

@property (assign,nonatomic) NSUInteger index;
@property (weak,nonatomic) id<PopItemButtonDelegate> delegate;

-(instancetype)initWithImage:(UIImage *)image
            highlightedImage:(UIImage *)highlightedImage
             backgroundImage:(UIImage *)backgroundImage
  backgroundHighlightedImage:(UIImage *)backgroundHighlightedImage;

-(instancetype)initWithTittle:(NSString *)tittle
                  tittleColor:(UIColor *)color
              backgroundImage:(UIImage *)backgroundImage
   backgroundHighlightedImage:(UIImage *)backgroundHighlightedImage;

@end
