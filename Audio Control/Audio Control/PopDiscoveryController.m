//
//  PopDiscoveryController.m
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 7/4/2016.
//  Copyright © 2016 primax. All rights reserved.
//

#import "PopDiscoveryController.h"

@implementation PopDiscoveryController

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dismiss
{
    completionExitBlcok(-1);
    [self fadeOut];
}

@end
