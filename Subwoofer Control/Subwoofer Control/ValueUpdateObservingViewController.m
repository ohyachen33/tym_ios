//
//  ValueUpdateObservingViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 27/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "ValueUpdateObservingViewController.h"
#import "SystemManager.h"

@interface ValueUpdateObservingViewController ()

@property (strong, nonatomic)id observer;

@end

@implementation ValueUpdateObservingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:SystemValueDidUpdate object:nil queue:nil usingBlock:^(NSNotification* note){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateWithUserInfo:[note userInfo]];
        });        
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

- (void)updateWithUserInfo:(NSDictionary*)userInfo
{
    NSLog(@"Please override this function");
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
