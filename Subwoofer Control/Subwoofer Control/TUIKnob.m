//
//  TUIKnob.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 10/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "TUIKnob.h"
#import "TUIKnobDotStyleRenderer.h"

@interface TUIKnob()

@property TUIKnobStyle style;

@end

@implementation TUIKnob

- (id)initWithFrame:(CGRect)frame style:(TUIKnobStyle)style
{
    if(self = [super initWithFrame:frame])
    {
        self.style = style;
    }
    
    return self;
}

- (RWKnobRenderer*)createRenderer
{
    RWKnobRenderer* renderer;
    
    if(self.style == TUIKnobStyleDotPointer)
    {
        renderer = [[TUIKnobDotStyleRenderer alloc] init];
    }else{
        renderer = [[RWKnobRenderer alloc] init];
    }
    
    return renderer;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
