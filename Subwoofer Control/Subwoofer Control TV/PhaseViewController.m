//
//  PhaseViewController.m
//  Subwoofer Control
//
//  Created by Alain Hsu on 16/5/11.
//  Copyright © 2016年 Tymphany. All rights reserved.
//

#import "PhaseViewController.h"
#import "SystemManager.h"

@interface PhaseViewController ()
@property (weak, nonatomic) IBOutlet UILabel *phaseTextLabel;

@end

@implementation PhaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateWithUserInfo:nil];
}
- (IBAction)onDownTapped:(id)sender {
    NSInteger value =[[SystemManager sharedManager].systemSettings.phase integerValue];
    
    NSNumber *val = [NSNumber numberWithInteger:MAX(value - 1, 0)];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyPhase value:val completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.phase = val;
        
    }];
    
    [SystemManager sharedManager].systemSettings.phase = val;

    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",val]];
    NSMutableAttributedString *sign = [[NSMutableAttributedString alloc]initWithString:@"°"];
    [sign addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, 1)];
    [string appendAttributedString:sign];
    
    self.phaseTextLabel.attributedText = string;
}
- (IBAction)onUpTapped:(id)sender {
    NSInteger value = [[SystemManager sharedManager].systemSettings.phase integerValue];
    
    NSNumber *val = [NSNumber numberWithInteger:MIN(value + 1, 180)];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyPhase value:val completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.phase = val;
        
    }];
    
    [SystemManager sharedManager].systemSettings.phase = val;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",val]];
    NSMutableAttributedString *sign = [[NSMutableAttributedString alloc]initWithString:@"°"];
    [sign addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, 1)];
    [string appendAttributedString:sign];
    
    self.phaseTextLabel.attributedText = string;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    //update phase
    NSNumber* phase = [SystemManager sharedManager].systemSettings.phase;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",phase]];
    NSMutableAttributedString *sign = [[NSMutableAttributedString alloc]initWithString:@"°"];
    [sign addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, 1)];
    [string appendAttributedString:sign];
    
    self.phaseTextLabel.attributedText = string;
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
