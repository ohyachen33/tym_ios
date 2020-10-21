//
//  TAProperty.h
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSignal.h"

@interface TAProperty : NSObject

- (NSData*)dataBySignal:(TPSignal*)signal writeData:(NSData*)data;

- (TPSignalType)signalType;

- (NSString*)uuid;

@end
