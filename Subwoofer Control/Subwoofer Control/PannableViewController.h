//
//  PannableViewController.h
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 5/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PannableViewController : UIViewController <UIGestureRecognizerDelegate>

- (void)panAway;
- (void)panBack;

@end
