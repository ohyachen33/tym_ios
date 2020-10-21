//
//  SwitchTableViewCell.h
//  TADemo
//
//  Created by Lam Yick Hong on 6/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchTableViewCellDelegate;

@interface SwitchTableViewCell : UITableViewCell

@property (nonatomic, strong)id<SwitchTableViewCellDelegate> delegate;
@property (nonatomic, strong)IBOutlet UILabel* lblTitle;
@property (nonatomic, strong)IBOutlet UISwitch* switchButton;

@end

@protocol SwitchTableViewCellDelegate

- (void)cell:(SwitchTableViewCell*)cell onSwitchChanged:(id)sender;

@end