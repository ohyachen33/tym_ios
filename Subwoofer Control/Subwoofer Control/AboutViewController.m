//
//  AboutViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 4/12/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (nonatomic, strong) IBOutlet UILabel* lblNameAndVersion;


@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString* appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString* versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    self.lblNameAndVersion.text = [NSString stringWithFormat:@"%@ v%@ (%@)", appName, versionNumber, buildNumber];
    
}

@end
