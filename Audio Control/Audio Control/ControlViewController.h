//
//  ControlViewController.h
//  Audio Control
//
//  Created by Alain Hsu on 6/29/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TAPlatform/TAPSystemService.h>
#import <TAPlatform/TAPPlayControlService.h>

@interface ControlViewController : UIViewController<TAPSystemServiceDelegate, TAPPlayControlServiceDelegate>

@end
