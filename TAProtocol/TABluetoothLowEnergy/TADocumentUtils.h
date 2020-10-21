//
//  TADocumentUtils.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 27/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TADocumentUtils : NSObject

+ (NSString*)getSimpleStorePathForFile:(NSString*)filename;
+ (NSDictionary*)dictionaryFromResources: (NSString*)resourceName;

+ (NSDictionary*)dictionaryFromDocumentFilename:(NSString*)filename;
+ (NSDictionary*)dictionaryFromArchivedDocumentFilename:(NSString*)filename;
+ (BOOL)saveDictionary:(NSDictionary*)dictionary asArchivedDocumentWithFilename:(NSString*)filename;
+ (BOOL)saveDictionary:(NSDictionary*)dictionary asFilename:(NSString*)filename;

@end
