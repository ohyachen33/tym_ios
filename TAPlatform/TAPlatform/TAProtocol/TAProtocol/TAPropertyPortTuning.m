//
//  TAPropertyPortTuning.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertyPortTuning.h"
#import "TASignalType.h"

@implementation TAPropertyPortTuning

- (NSData*)dataBySignal:(TPSignal*)signal writeData:(NSData*)data
{
    return [signal settingWriteSignalWithData:data type:TPSignalTypeTuningSetting];
}

- (TPSignalType)signalType
{
    return TPSignalTypeTuningSetting;
}

@end
