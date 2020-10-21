//
//  VolumePedalViewController.h
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 26/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntervalSlider.h"
#import "ValueUpdateObservingViewController.h"

@interface VolumePedalViewController : ValueUpdateObservingViewController <IntervalSliderDelegate>

@end
