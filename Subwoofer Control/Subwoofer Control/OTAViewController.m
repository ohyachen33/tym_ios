//
//  OTAViewController.m
//  Subwoofer Control
//
//  Created by Alain Hsu on 14/12/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "OTAViewController.h"
#import "SystemManager.h"


@interface OTAViewController () {
    NSString* _path;
    NSString* _verison;
    id progressObserver;
}

@property (weak, nonatomic) IBOutlet UITextView *textview;

@end

@implementation OTAViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _path = [[NSBundle mainBundle] pathForResource:@"SVS_PB16_Ultra_hwDVT_swv6.0.3_Application_release_20170315" ofType:@"hex"];
    _verison = @"6.0.3";

    progressObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"otaProgressDidUpdate" object:nil queue:nil usingBlock:^(NSNotification*  _Nonnull note) {
        int percentage = [note.object intValue];
        [self.textview setText:[NSString stringWithFormat:@"Upgrading...%d%%",percentage]];
    }];
}

- (IBAction)hexFileChange:(id)sender {
    UISwitch *swi = sender;
    if (!swi.on) {
        _path = [[NSBundle mainBundle] pathForResource:@"SVS_PB16_Ultra_hwDVT_swv6.0.3_Application_release_20170315" ofType:@"hex"];
        _verison = @"6.0.3";
    }else{
        _path = [[NSBundle mainBundle] pathForResource:@"SVS_PB3000_hwES_swv1.0.4_Application_release_20170324" ofType:@"hex"];
        _verison = @"1.04";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:progressObserver];
}

- (IBAction)checkBtnTapped:(id)sender {

        if ([[SystemManager sharedManager].otaService checkFirmwareIsDFUMode:[SystemManager sharedManager].connectedSystem]) {
            NSLog(@"is DFU mode");
        }else{
            NSLog(@"is normal mode");
        }
}

- (IBAction)startTapped:(id)sender {
    [[SystemManager sharedManager].otaService system:[SystemManager sharedManager].connectedSystem startUpdateWithfile:_path];
}


- (IBAction)cleanBtnTapped:(id)sender {
    [[SystemManager sharedManager].otaService system:[SystemManager sharedManager].connectedSystem saveDFUDeviceWithFile:nil andVersion:nil];
    
    [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem enterDFUMode:^(id complete) {
        [[SystemManager sharedManager].otaService startMonitorACKOfSystem:[SystemManager sharedManager].connectedSystem];
    }];
}
- (IBAction)getProductNamebtnTapped:(id)sender {
    [[SystemManager sharedManager].otaService system:[SystemManager sharedManager].connectedSystem getProductName:^(NSString *name) {
        
        NSLog(@"=============%@====%lu============",name,(unsigned long)name.length);
    }];
}

@end
