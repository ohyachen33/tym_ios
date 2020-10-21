//
//  PedalCaseViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 6/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "PedalCaseViewController.h"
#import "VolumePedalView.h"
#import "VolumePedalViewController.h"

#define kAddAnimationDuration 0.8

@interface PedalCaseViewController ()

@property (nonatomic, strong) UIViewController* currentViewController;

@end

@implementation PedalCaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //TODO: init View
}

- (void)addPedalViewControllerByString:(NSString*)viewControllerName
{
    if(![self.currentViewController isKindOfClass:NSClassFromString(viewControllerName)])
    {
        UIViewController* newViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:viewControllerName];
        
        newViewController.view.frame = self.view.bounds;
        
        [self addChildViewController:newViewController];
        [newViewController didMoveToParentViewController:self];
        
        [self.view addSubview:newViewController.view];
        
        self.currentViewController = newViewController;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
