//
//  RangeSliderTableViewCell.m
//  TADemo
//
//  Created by Alain Hsu on 2018/11/13.
//  Copyright © 2018 Tymphany. All rights reserved.
//

#import "RangeSliderTableViewCell.h"

@interface RangeSliderTableViewCell()<SDRangeSliderViewDelegate>

@end

@implementation RangeSliderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.slider = [[SDRangeSliderView alloc] initWithFrame:CGRectMake(20, self.contentView.frame.size.height - 40, self.contentView.frame.size.width - 40, 0)];
    self.slider.delegate = self;
    [self.contentView addSubview:self.slider];
}

#pragma mark - SDRangeSliderViewDelegate
- (void)sliderValueDidChangedOfLeft:(double)left right:(double)right
{
    if (self.delegate) {
        [self.delegate cell:self onValueChangedFromLeft:left toRight:right];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
