//
//  VolumeViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 5/1/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "VolumeViewController.h"
#import "SystemManager.h"

@interface VolumeViewController ()

@property (nonatomic, strong) IBOutlet UILabel* lblVolume;

@end

@implementation VolumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateWithUserInfo:nil];
}


- (IBAction)onUpTapped:(id)sender
{
    NSString* valueString = [SystemManager sharedManager].systemSettings.volume;
    
    NSInteger val = MIN([valueString integerValue] + 1, 0);
    
    [[SystemManager sharedManager].playControlService volumeUpSystem:[SystemManager sharedManager].connectedSystem completion:^(id complete)
     {
         
     }];
    
    valueString = [NSString stringWithFormat:@"%ld", (long)val];
    
    [SystemManager sharedManager].systemSettings.volume = valueString;
    self.lblVolume.text = [NSString stringWithFormat:@"%@dB", valueString];
    //[self updateWithUserInfo:nil];
}

- (IBAction)onDownTapped:(id)sender
{
    NSString* valueString = [SystemManager sharedManager].systemSettings.volume;
    
    NSInteger val = MAX([valueString integerValue] - 1, -60);
    
    [[SystemManager sharedManager].playControlService volumeDownSystem:[SystemManager sharedManager].connectedSystem completion:^(id complete)
     {
         
     }];
    
    valueString = [NSString stringWithFormat:@"%ld", (long)val];
    
    [SystemManager sharedManager].systemSettings.volume = valueString;
    self.lblVolume.text = [NSString stringWithFormat:@"%@dB", valueString];
    //[self updateWithUserInfo:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    NSString* valueString = [SystemManager sharedManager].systemSettings.volume;
    NSNumber* value = [NSNumber numberWithFloat:[valueString floatValue]];
    
    self.lblVolume.text = [NSString stringWithFormat:@"%@dB", valueString];
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
