//
//  FilterTableViewController.h
//  TADemo
//
//  Created by Alain Hsu on 2018/11/13.
//  Copyright © 2018 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FilterTableViewControllerDelegate  <NSObject>

- (void)didSetFilter:(BOOL)isOn from:(double)left to:(double)right;

@end

@interface FilterTableViewController : UITableViewController

@property (assign, nonatomic) BOOL filterIsOn;
@property (assign, nonatomic) double left;
@property (assign, nonatomic) double right;

@property (weak, nonatomic) id<FilterTableViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
