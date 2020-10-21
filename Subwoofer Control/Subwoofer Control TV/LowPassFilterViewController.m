//
//  LowPassFilterViewController.m
//  Subwoofer Control
//
//  Created by Alain Hsu on 16/5/10.
//  Copyright © 2016年 Tymphany. All rights reserved.
//

#import "LowPassFilterViewController.h"
#import "SystemManager.h"

@interface LowPassFilterViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *SwitchSegment;
@property (weak, nonatomic) IBOutlet UILabel *LFEModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *FREQLabel;
@property (weak, nonatomic) IBOutlet UIButton *FREQDownButton;
@property (weak, nonatomic) IBOutlet UIButton *FREQUpButton;
@property (weak, nonatomic) IBOutlet UIButton *SlopeAlertButton;

@end

@implementation LowPassFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateWithUserInfo:nil];
}

- (IBAction)switchChanged:(UISegmentedControl *)sender {
    NSNumber* value = [NSNumber numberWithInteger:sender.selectedSegmentIndex];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyLowPassOnOff value:value completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.lowPassOnOff = value;
        
    }];
    
    [self updateEnabling];
}

- (IBAction)onUpTapped:(id)sender {
    NSInteger value =[[SystemManager sharedManager].systemSettings.lowPassFrequency integerValue];
    NSNumber *val = [NSNumber numberWithInteger:MIN(value + 1, 200)];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyLowPassFrequency value:val completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.lowPassFrequency = val;
        
    }];
    [SystemManager sharedManager].systemSettings.lowPassFrequency = val;
    
    self.FREQLabel.text = [NSString stringWithFormat:@"%@Hz",val];

}
- (IBAction)onDownTapped:(id)sender {
    NSInteger value =[[SystemManager sharedManager].systemSettings.lowPassFrequency integerValue];
    NSNumber *val = [NSNumber numberWithInteger:MAX(value - 1, 30)];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyLowPassFrequency value:val completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.lowPassFrequency = val;
        
    }];
    [SystemManager sharedManager].systemSettings.lowPassFrequency = val;

    self.FREQLabel.text = [NSString stringWithFormat:@"%@Hz",val];}

- (IBAction)onSlopeTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SlOPE" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"6dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self uppdateSlopeWithValue:6];
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"12dB (DEFAULT)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self uppdateSlopeWithValue:12];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"18dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self uppdateSlopeWithValue:18];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"24dB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self uppdateSlopeWithValue:24];
    }];
    
    [alert addAction:action0];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    //update on/off
    BOOL on = [[SystemManager sharedManager].systemSettings.lowPassOnOff boolValue];
    [self.SwitchSegment setSelectedSegmentIndex:on ? 1: 0];
    
    
    //update freq
    NSNumber* freq = [SystemManager sharedManager].systemSettings.lowPassFrequency;
    
    self.FREQLabel.text = [NSString stringWithFormat:@"%@Hz",freq];
    
    //update slope
    [self refreshSlope];
    
    //update ui enabling
    [self updateEnabling];
}

- (void)uppdateSlopeWithValue:(NSInteger)value
{
    [self.SlopeAlertButton setTitle:value == 12 ? [NSString stringWithFormat:@"%lddB (DEFAULT)",value] : [NSString stringWithFormat:@"%lddB",value] forState:0];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyLowPassSlope value:[NSNumber numberWithInteger:value] completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.lowPassSlope = [NSNumber numberWithInteger:value];
    }];
}

- (void)refreshSlope
{
    switch ([[SystemManager sharedManager].systemSettings.lowPassSlope intValue]) {
        case 6:
        {
            [self.SlopeAlertButton setTitle:@"6dB" forState:0];
        }
            break;
        case 12:
        {
            [self.SlopeAlertButton setTitle:@"12dB (DEFAULT)" forState:0];
        }
            break;
        case 18:
        {
            [self.SlopeAlertButton setTitle:@"18dB" forState:0];
        }
            break;
        case 24:
        {
            [self.SlopeAlertButton setTitle:@"24dB" forState:0];
        }
            break;
            
        default:
            break;
    }
}

- (void)updateEnabling
{
    if(self.SwitchSegment.selectedSegmentIndex == 1)
    {
        self.FREQDownButton.enabled = YES;
        self.FREQUpButton.enabled = YES;
        self.SlopeAlertButton.enabled = YES;
        self.FREQLabel.enabled = YES;
    }else{
        self.FREQDownButton.enabled = NO;
        self.FREQUpButton.enabled = NO;
        self.SlopeAlertButton.enabled = NO;
        self.FREQLabel.enabled = NO;
    }
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
