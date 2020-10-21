//
//  TAHttpServer.h
//  TAProtocol
//
//  Created by Lam Yick Hong on 27/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const TAHttpServerConfigPort;
FOUNDATION_EXPORT NSString * const TAHttpServerConfigType;
FOUNDATION_EXPORT NSString * const TAHttpServerConfigRoot;

/** TAHttpServer is a simple HTTP Server which support backgroud running.
 
 The HTTP Server can only be configured during init time.
 
 */

@class HTTPServer;
@interface TAHttpServer : NSObject
{
    HTTPServer *httpServer;
}

/** Initializes and returns a newly allocated HTTP Server wrapper object with default config.
 
 @return An initialized HTTP Server wrapper object or nil if the object couldn't be created.
 */
- (id)init;

/** Initializes and returns a newly allocated HTTP Server wrapper object with the specified config.
 
 @param config to be used to initialize the HTTP Server. Supported keys are all defined as const string.
 @return An initialized HTTP Server wrapper object or nil if the object couldn't be created.
 */
- (id)initWithConfig:(NSDictionary*)config;

- (void)start;
- (void)stop;

/** Returns a server property value by the given key.
 
 @param propertyKey the key of the property to get.
 @return Value of the property.
 */
- (id)propertyByKey:(NSString*)propertyKey;

/** Create a folder under the server document root and return the result.
 
 @param foldername the name of the folder to be created.
 @return Boolean if the folder has been created(can be created before this call) or not.
 */
- (BOOL)createRootFolder:(NSString*)foldername;

@end
