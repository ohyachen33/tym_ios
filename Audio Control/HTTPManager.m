//
//  HTTPManager.m
//  Audio Control
//
//  Created by Alain Hsu on 19/11/2016.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "HTTPManager.h"

@implementation HTTPManager

+ (instancetype)manager {
    
    static HTTPManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [super manager];
        NSMutableSet *newSet = [NSMutableSet set];
        newSet.set = mgr.responseSerializer.acceptableContentTypes;
        [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html" , nil];
        mgr.responseSerializer.acceptableContentTypes = newSet;
        mgr.requestSerializer = [AFJSONRequestSerializer serializer];
        mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return mgr;
}


@end
