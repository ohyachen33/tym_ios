//
//  VolumePedalView.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 6/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "VolumePedalView.h"
#import "TUIKnob.h"

@interface VolumePedalView ()

@property (nonatomic, strong)TUIKnob* knobControl;

@end


@implementation VolumePedalView

- (void)awakeFromNib
{
    //[[NSBundle mainBundle]]
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        
        /*self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = self.frame.size.width / 20.0;
        
        self.knobControl = [[TUIKnob alloc] initWithFrame:CGRectMake(0, 0, 80, 80) style:TUIKnobStyleDotPointer];
        [self addSubview:self.knobControl];
        
        self.knobControl.lineWidth = 1.0;
        self.knobControl.pointerLength = 8.0;
        self.tintColor = [UIColor redColor];
        
        [_knobControl addObserver:self forKeyPath:@"value" options:0 context:NULL];
        
        // Hooks up the knob control
        [_knobControl addTarget:self
                         action:@selector(handleValueChanged:)
               forControlEvents:UIControlEventValueChanged];*/
        
    }
    
    return self;
}

- (IBAction)onVolumeSliderChanged:(UISlider*)slider
{
    NSLog(@"onVolumeSliderChanged");
    
    /*NSInteger value = slider.value;
     
     [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem writeVolume:value completion:^(id complete)
     {
     [self.volumeTextLabel value:value];
     }];*/
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
