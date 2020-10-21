//
//  TAHttpServer.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 27/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAHttpServer.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

#import "MHAudioBufferPlayer.h"
#import "HTTPServer.h"

#define kDefaultPort 8081
#define kDefaultType @"_http._tcp."

NSString * const TAHttpServerConfigPort =   @"port";
NSString * const TAHttpServerConfigType =   @"type";
NSString * const TAHttpServerConfigRoot =   @"root";

@interface TAHttpServer()

@property (nonatomic, strong)MHAudioBufferPlayer* backgroundPlayer;

@end

@implementation TAHttpServer

- (id)init
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* root = [paths objectAtIndex:0];
    
    NSDictionary* config = @{TAHttpServerConfigPort : [NSNumber numberWithLongLong:kDefaultPort],
                             TAHttpServerConfigType : kDefaultType,
                             TAHttpServerConfigRoot : root};
    
    return [self initWithConfig:config];
}

- (id)initWithConfig:(NSDictionary*)config
{
    if(self = [super init])
    {
        // Custom initialization
        // Create server using our custom MyHTTPServer class
        httpServer = [[HTTPServer alloc] init];
        
        // Tell the server to broadcast its presence via Bonjour.
        // This allows browsers such as Safari to automatically discover our service.
        NSString* type = [config objectForKey:TAHttpServerConfigType];
        
        if(!type)
        {
            type = @"_http._tcp.";
        }
        [httpServer setType:type];
        
        // Normally there's no need to run our server on any specific port.
        // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
        // However, for easy testing you may want force a certain port so you can just hit the refresh button.
        UInt16 port = [[config objectForKey:TAHttpServerConfigPort] longLongValue];
        if(!port)
        {
            port = kDefaultPort;
        }
        [httpServer setPort:port];
        
        NSString* root = [config objectForKey:TAHttpServerConfigRoot];
        if(!root)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            root = [paths objectAtIndex:0];
        }
        
        [httpServer setDocumentRoot:root];
    }
    return self;
}

- (void)start
{
    [self startBackgroundProcess];
    
    NSError *error;
    if([httpServer start:&error])
    {
        NSLog(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
    }
    else
    {
        //DDLogError(@"Error starting HTTP Server: %@", error);
    }
    
}

- (void)stop
{
    [self stopBackgroundProcess];
    
    BOOL keepExistingConnections = YES;
    
    [httpServer stop:keepExistingConnections];
    
    if(keepExistingConnections){
        
        NSLog(@"Stop HTTP Server with keeping existing Connection on port %hu", [httpServer listeningPort]);
    }else{
        
        NSLog(@"Stop HTTP Server");
    }
}

- (id)propertyByKey:(NSString*)propertyKey
{
    if([propertyKey isEqualToString:TAHttpServerConfigPort])
    {
        return [NSNumber numberWithLongLong:[httpServer listeningPort]];
        
    }else if([propertyKey isEqualToString:TAHttpServerConfigRoot])
    {
        return [httpServer documentRoot];
        
    }else if([propertyKey isEqualToString:TAHttpServerConfigType])
    {
        return [httpServer type];
    }
    
    NSLog(@"Error: The propertyKey is not supported by TAHttpServer");
    
    return nil;
}

- (BOOL)createRootFolder:(NSString*)foldername
{
    NSString* folderPath = [[httpServer documentRoot] stringByAppendingPathComponent:foldername];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:folderPath])
    {
        NSLog(@"folder exists - No issue");
        return YES;
    }
    
    if([[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil])
    {
        NSLog(@"folder created - No issue");
        return YES;
    }
    
    NSLog(@"Error: folder not exist and not created.");
    
    return NO;
}

#pragma Helper functions

- (void)startBackgroundProcess
{
    // Start the server (and check for problems)
    float sampleRate = 16000.0f;
    self.backgroundPlayer = [[MHAudioBufferPlayer alloc] initWithSampleRate:sampleRate
                                                                   channels:1
                                                             bitsPerChannel:16
                                                           packetsPerBuffer:1024];
    self.backgroundPlayer.gain = 0.9f;
    
    [self.backgroundPlayer start];
}

- (void)stopBackgroundProcess
{
    [self.backgroundPlayer stop];
}

//TODO: someone else provide this
+ (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

@end
