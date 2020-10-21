//
//  PolarityPedalViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 28/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "PolarityPedalViewController.h"
#import "SystemManager.h"
#import "UnitLabel.h"
#import "ThemeUtils.h"

@interface PolarityPedalViewController ()

@property (nonatomic, strong) IBOutlet UISegmentedControl * segPolarity;

@end

@implementation PolarityPedalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateWithUserInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSegmentedControlChanged:(UISegmentedControl*)sender
{
    NSNumber* value = [NSNumber numberWithFloat:sender.selectedSegmentIndex];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyPolarity value:value completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.polarity = value;
        
    }];
}

- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    //update polarity
    CGFloat polarity = [[SystemManager sharedManager].systemSettings.polarity floatValue];
    
    self.segPolarity.selectedSegmentIndex = (NSUInteger)polarity;
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
