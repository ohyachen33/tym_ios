//
//  ParametricEQViewController.h
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 1/12/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "ValueUpdateObservingViewController.h"
#import "IntervalSlider.h"
#import "ActionIntervalFilter.h"

@interface ParametricEQViewController : ValueUpdateObservingViewController <IntervalSliderDelegate, ActionIntervalFilterDelegate, UIGestureRecognizerDelegate>

@end
