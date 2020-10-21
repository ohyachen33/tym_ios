//
//  MasterViewController.h
//  Bluetooth Tool
//
//  Created by Lam Yick Hong on 1/7/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataDumpViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DataDumpViewController *detailViewController;


@end

