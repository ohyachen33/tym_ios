//
//  FeatureTableViewController.h
//  TADemo
//
//  Created by Lam Yick Hong on 11/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TAPlatform/TAPSystemService.h>
#import <TAPlatform/TAPPlayControlService.h>
#import "SliderTableViewCell.h"

@interface FeatureTableViewController : UITableViewController <UIActionSheetDelegate, TAPSystemServiceDelegate, TAPPlayControlServiceDelegate, SliderTableViewCellDelegate>

@property (nonatomic, strong) TAPSystemService* systemService;
@property (nonatomic, strong) TAPPlayControlService* playControlService;
@property (nonatomic, strong) NSDictionary* model;
@property (nonatomic, strong) id system;
@property (strong, nonatomic) NSString* type;

@end
