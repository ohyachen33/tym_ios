//
//  PhasePedalViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 28/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "PhasePedalViewController.h"
#import "SystemManager.h"
#import "UnitLabel.h"
#import "ThemeUtils.h"

@interface PhasePedalViewController ()

@property (nonatomic, strong) IBOutlet IntervalSlider * phaseSlider;
@property (nonatomic, strong) IBOutlet UnitLabel * phaseTextLabel;

@end

@implementation PhasePedalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [ThemeUtils themeUnitLabel:self.phaseTextLabel unit:@"°"];
    [ThemeUtils themeIntervalSlider:self.phaseSlider delegate:self];
    
    //extra style
    self.phaseTextLabel.phaseStyle = YES;
    
    [self updateWithUserInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onValueChanged:(id)sender
{
    NSNumber* value = [NSNumber numberWithFloat:((UISlider*)sender).value];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyPhase value:value completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.phase = value;
        
    }];
    
    [self.phaseTextLabel value:value];
    
}

- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    //update phase
    NSNumber* phase = [SystemManager sharedManager].systemSettings.phase;
    
    [self.phaseTextLabel value:phase];
    self.phaseSlider.value = [phase floatValue];
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
