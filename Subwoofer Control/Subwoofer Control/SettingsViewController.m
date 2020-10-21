//
//  SettingsViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 30/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "SettingsViewController.h"
#import "ThemeUtils.h"
#import "UnitLabel.h"
#import "SystemManager.h"

@interface SettingsViewController ()

@property (nonatomic, strong) IBOutlet UnitLabel * lblDisplayTime;
@property (nonatomic, strong) IBOutlet UIStepper * stepDisplayTime;
@property (nonatomic, strong) IBOutlet UISegmentedControl * segStandby;
@property (nonatomic, strong) IBOutlet UISegmentedControl * segDisplay;
@property (nonatomic, strong) IBOutlet UIButton * btnReset;


@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [ThemeUtils themeUnitLabel:self.lblDisplayTime unit:@"Sec"];
    
    [self updateWithUserInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onStandbySelected:(UISegmentedControl*)seg
{
    NSNumber* value = [NSNumber numberWithInteger:seg.selectedSegmentIndex];
    
    [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem writeSettingsType:TAPSystemKeyStandby value:value completion:^(id completion) {

    }];
}

- (IBAction)onDisplaySelected:(UISegmentedControl*)seg
{
    NSNumber* value = [NSNumber numberWithInteger:seg.selectedSegmentIndex];
    
    [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem writeSettingsType:TAPSystemKeyDisplay value:value completion:^(id completion) {
        
    }];
}

- (IBAction)onTimeoutStep:(UIStepper*)sender
{
    NSNumber* value = [NSNumber numberWithDouble:sender.value];
    
    [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem writeSettingsType:TAPSystemKeyTimeout value:value completion:^(id completion) {
        
    }];
    
    [self.lblDisplayTime value:value];
}

- (IBAction)onFactoryResetTapped:(id)sender
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Factory Reset" message:@"Are you sure? This will delete and reset all settings on the subwoofer." preferredStyle:UIAlertControllerStyleActionSheet];
    
    //reset button
    UIAlertAction* reset = [UIAlertAction actionWithTitle:@"Reset Now" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action){

        [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem factoryReset:^(id complete){
            
        }];
    }];
    
    //cancel button
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:reset];
    [alertController addAction:cancel];
    
    //display
    [self showViewController:alertController sender:self];
    
}

- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    NSInteger display = [[SystemManager sharedManager].systemSettings.display integerValue];
    
    [self.segDisplay setSelectedSegmentIndex:display];
    
    NSNumber* timeout = [SystemManager sharedManager].systemSettings.timeout;
    
    [self.lblDisplayTime value:timeout];
    self.stepDisplayTime.value = [timeout floatValue];
    
    NSInteger standby = [[SystemManager sharedManager].systemSettings.standby integerValue];
    
    [self.segStandby setSelectedSegmentIndex:standby];
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
