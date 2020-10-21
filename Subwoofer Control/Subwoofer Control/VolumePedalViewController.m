//
//  VolumePedalViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 26/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "VolumePedalViewController.h"
#import "UnitLabel.h"
#import "SystemManager.h"
#import "ThemeUtils.h"

@interface VolumePedalViewController ()

@property (nonatomic, strong) IBOutlet IntervalSlider * volumeSlider;
@property (nonatomic, strong) IBOutlet UnitLabel * volumeTextLabel;

@end

@implementation VolumePedalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [ThemeUtils themeUnitLabel:self.volumeTextLabel unit:@"dB"];
    [ThemeUtils themeIntervalSlider:self.volumeSlider delegate:self];
    
    [self updateWithUserInfo:nil];
}

- (void)onValueChanged:(id)sender
{
    NSInteger value = ((UISlider*)sender).value;
    
    for (TAPSystem* connectedSystem in [SystemManager sharedManager].connectedSystems) {
        [[SystemManager sharedManager].playControlService system:connectedSystem writeVolume:value completion:^(id complete)
         {
             
         }];

    }
    
    [SystemManager sharedManager].systemSettings.volume = [NSNumber numberWithFloat:value];
    [self.volumeTextLabel value:[NSNumber numberWithFloat:value]];
    
}

- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    NSString* valueString = [SystemManager sharedManager].systemSettings.volume;
    NSNumber* value = [NSNumber numberWithFloat:[valueString floatValue]];
    
    [self.volumeTextLabel value:value];
    self.volumeSlider.value = [value floatValue];
}
- (IBAction)renameBtnTapped:(id)sender {
    [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem softwareVersion:^(NSString *verison) {
        
    }];
    
    [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem  productName:^(NSString *name) {
        
    }];
}
- (IBAction)loadPresetBtnTapped:(id)sender {
    [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem loadToCurrentFromPreset:@"1" completion:^(id complet){
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
