//
//  ConnectionTestTableViewController.h
//  BLE Remote
//
//  Created by Lam Yick Hong on 12/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TABluetoothLowEnergyCentral.h"

@interface ConnectionTestTableViewController : UITableViewController <TABluetoothLowEnergyCentralDelegate, UIActionSheetDelegate>

@end
