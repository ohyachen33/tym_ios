//
//  TAProperty.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAProperty.h"
#import "TASignalType.h"


@implementation TAProperty

- (NSData*)dataBySignal:(TPSignal*)signal writeData:(NSData*)data
{
    return nil;
}

- (TPSignalType)signalType
{
    return TPSignalTypeTotalNumber;
}

- (NSString*)uuid
{
    return nil;
}

@end
