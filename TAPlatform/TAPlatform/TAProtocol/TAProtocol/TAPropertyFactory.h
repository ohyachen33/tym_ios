//
//  TAPropertyFactory.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAProperty.h"
#import "TAPProtocolAdaptor.h"

#import "TAPropertyVolume.h"
#import "TAPropertyLowPassFilter.h"
#import "TAPropertyRGC.h"
#import "TAPropertyPhase.h"
#import "TAPropertyPortTuning.h"
#import "TAPropertyParametricEQ.h"
#import "TAPropertySettings.h"
#import "TAPropertyScreenDisplay.h"
#import "TAPropertyPreset.h"


@interface TAPropertyFactory : NSObject

+ (TAProperty*)createPropertyWithType:(TAPropertyType)type;

@end
