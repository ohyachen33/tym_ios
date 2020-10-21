//
//  TAService.m
//  TAService
//
//  Created by Lam Yick Hong on 29/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAService.h"
#import "TAProtocolFactory.h"

/*!
 *  @protocol TAService(Private)
 *
 *  @brief   Declares extension private methods.
 *
 */
@interface TAService()

@property (nonatomic, strong) id<TAProtocolAdaptor> protocolProxy;
@property (nonatomic, strong) NSMutableDictionary* observers;

- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block;
- (void)subscribe:(TAPropertyType)targetType system:(id)system;
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system;

@end


@implementation TAService

- (id)initWithType:(NSString*)type config:(NSDictionary*)config
{
    if(self = [super init])
    {
        //instantiate a protcol proxy. It will create a protocol for us if it's not there.
        self.protocolProxy = [TAProtocolFactory generateProtocol:type config:config];
        
        self.observers = [[NSMutableDictionary alloc] init];
    }
    return self;
    
}

- (id)initWithType:(NSString*)type
{
    if(self = [super init])
    {
        //instantiate a protcol proxy. It will create a protocol for us if it's not there.
        self.protocolProxy = [TAProtocolFactory generateProtocol:type config:nil];
        
        self.observers = [[NSMutableDictionary alloc] init];
    }
    return self;
    
}

- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block
{
    NSString* observerKey = [NSString stringWithFormat:@"%@ - %ld", @"read", (long)targetType];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAProtocolEventDidUpdateValue object:nil queue:nil usingBlock:^(NSNotification* note){
        
        NSDictionary* value = [[note userInfo] objectForKey:TAProtocolKeyValue];
        TAPropertyType type = [[[note userInfo] objectForKey:TAProtocolPropertyType] integerValue];
        NSError* error = [[note userInfo] objectForKey:TAProtocolKeyError];
        
        id targetObserver = [self.observers objectForKey:observerKey];
        
        //only return result if we have a observer, it means it's the first result
        if(targetObserver){
            
            //if it's what we are observing
            if(type == targetType)
            {
                //Return the value
                block(value, error);
                
                if(targetObserver)
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:targetObserver];
                    [self.observers removeObjectForKey:observerKey];
                }
                
            }
            
        }
        
    }];
    
    [self.observers setObject:observer forKey:observerKey];

    [self.protocolProxy read:system type:targetType];
}

//help to write data to system
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block
{
    NSString* observerKey = [NSString stringWithFormat:@"%@ - %ld", @"write", (long)targetType];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAProtocolEventDidWriteValue object:nil queue:nil usingBlock:^(NSNotification* note){
        
        NSDictionary* value = [[note userInfo] objectForKey:TAProtocolKeyValue];
        TAPropertyType type = [[[note userInfo] objectForKey:TAProtocolPropertyType] integerValue];
        NSError* error = [[note userInfo] objectForKey:TAProtocolKeyError];
        
        //if it's what we are observing TODO: it's not easy for us to pass this back to mmake it safe. Possible?
        //if(type == targetType)
        {
            //TODO: success or not? error handling?
            block(nil, error);
            
            id targetObserver = [self.observers objectForKey:observerKey];
            
            if(targetObserver)
            {
                [[NSNotificationCenter defaultCenter] removeObserver:targetObserver];
            }
        }
    }];
    
    [self.observers setObject:observer forKey:observerKey];
    
    [self.protocolProxy write:system type:targetType data:data];
}

//help to subscribe a value update from system
- (void)subscribe:(TAPropertyType)targetType system:(id)system
{
    NSString* observerKey = [NSString stringWithFormat:@"%@ - %ld", @"subscribe", (long)targetType];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAProtocolEventDidUpdateValue object:nil queue:nil usingBlock:^(NSNotification* note){
        
        NSDictionary* value = [[note userInfo] objectForKey:TAProtocolKeyValue];
        TAPropertyType type = [[[note userInfo] objectForKey:TAProtocolPropertyType] integerValue];
        id system = [[note userInfo] objectForKey:TAProtocolKeyTargetSystem];
        
        //if it's what we are observing
        if(type == targetType)
        {
            [self system:system didReceiveUpdateValue:value type:type];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }];
    
    [self.observers setObject:observer forKey:observerKey];
    
    [self.protocolProxy subscribe:system type:targetType];
}

//help to unsubscribe a value update from system
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system
{
    NSString* observerKey = [NSString stringWithFormat:@"%@ - %ld", @"unsubscribe", (long)targetType];
    
    [self.observers removeObjectForKey:observerKey];
    
    [self.protocolProxy unsubscribe:system type:targetType];
}

- (void)system:(id)system didReceiveUpdateValue:(NSDictionary*)data type:(TAPropertyType)targetType
{
    //Subclass should override this to implement your own interpretation
    NSLog(@"Did receive update value of type: %ld", (long)targetType);
}

@end
