//
//  TAPropertyDevice.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 13/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertyDevice.h"
#import "TASignalType.h"
#import "TPSignalConfig.h"

@interface TAPropertyDevice()

@property (readwrite) TAPropertyDeviceSubType subType;

@end

@implementation TAPropertyDevice

- (id)initWithSubType:(TAPropertyDeviceSubType)subType
{
    if(self = [super init])
    {
        self.subType = subType;
    }
    
    return self;
}

- (NSString*)uuid
{
    NSString* result = nil;
    
    switch (self.subType) {
        case TAPropertyDeviceSubTypeModelNumber:
        {
            result = @"2A24";
        }
            break;
        case TAPropertyDeviceSubTypeSerialNumber:
        {
            result = @"2A25";
        }
            break;
        case TAPropertyDeviceSubTypeDeviceName:
        {
            result = @"2A00";
        }
            break;
        case TAPropertyDeviceSubTypeSoftwareVersion:
        {
            result = @"2A26";
        }
            break;
        case TAPropertyDeviceSubTypeHardwareNumber:
        {
            result = @"2A27";
        }
            break;
            
        default:
            break;
    }
    
    return result;
}

@end
