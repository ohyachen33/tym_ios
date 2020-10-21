//
//  SwitchTableViewCell.m
//  TADemo
//
//  Created by Lam Yick Hong on 6/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

- (IBAction)onValueChanged:(id)sender
{
    if(self.delegate)
    {
        [self.delegate cell:self onSwitchChanged:self.switchButton];
    }
}

@end
