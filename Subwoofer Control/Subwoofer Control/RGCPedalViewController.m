//
//  RGCPedalViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 28/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "RGCPedalViewController.h"
#import "SystemManager.h"

@interface RGCPedalViewController ()

@property (nonatomic, strong) IBOutlet UISwitch* swOnOff;
@property (nonatomic, strong) IBOutlet UISegmentedControl * segSlope;
@property (nonatomic, strong) IBOutlet UISegmentedControl * segFrequency;

@end

@implementation RGCPedalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateWithUserInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSwitch:(UISwitch*)sender
{
    NSNumber* value = [NSNumber numberWithBool:sender.on];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyRGCOnOff value:value completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.rgcOnOff = value;
        
    }];
    
    [self updateEnabling];
}

- (IBAction)onFreqencyChange:(UISegmentedControl*)sender
{
    NSInteger freq = 25;
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            freq = 25;
        }
            break;
        case 1:
        {
            freq = 31;
        }
            break;
        case 2:
        {
            freq = 40;
        }
            break;
            
        default:
            break;
    }
    
    NSNumber* value = [NSNumber numberWithInteger:freq];
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyRGCFrequency value:value completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.rgcFrequency = value;
        
    }];
}

- (IBAction)onSlopeChange:(UISegmentedControl*)sender
{
    NSInteger slope = 6;
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            slope = 6;
        }
            break;
        case 1:
        {
            slope = 12;
        }
            break;
        default:
            break;
    }
    
    NSNumber* value = [NSNumber numberWithInteger:slope];
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyRGCSlope value:value completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.rgcSlope = value;
        
    }];
}

- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    //update polarity
    BOOL onoff = [[SystemManager sharedManager].systemSettings.rgcOnOff boolValue];
    [self.swOnOff setOn:onoff];
    
    [self refreshFrequency:[[SystemManager sharedManager].systemSettings.rgcFrequency integerValue]];
    [self refreshSlope:[[SystemManager sharedManager].systemSettings.rgcSlope integerValue]];
    
    [self updateEnabling];
}

- (void)refreshFrequency:(NSInteger)freq
{
    switch (freq) {
        case 25:
        {
            [self.segFrequency setSelectedSegmentIndex:0];
        }
            break;
        case 31:
        {
            [self.segFrequency setSelectedSegmentIndex:1];
        }
            break;
        case 40:
        {
            [self.segFrequency setSelectedSegmentIndex:2];
        }
            break;
            
        default:
            break;
    }
}

- (void)refreshSlope:(NSInteger)slope
{
    switch (slope) {
        case 6:
        {
            [self.segSlope setSelectedSegmentIndex:0];
        }
            break;
        case 12:
        {
            [self.segSlope setSelectedSegmentIndex:1];
        }
            break;
        default:
            break;
    }
}

- (void)updateEnabling
{
    if(self.swOnOff.isOn)
    {
        self.segFrequency.enabled = YES;
        self.segSlope.enabled = YES;
        
    }else{
        self.segFrequency.enabled = NO;
        self.segSlope.enabled = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
