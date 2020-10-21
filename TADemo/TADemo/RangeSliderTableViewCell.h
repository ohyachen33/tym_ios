//
//  RangeSliderTableViewCell.h
//  TADemo
//
//  Created by Alain Hsu on 2018/11/13.
//  Copyright © 2018 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDRangeSliderView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RangeSliderTableViewCellDelegate;

@interface RangeSliderTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic)SDRangeSliderView *slider;
@property (nonatomic, strong)id<RangeSliderTableViewCellDelegate> delegate;

@end

@protocol RangeSliderTableViewCellDelegate

- (void)cell:(RangeSliderTableViewCell*)cell onValueChangedFromLeft:(double)leftValue toRight:(double)rightValue;

@end

NS_ASSUME_NONNULL_END
