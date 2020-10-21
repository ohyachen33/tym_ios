//
//  DataDumpViewController.h
//  Bluetooth Tool
//
//  Created by Lam Yick Hong on 5/7/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TAPlatform/TAPBluetoothLowEnergyCentral.h>
#import <MessageUI/MessageUI.h>

@interface DataDumpViewController : UIViewController <TAPBluetoothLowEnergyCentralDelegate, MFMailComposeViewControllerDelegate>

@end
