//
//  DiscoveryTableViewController.h
//  TADemo
//
//  Created by Lam Yick Hong on 11/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TAPlatform/TAPSystemService.h>

@interface DiscoveryTableViewController : UITableViewController <TAPSystemServiceDelegate>

@property (nonatomic, strong) NSDictionary* model;

@end
