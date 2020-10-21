//
//  PEQPlot.h
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 16/9/15.
//  Copyright (c) 2015 primax. All rights reserved.
//

#import "CurvedScatterPlot.h"

@interface PEQPlot : CurvedScatterPlot

@property (nonatomic, strong) NSMutableArray* peqSettings;
@property NSUInteger selectedIndex;

@property (nonatomic, strong) UIColor* enableColour;
@property (nonatomic, strong) UIColor* disableColor;
@property (nonatomic, strong) UIColor* selectedColor;
@property (nonatomic, strong) UIColor* totalColor;

- (void)updateGraph;
- (void)valueOfPoint:(CGPoint)point freq:(CGFloat*)freq boost:(CGFloat*)boost;
- (CGPoint)pointOfPeakOfIndex:(NSInteger)index;

@end
