//
//  TAPropertyPhase.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertyPhase.h"
#import "TASignalType.h"

@interface TAPropertyPhase()

@property (readwrite) TAPropertyPhaseSubType subType;

@end

@implementation TAPropertyPhase

- (id)initWithSubType:(TAPropertyPhaseSubType)subType
{
    if(self = [super init])
    {
        self.subType = subType;
    }
    
    return self;
}

- (NSData*)dataBySignal:(TPSignal*)signal writeData:(NSData*)data
{
    TPSignalType type = TPSignalTypeTotalNumber;
    
    switch (self.subType) {
        case TAPropertyPhaseSubTypePhase:
        {
            type = TPSignalTypePhaseSetting;
        }
            break;
        case TAPropertyPhaseSubTypePolarity:
        {
            type = TPSignalTypePolaritySetting;
        }
            break;
            
        default:
            break;
    }
    
    return [signal settingWriteSignalWithData:data type:type];
}

- (TPSignalType)signalType
{
    TPSignalType signalType = TPSignalTypeTotalNumber;
    
    switch (self.subType) {
        case TAPropertyPhaseSubTypePhase:
        {
            signalType = TPSignalTypePhaseSetting;
        }
            break;
        case TAPropertyPhaseSubTypePolarity:
        {
            signalType = TPSignalTypePolaritySetting;
        }
            break;
        default:
            break;
    };
    
    return signalType;
}

@end
