//
//  ResponseObject.m
//  AVSObjcFTW
//
//  Created by Alain Hsu on 9/8/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "ResponseObject.h"

@implementation ResponseObject

- (void)parseResponseData:(NSData*)data boundary:(NSString *)boundary
{
    
    NSData *innerBoundary = [[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *endBoundary = [[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableArray *innerRanges = [NSMutableArray new];
    NSInteger lastStartingLocation = 0;
    
    NSRange boundaryRange = [data rangeOfData:innerBoundary options:0 range:NSMakeRange(lastStartingLocation, data.length)];
    
    while (boundaryRange.location != NSNotFound) {
        
        lastStartingLocation = boundaryRange.location + boundaryRange.length;
        boundaryRange = [data rangeOfData:innerBoundary options:0 range:NSMakeRange(lastStartingLocation, data.length - lastStartingLocation)];
        
        if (boundaryRange.location != NSNotFound) {
            [innerRanges addObject:[NSValue valueWithRange:NSMakeRange(lastStartingLocation, boundaryRange.location - lastStartingLocation)]];
        }else{
            [innerRanges addObject:[NSValue valueWithRange:NSMakeRange(lastStartingLocation, data.length - lastStartingLocation)]];
        }
    }
    
    NSMutableArray *partDataArray = [NSMutableArray new];
    
    for (NSValue *rangeValue in innerRanges) {
        NSRange innerRange = [rangeValue rangeValue];
        
        NSData *innerData = [data subdataWithRange:innerRange];
        
        NSRange headerRange = [innerData rangeOfData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, innerRange.length)];
        
        NSMutableDictionary *headers = [NSMutableDictionary new];
        NSString *headData = [[NSString alloc]initWithData:[innerData subdataWithRange:NSMakeRange(0, headerRange.location)] encoding:NSUTF8StringEncoding];
        if (headData) {
            NSArray *headerLines = [headData componentsSeparatedByString:@"\r\n"];
            for (NSString *headerLine in headerLines) {
                NSArray *headerSplit = [headerLine componentsSeparatedByString:@":"];
                headers[headerSplit[0]] = [headerSplit[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
        }
        
        NSInteger startLocation = headerRange.location + headerRange.length;
        NSData *contentData = [innerData subdataWithRange:NSMakeRange(startLocation, innerRange.length - startLocation)];
        
        NSRange endContentRange = [contentData rangeOfData:endBoundary options:0 range:NSMakeRange(0, contentData.length)];
        
        PartData *partData = [PartData new];
        if (endContentRange.location != NSNotFound) {
            partData.headers = headers;
            partData.data = [contentData subdataWithRange:NSMakeRange(0, endContentRange.location)];
        }else{
            partData.headers = headers;
            partData.data = contentData;
        }
        [partDataArray addObject:partData];
    }
    self.data = data;
    self.partDataArray = partDataArray;
}

@end
