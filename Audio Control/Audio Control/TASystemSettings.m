//
//  TASystemSettings.m
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 19/8/15.
//  Copyright (c) 2015 primax. All rights reserved.
//

#import "TASystemSettings.h"

@implementation TASystemSettings

- (id)init
{
    if(self = [super init])
    {
        [self loadDefault];
    }
    
    return self;
}

- (void)loadDefault
{
    self.volume = @"12";

    self.connection = [NSNumber numberWithInteger:1];
    self.powerStatus = [NSNumber numberWithInteger:0];
    self.playStatus = [NSNumber numberWithInteger:0];
    
    self.EQx = [NSNumber numberWithInteger:0];
    self.EQy = [NSNumber numberWithInteger:0];
    self.EQz = [NSNumber numberWithInteger:0];
}

- (NSString*)description
{
    NSMutableString* description = [[NSMutableString alloc] init];
    
    [description appendString:[NSString stringWithFormat:@"volume: %@\n", self.volume]];

    [description appendString:[NSString stringWithFormat:@"connection: %@\n", self.connection]];
    [description appendString:[NSString stringWithFormat:@"sleep: %@\n", self.powerStatus]];
    [description appendString:[NSString stringWithFormat:@"controller: %@\n", self.playStatus]];

    [description appendString:[NSString stringWithFormat:@"EQx: %@\n", [self.EQx  stringValue]]];
    [description appendString:[NSString stringWithFormat:@"EQy: %@\n", [self.EQy stringValue]]];
    [description appendString:[NSString stringWithFormat:@"EQz: %@\n", [self.EQz stringValue]]];
    
    return description;
}

@end
