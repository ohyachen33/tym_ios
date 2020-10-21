//
//  SliderTableViewCell.h
//  TADemo
//
//  Created by Lam Yick Hong on 6/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SliderTableViewCellDelegate;

@interface SliderTableViewCell : UITableViewCell

@property (nonatomic, strong)IBOutlet UISlider* slider;
@property (nonatomic, strong)id<SliderTableViewCellDelegate> delegate;
@property NSTimeInterval interval;

@end

@protocol SliderTableViewCellDelegate

- (void)cell:(SliderTableViewCell*)cell onValueChanged:(id)sender;

@end
