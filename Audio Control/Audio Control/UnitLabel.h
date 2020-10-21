//
//  UnitLabel.h
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 20/10/2015.
//  Copyright © 2015 primax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnitLabel : UILabel

@property (nonatomic, strong) NSString* unit;

@property (nonatomic, strong) UIFont* valueFont;
@property (nonatomic, strong) UIFont* unitFont;

@property (nonatomic, strong) UIColor* valueTextColor;
@property (nonatomic, strong) UIColor* unitTextColor;

@property (nonatomic, strong) NSNumberFormatter* numberFormatter;

@property CGFloat valueKern;
@property CGFloat unitKern;

@property BOOL phaseStyle;

- (NSString*)valueString;

- (NSNumber*)value;
- (void)value:(NSNumber*)value;

@end
