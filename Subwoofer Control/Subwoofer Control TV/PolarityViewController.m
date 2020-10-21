//
//  PolarityViewController.m
//  Subwoofer Control
//
//  Created by Alain Hsu on 6/24/16.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "PolarityViewController.h"
#import "SystemManager.h"

@interface PolarityViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *seg;

@end

@implementation PolarityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateWithUserInfo:nil];

}
- (IBAction)segmentDidChange:(UISegmentedControl*)sender {
    
    NSNumber* value = [NSNumber numberWithFloat:sender.selectedSegmentIndex];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:TAPDigitalSignalProcessingKeyPolarity value:value completion:^(id completion) {
        
        [SystemManager sharedManager].systemSettings.polarity = value;
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    //update polarity
    CGFloat polarity = [[SystemManager sharedManager].systemSettings.polarity floatValue];
    
    self.seg.selectedSegmentIndex = (NSUInteger)polarity;
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
