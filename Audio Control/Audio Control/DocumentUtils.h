//
//  DocumentUtils.h
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 28/8/15.
//  Copyright (c) 2015 primax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentUtils : NSObject

+ (NSString*)getSimpleStorePathForFile:(NSString*)filename;
+ (NSDictionary*)dictionaryFromResources: (NSString*)resourceName;

+ (NSDictionary*)dictionaryFromDocumentFilename:(NSString*)filename;
+ (NSDictionary*)dictionaryFromArchivedDocumentFilename:(NSString*)filename;
+ (BOOL)saveDictionary:(NSDictionary*)dictionary asArchivedDocumentWithFilename:(NSString*)filename;
+ (BOOL)saveDictionary:(NSDictionary*)dictionary asFilename:(NSString*)filename;

@end
