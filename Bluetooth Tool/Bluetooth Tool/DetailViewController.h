//
//  DetailViewController.h
//  Bluetooth Tool
//
//  Created by Lam Yick Hong on 1/7/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

