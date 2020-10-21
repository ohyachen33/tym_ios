//
//  TAPService.m
//  TAPService
//
//  Created by Lam Yick Hong on 29/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAPService.h"
#import "TAPProtocolFactory.h"

#import "TAPError.h"

#define kReadObserverExpireInterval 3

/*!
 *  @protocol TAPService(Private)
 *
 *  @brief   Declares extension private methods.
 *
 */
@interface TAPService()

@property (nonatomic, strong) id<TAPProtocolAdaptor> protocolProxy;
@property (nonatomic, strong) NSMutableDictionary* observers;
@property (nonatomic, strong) NSMutableDictionary* otherObservers;
@property (nonatomic, strong) NSMutableDictionary* monitorObservers;

@property (nonatomic, strong) NSTimer* readTimer;

- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block;
- (void)reset:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)subscribe:(TAPropertyType)targetType system:(id)system;
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system;
- (NSError*)unsupportedErrorWithInfo:(NSDictionary*)info;
- (void)registerReadObserver:(id)observer forKey:(id)observerKey;

@end


@implementation TAPService

- (id)initWithType:(NSString*)type config:(NSDictionary*)config
{
    if(self = [super init])
    {
        //instantiate a protcol proxy. It will create a protocol for us if it's not there.
        self.protocolProxy = [TAPProtocolFactory generateProtocol:type config:config];
        
        self.observers = [[NSMutableDictionary alloc] init];
        
        self.monitorObservers = [[NSMutableDictionary alloc] init];
    }
    return self;
    
}

- (id)initWithType:(NSString*)type
{
    if(self = [super init])
    {
        //instantiate a protcol proxy. It will create a protocol for us if it's not there.
        self.protocolProxy = [TAPProtocolFactory generateProtocol:type config:nil];
        
        self.observers = [[NSMutableDictionary alloc] init];
        
        self.monitorObservers = [[NSMutableDictionary alloc] init];
    }
    return self;
    
}

- (void)dealloc
{
    for(id observer in self.observers)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block
{
    DDLogDebug(@"type: %ld system: %@", (long)targetType, [system description]);
    
    NSString* observerKey = [self observerKeyFromTimestamp];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAPProtocolEventDidUpdateValue object:nil queue:nil usingBlock:^(NSNotification* note){
        
        NSDictionary* value = [[note userInfo] objectForKey:TAPProtocolKeyValue];
        TAPropertyType type = [[[note userInfo] objectForKey:TAPProtocolPropertyType] integerValue];
        NSError* error = [[note userInfo] objectForKey:TAPProtocolKeyError];
        
        id targetObserver = [[self.observers objectForKey:observerKey] objectForKey:@"observer"];
        
        //only return result if we have a observer, it means it's the first result
        if(targetObserver){
            
            //if it's what we are observing
            if(type == targetType)
            {
                //Return the value
                block(value, error);
                
                if(targetObserver)
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:targetObserver name:TAPProtocolEventDidUpdateValue object:nil];
                    [self.observers removeObjectForKey:observerKey];
                }
                
            }
            
        }
        
    }];
    
    [self registerReadObserver:observer forKey:observerKey];

    [self.protocolProxy read:system type:targetType];
}

//help to write data to system
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block
{
    DDLogDebug(@"type: %ld data:%@ system: %@", (long)targetType, [data description], [system description]);
    
    NSString* observerKey = [self observerKeyFromTimestamp];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAPProtocolEventDidWriteValue object:nil queue:nil usingBlock:^(NSNotification* note){
        
        NSDictionary* value = [[note userInfo] objectForKey:TAPProtocolKeyValue];
        TAPropertyType type = TAPropertyTypeUnknown;
        
        NSNumber* typeNum = [[note userInfo] objectForKey:TAPProtocolPropertyType];
        if(typeNum){
            type = [typeNum integerValue];
        }
        
        NSError* error = [[note userInfo] objectForKey:TAPProtocolKeyError];
        
        //if it's what we are observing TODO: it's not easy for us to pass this back to mmake it safe. Possible?
        //if(type == targetType)
        {
            id value = [[note userInfo] objectForKey:TAPProtocolKeyValue][@"value"];
            
            //TODO: success or not? error handling?
            block(value, error);
            
            id targetObserver = [[self.observers objectForKey:observerKey]  objectForKey:@"observer"];
            
            if(targetObserver)
            {
                [[NSNotificationCenter defaultCenter] removeObserver:targetObserver name:TAPProtocolEventDidWriteValue object:nil];
                [self.observers removeObjectForKey:observerKey];
            }
        }
    }];
    
    [self registerReadObserver:observer forKey:observerKey];
    
    [self.protocolProxy write:system type:targetType data:data];
}

- (void)reset:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block
{
    DDLogDebug(@"type: %ld system: %@", (long)targetType, [system description]);
    
    NSString* observerKey = [self observerKeyFromTimestamp];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAPProtocolEventDidUpdateValue object:nil queue:nil usingBlock:^(NSNotification* note){
        
        NSDictionary* value = [[note userInfo] objectForKey:TAPProtocolKeyValue];
        TAPropertyType type = [[[note userInfo] objectForKey:TAPProtocolPropertyType] integerValue];
        NSError* error = [[note userInfo] objectForKey:TAPProtocolKeyError];
        
        id targetObserver = [[self.observers objectForKey:observerKey] objectForKey:@"observer"];
        
        //only return result if we have a observer, it means it's the first result
        if(targetObserver){
            
            //special case
            BOOL isTargetPresentName = (targetType >= TAPropertyTypePresetName1 && targetType <= TAPropertyTypePresetName3);
            BOOL isReceivedPresentName = (type >= TAPropertyTypePresetName1 && type <= TAPropertyTypePresetName3);
            
            //if it's what we are observing
            
            if(isTargetPresentName && isReceivedPresentName){
                
                NSNumber* typeNum = [NSNumber numberWithInt:type];
                
                //Return the value
                block(@{@"type" : typeNum , @"value" : [value objectForKey:@"value"]}, error);
                
                //don't remove observer, simply let it expired
                
            }else if(type == targetType)
            {
                //Return the value
                block(value, error);
                
                if(targetObserver)
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:targetObserver name:TAPProtocolEventDidUpdateValue object:nil];
                    [self.observers removeObjectForKey:observerKey];
                }
                
            }
            
        }
        
    }];
    
    [self registerReadObserver:observer forKey:observerKey];
    
    [self.protocolProxy reset:system type:targetType];
}

- (void)subscribe:(TAPropertyType)targetType system:(id)system
{
    DDLogDebug(@"type: %ld system: %@", (long)targetType, [system description]);
    
    NSString* observerKey = [self observerKeyFromType:targetType];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAPProtocolEventDidUpdateValue object:nil queue:nil usingBlock:^(NSNotification* note){
        
        NSDictionary* value = [[note userInfo] objectForKey:TAPProtocolKeyValue];
        TAPropertyType type = [[[note userInfo] objectForKey:TAPProtocolPropertyType] integerValue];
        id system = [[note userInfo] objectForKey:TAPProtocolKeyTargetSystem];
        NSError* error = [[note userInfo] objectForKey:TAPProtocolKeyError];
        
        //if it's what we are observing
        if(type == targetType || (targetType == TAPropertyTypeEqualizer && type <= TAPropertyTypeEqualizer && type != TAPropertyTypeVolume) || type == TAPropertyTypeFactoryReset)
        {
            [self system:system didReceiveUpdateValue:value type:type];
        }
    }];
    
    if ([[self.monitorObservers allKeys] containsObject:observerKey]) {
        NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:self.monitorObservers[observerKey]];
        [arr addObject:observer];
        [self.monitorObservers setObject:arr forKey:observerKey];
    }else{
        [self.monitorObservers setObject:@[observer] forKey:observerKey];
    }
    
    [self.protocolProxy subscribe:system type:targetType];
}

//help to unsubscribe a value update from system
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system
{
    DDLogDebug(@"type: %ld system: %@", (long)targetType, [system description]);
    
    NSString* observerKey = [self observerKeyFromType:targetType];
    
    for (id targetObserver in (NSArray*)self.monitorObservers[observerKey]) {
        [[NSNotificationCenter defaultCenter] removeObserver:targetObserver name:TAPProtocolEventDidUpdateValue object:nil];
    }
    
    [self.monitorObservers removeObjectForKey:observerKey];
    
    [self.protocolProxy unsubscribe:system type:targetType];
}

- (void)registerReadObserver:(id)observer forKey:(id)observerKey
{
    [self.observers setObject:@{@"observer" : observer, @"timestamp" : [NSDate date]} forKey:observerKey];
    
    if(!self.readTimer)
    {
        self.readTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    }
}

- (void)onTimer:(NSTimer*)timer
{
    for(NSDictionary* dictionary in [self.observers allValues])
    {
        NSString* key = [[self.observers allKeysForObject:dictionary] objectAtIndex:0];
        NSDate* date = [dictionary objectForKey:@"timestamp"];
        NSTimeInterval diff = [[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970];
        
        if(diff > kReadObserverExpireInterval)
        {
            id observer = [dictionary objectForKey:@"observer"];
            
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            [self.observers removeObjectForKey:key];
        }
    }
    
    //no more observers
    if([self.observers count] == 0)
    {
        DDLogVerbose(@"Timer invalidated and removed");
        [self.readTimer invalidate];
        self.readTimer = nil;
    }
}

- (NSDictionary*)perform:(NSDictionary*)operationInfo
{
    return [self.protocolProxy perform:operationInfo];
}


- (void)system:(id)system didReceiveUpdateValue:(NSDictionary*)data type:(TAPropertyType)targetType
{
    //Subclass should override this to implement your own interpretation
    DDLogDebug(@"data %@ type: %ld", [data description], (long)targetType);
}

- (NSString*)observerKeyFromTimestamp{
    
    return [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
}

- (NSString*)observerKeyFromType:(NSInteger)targetType{
    
    return [NSString stringWithFormat:@"%@ - %ld", @"subscribe", (long)targetType];
}

- (NSError*)unsupportedErrorWithInfo:(NSDictionary*)info
{
    return [NSError errorWithDomain:TAPServiceErrorDomain code:TAPErrorCodeNotSupported userInfo:info];
}

@end
