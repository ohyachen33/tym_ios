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
    self.display = [NSNumber numberWithInteger:0];
    self.timeout = [NSNumber numberWithInteger:10];
    self.standby = [NSNumber numberWithInteger:0];

    self.lowPassFrequency = [NSNumber numberWithInteger:80];
    self.lowPassSlope = [NSNumber numberWithInteger:12];
    self.lowPassOnOff = [NSNumber numberWithInteger:0];
    
    self.pEq1OnOff = [NSNumber numberWithInteger:0];
    self.pEq1Frequency = [NSNumber numberWithInteger:50];
    self.pEq1Boost = [NSNumber numberWithInteger:0];
    self.pEq1QFactor= [NSNumber numberWithInteger:1];
    
    self.pEq2OnOff = [NSNumber numberWithInteger:0];
    self.pEq2Frequency = [NSNumber numberWithInteger:50];
    self.pEq2Boost = [NSNumber numberWithInteger:0];
    self.pEq2QFactor= [NSNumber numberWithInteger:1];
    
    self.pEq3OnOff = [NSNumber numberWithInteger:0];
    self.pEq3Frequency = [NSNumber numberWithInteger:50];
    self.pEq3Boost = [NSNumber numberWithInteger:0];
    self.pEq3QFactor= [NSNumber numberWithInteger:1];

    self.rgcOnOff = [NSNumber numberWithInteger:0];
    self.rgcFrequency = [NSNumber numberWithInteger:25];
    self.rgcSlope = [NSNumber numberWithInteger:12];
    
    self.volume = @"-20";
    self.phase = [NSNumber numberWithInteger:0];
    self.polarity = [NSNumber numberWithInteger:0];
    self.tunning = [NSNumber numberWithInteger:20];
}

- (NSString*)description
{
    NSMutableString* description = [[NSMutableString alloc] init];
    
    [description appendString:[NSString stringWithFormat:@"display: %@\n", [self.display stringValue]]];
    [description appendString:[NSString stringWithFormat:@"timeout: %@\n", [self.timeout stringValue]]];
    [description appendString:[NSString stringWithFormat:@"standby: %@\n", [self.standby stringValue]]];
    
    [description appendString:[NSString stringWithFormat:@"lowPassFrequency: %@\n", [self.lowPassFrequency stringValue]]];
    [description appendString:[NSString stringWithFormat:@"lowPassSlope: %@\n", [self.lowPassSlope  stringValue]]];
    [description appendString:[NSString stringWithFormat:@"lowPassOnOff: %@\n", [self.lowPassOnOff stringValue]]];
    
    [description appendString:[NSString stringWithFormat:@"pEq1OnOff: %@\n", [self.pEq1OnOff stringValue]]];
    [description appendString:[NSString stringWithFormat:@"pEq1Frequency: %@\n", [self.pEq1Frequency  stringValue]]];
    [description appendString:[NSString stringWithFormat:@"pEq1Boost: %@\n", [self.pEq1Boost stringValue]]];
    [description appendString:[NSString stringWithFormat:@"pEq1QFactor: %@\n", [self.pEq1QFactor stringValue]]];
    
    [description appendString:[NSString stringWithFormat:@"pEq2OnOff: %@\n", [self.pEq2OnOff stringValue]]];
    [description appendString:[NSString stringWithFormat:@"pEq2Frequency: %@\n", [self.pEq2Frequency  stringValue]]];
    [description appendString:[NSString stringWithFormat:@"pEq2Boost: %@\n", [self.pEq2Boost stringValue]]];
    [description appendString:[NSString stringWithFormat:@"pEq2QFactor: %@\n", [self.pEq2QFactor stringValue]]];
    
    [description appendString:[NSString stringWithFormat:@"pEq3OnOff: %@\n", [self.pEq3OnOff stringValue]]];
    [description appendString:[NSString stringWithFormat:@"pEq3Frequency: %@\n", [self.pEq3Frequency  stringValue]]];
    [description appendString:[NSString stringWithFormat:@"pEq3Boost: %@\n", [self.pEq3Boost stringValue]]];
    [description appendString:[NSString stringWithFormat:@"pEq3QFactor: %@\n", [self.pEq3QFactor stringValue]]];
    
    [description appendString:[NSString stringWithFormat:@"rgcOnOff: %@\n", [self.rgcOnOff stringValue]]];
    [description appendString:[NSString stringWithFormat:@"rgcFrequency: %@\n", [self.rgcFrequency  stringValue]]];
    [description appendString:[NSString stringWithFormat:@"rgcSlope: %@\n", [self.rgcSlope stringValue]]];
    
    [description appendString:[NSString stringWithFormat:@"volume: %@\n", self.volume]];
    [description appendString:[NSString stringWithFormat:@"phase: %@\n", [self.phase  stringValue]]];
    [description appendString:[NSString stringWithFormat:@"polarity: %@\n", [self.polarity stringValue]]];
    [description appendString:[NSString stringWithFormat:@"tunning: %@\n", [self.tunning stringValue]]];
     
    return description;
}

@end
