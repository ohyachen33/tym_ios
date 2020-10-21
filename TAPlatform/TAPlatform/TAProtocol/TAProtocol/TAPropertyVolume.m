//
//  TAPropertyVolume.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertyVolume.h"
#import "TPSignal.h"
#import "TPSignalConfig.h"
#import "TAPDataUtils.h"

@implementation TAPropertyVolume

- (NSData*)dataBySignal:(TPSignal*)signal writeData:(NSData*)data
{
    NSData* value;
    NSData* result;
    NSString* inputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if(data && [data isKindOfClass:[NSData class]])
    {
        //TODO: examine if this step is really necessary
        value = [TAPDataUtils reverse:data];
    }
    
    if(inputString && [inputString isEqualToString:@"up"])
    {
        result = [signal keySignalWithKeyIdData:[TPSignalConfig dataForVolumeUp] type:TPSignalTypeKey];
        
    }else if(inputString && [inputString isEqualToString:@"down"])
    {
        result = [signal keySignalWithKeyIdData:[TPSignalConfig dataForVolumeDown] type:TPSignalTypeKey];
        
    }else{
        
        result = [signal settingWriteSignalWithData:value type:TPSignalTypeVolumeSetting];
    }
    
    return result;
}

- (TPSignalType)signalType
{
    return TPSignalTypeVolumeSetting;
}

- (NSString*)uuid
{
    return @"44FA50B2-D0A3-472E-A939-D80CF17638BB";
}

@end
