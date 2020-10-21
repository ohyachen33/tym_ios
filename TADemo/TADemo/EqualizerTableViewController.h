//
//  EqualizerTableViewController.h
//  TADemo
//
//  Created by Lam Yick Hong on 6/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TAPlatform/TAPDigitalSignalProcessingService.h>
#import "SliderTableViewCell.h"
#import "SwitchTableViewCell.h"

@interface EqualizerTableViewController : UITableViewController<TAPDigitalSignalProcessingServiceDelegate, SliderTableViewCellDelegate, SwitchTableViewCellDelegate>

@property (nonatomic, strong) TAPDigitalSignalProcessingService* dspService;
@property (nonatomic, strong) id system;
@property (strong, nonatomic) NSString* type;

@end
