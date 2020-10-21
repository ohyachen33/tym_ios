//
//  DetailViewController.h
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 5/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

