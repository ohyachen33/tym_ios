//
//  MarqueeView.h
//  Audio Control
//
//  Created by Alain Hsu on 05/07/2017.
//  Copyright © 2017 tymphanysz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarqueeView : UIView

#define MAQUEE_TEXTCOLOR [UIColor redColor]
#define MAQUEE_TEXTFONTSIZE 24
#define MAQUEE_SPEED 3

- (instancetype)initWithFrame:(CGRect)frame title:(NSString*)title;

- (void)start;
- (void)stop;

@end
