//
//  TAMediaImportService.h
//  TAMediaImportService
//
//  Created by Lam Yick Hong on 29/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAMediaImportService : NSObject

/** Export the target library asset to a defined URL.
 
 @param assetURL the URL of the target library asset to be exported.
 @param outURL the URL of the target library asset to be exported to.
 @param completionBlock to be carried out after the exporting.
 */
+ (void)exportAssetAtURL:(NSURL*)assetURL outURL:(NSURL*)outURL completionBlock:(void (^)(NSError* error))completionBlock;

/** Returns the file extension of the given library asset URL
 
 @param assetURL the URL of the target library asset.
 @return File extension of the target library asset.
 */
+ (NSString*)extensionForAssetURL:(NSURL*)assetURL;

@end
