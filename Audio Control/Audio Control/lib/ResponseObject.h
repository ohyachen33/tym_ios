//
//  ResponseObject.h
//  AVSObjcFTW
//
//  Created by Alain Hsu on 9/8/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PartData.h"

@interface ResponseObject : NSObject

@property (nonatomic) NSData *data;
@property (nonatomic) NSArray *partDataArray;

- (void)parseResponseData:(NSData*)data boundary:(NSString *)boundary;

@end
