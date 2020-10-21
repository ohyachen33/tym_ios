//
//  TASystem.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 29/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TASystem.h"

@interface TASystem()

@property(nonatomic, strong)id system;

@end

@implementation TASystem

- (id)initWithSystem:(id)system
{
    if(self = [super init])
    {
        self.system = system;
        return self;
    }
    
    return nil;
}

- (id)instance
{
    return self.system;
}

@end
