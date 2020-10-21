//
//  TUIKnob.h
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 10/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "RWKnobControl.h"

typedef NS_ENUM (NSInteger, TUIKnobStyle)
{
    TUIKnobStyleDefault = 0,
    TUIKnobStyleDotPointer
};

@interface TUIKnob : RWKnobControl

- (id)initWithFrame:(CGRect)frame style:(TUIKnobStyle)style;

@end
