//
//  TUIKnobDotStyleRenderer.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 10/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "TUIKnobDotStyleRenderer.h"

@implementation TUIKnobDotStyleRenderer

- (void)updatePointerShape
{
    UIBezierPath *pointer = [UIBezierPath bezierPath];
    //on the shape
    [pointer moveToPoint:CGPointMake(CGRectGetWidth(self.pointerLayer.bounds) - self.pointerLength - self.lineWidth/2.f,
                                     CGRectGetHeight(self.pointerLayer.bounds) / 2.f)];
    
    //point inward
    [pointer addLineToPoint:CGPointMake(CGRectGetWidth(self.pointerLayer.bounds) - self.pointerLength - self.lineWidth/2.f - 20,
                                        CGRectGetHeight(self.pointerLayer.bounds) / 2.f)];
    self.pointerLayer.path = [pointer CGPath];
}

@end
