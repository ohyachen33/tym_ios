//
//  PartData.h
//  AVSObjcFTW
//
//  Created by Alain Hsu on 9/8/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PartData : NSObject
@property (nonatomic,strong) NSDictionary *headers;
@property (nonatomic,strong) NSData *data;

@end
