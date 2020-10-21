//
//  ControlViewController.h
//  BLE Remote
//
//  Created by Lam Yick Hong on 9/2/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TABluetoothLowEnergyCentral.h"
#import "TASystemService.h"

@interface ControlViewController : UIViewController <TABluetoothLowEnergyCentralDelegate, TASystemServiceDelegate>


@end
