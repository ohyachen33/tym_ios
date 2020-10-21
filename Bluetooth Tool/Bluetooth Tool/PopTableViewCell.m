//
//  PopTableViewCell.m
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 23/9/15.
//  Copyright © 2015 primax. All rights reserved.
//

#import "PopTableViewCell.h"

@implementation PopTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //so even with the left image, the text will still center aligned
    if (self.imageView.image)
    {
        self.textLabel.frame = CGRectOffset(self.textLabel.frame, - (self.imageView.frame.size.width), 0);
    }
    
    if (self.selectedBackgroundView)
    {
        NSInteger halfPadding = 3.5;
        CGRect oldFrame = self.selectedBackgroundView.frame;
        
        CGRect newFrame = CGRectOffset(oldFrame, 0, halfPadding);
        newFrame = CGRectMake(newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height - halfPadding * 2);

        self.selectedBackgroundView.frame = newFrame;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
