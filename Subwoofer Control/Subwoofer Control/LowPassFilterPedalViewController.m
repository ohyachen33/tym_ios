//
//  LowPassFilterPedalViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 27/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "LowPassFilterPedalViewController.h"
#import "UnitLabel.h"
#import "ThemeUtils.h"
#import "SystemManager.h"

@interface LowPassFilterPedalViewController()

@property (nonatomic, strong) IBOutlet IntervalSlider * frequencySlider;
@property (nonatomic, strong) IBOutlet UnitLabel * frequencyTextLabel;

@property (nonatomic, strong) IBOutlet UISwitch* swLowPass;
@property (nonatomic, strong) IBOutlet UISegmentedControl * slopeSegmentControl;

@end

@implementation LowPassFilterPedalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [ThemeUtils themeUnitLabel:self.frequencyTextLabel unit:@"Hz"];
    [ThemeUtils themeIntervalSlider:self.frequencySlider delegate:self];

    [self updateWithUserInfo:nil];
}

- (void)onValueChanged:(id)sender
{
    NSNumber* value = [NSNumber numberWithFloat:((UISlider*)sender).value];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyLowPassFrequency value:value completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.lowPassFrequency = value;
        
    }];
    
    [self.frequencyTextLabel value:value];
    
}

- (IBAction)onSwitch:(UISwitch*)sender
{
    NSNumber* value = [NSNumber numberWithBool:sender.on];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyLowPassOnOff value:value completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.lowPassOnOff = value;
        
    }];
    
    [self updateEnabling];
}

- (IBAction)onSegmentChanged:(UISegmentedControl*)sender
{
    NSInteger value = 6;
    
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            value = 6;
        }
            break;
        case 1:
        {
            value = 12;
        }
            break;
        case 2:
        {
            value =18;
        }
            break;
        case 3:
        {
            value = 24;
        }
            break;
            
        default:
            break;
    }
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyLowPassSlope value:[NSNumber numberWithInteger:value] completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.lowPassSlope = [NSNumber numberWithInteger:value];
        
    }];
    
}

- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    //update on/off
    BOOL on = [[SystemManager sharedManager].systemSettings.lowPassOnOff boolValue];
    [self.swLowPass setOn:on];
    
    
    //update freq
    NSNumber* freq = [SystemManager sharedManager].systemSettings.lowPassFrequency;
    
    [self.frequencyTextLabel value:freq];
    self.frequencySlider.value = [freq floatValue];
    
    //update slope
    [self refreshSlope];
    
    //update ui enabling
    [self updateEnabling];
}

- (void)refreshSlope
{
    switch ([[SystemManager sharedManager].systemSettings.lowPassSlope intValue]) {
        case 6:
        {
            [self.slopeSegmentControl setSelectedSegmentIndex:0];
        }
            break;
        case 12:
        {
            [self.slopeSegmentControl setSelectedSegmentIndex:1];
        }
            break;
        case 18:
        {
            [self.slopeSegmentControl setSelectedSegmentIndex:2];
        }
            break;
        case 24:
        {
            [self.slopeSegmentControl setSelectedSegmentIndex:3];
        }
            break;
            
        default:
            break;
    }
}

- (void)updateEnabling
{
    if(self.swLowPass.isOn)
    {
        self.frequencySlider.enabled = YES;
        self.slopeSegmentControl.enabled = YES;
        
    }else{
        self.frequencySlider.enabled = NO;
        self.slopeSegmentControl.enabled = NO;
    }
}

@end
