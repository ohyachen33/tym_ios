//
//  DocumentUtils.m
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 28/8/15.
//  Copyright (c) 2015 primax. All rights reserved.
//

#import "DocumentUtils.h"

@implementation DocumentUtils

+ (NSString*)getSimpleStorePathForFile:(NSString*)filename{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [doc stringByAppendingFormat:[@"/" stringByAppendingString:filename]];
    
    return path;
}

+ (NSDictionary*)dictionaryFromArchivedDocumentFilename:(NSString*)filename
{
    NSString* filePath = [DocumentUtils getSimpleStorePathForFile:filename];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dictionary = [unarchiver decodeObjectForKey:filename];
    
    return dictionary;
}

+ (BOOL)saveDictionary:(NSDictionary*)dictionary asArchivedDocumentWithFilename:(NSString*)filename
{
    NSString* filePath = [DocumentUtils getSimpleStorePathForFile:filename];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dictionary forKey:filename];
    [archiver finishEncoding];
    
    return [data writeToFile:filePath atomically:NO];
}

+ (BOOL)saveDictionary:(NSDictionary*)dictionary asFilename:(NSString*)filename
{
    NSString* filePath = [DocumentUtils getSimpleStorePathForFile:filename];
    
    return [dictionary writeToFile:filePath atomically:NO];
}


+ (NSDictionary*)dictionaryFromDocumentFilename:(NSString*)filename
{
    NSString *filePath = [DocumentUtils getSimpleStorePathForFile:filename];
    
    NSDictionary* result = [DocumentUtils dictionaryFromFilePath:filePath];
    
    if(result)
    {
        NSLog(@"Document: %@ file has been loaded successfully", filename);
        
        return result;
    }
    
    NSLog(@"Document: %@ file does not exist!", filename);
    
    return nil;
}

+ (NSDictionary*)dictionaryFromResources:(NSString*)resourceName
{
    NSString *defaultFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:resourceName ofType:@"plist"];
    
    NSDictionary* result = [DocumentUtils dictionaryFromFilePath:defaultFilePath];
    
    if(result)
    {
        NSLog(@"Resource: %@ file has been loaded successfully", resourceName);
        
        return result;
    }
    
    NSLog(@"Resource: %@ file does not exist!", resourceName);
    
    return nil;
}

+ (NSDictionary*)dictionaryFromFilePath:(NSString*)filePath
{
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    
    return nil;
}


@end
