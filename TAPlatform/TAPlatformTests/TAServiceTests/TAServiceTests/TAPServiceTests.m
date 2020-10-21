//
//  TAPServiceTests.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 13/10/15.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OCMock.h"
#import "TAPService.h"
#import "TAPSystem.h"
#import "TAPError.h"

@interface TAPService(Private)

- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block;

@end

@interface TAPServiceTests : XCTestCase

@end

@implementation TAPServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReadUnknownPropertyStandardMode{
    
    NSString* type = [NSString stringWithFormat:@"BLE-%@", @"unit-testing"];
    
    NSDictionary* serviceInfo = @{ @"serviceInfo" : @{
                                           @"services" : @[
                                                   @{ @"characteristic" : @[@"2A24"],
                                                      @"description" : @"DEVICE_INFO_SERVICE",
                                                      @"identifier" : @"180A",
                                                      }
                                                   ],
                                           @"mode" : @"standard"
                                           }
                                   };
    
    TAPService* service = [[TAPService alloc] initWithType:type config:serviceInfo];
    
    id peripheralMock = OCMClassMock([CBPeripheral class]);
    TAPSystem* system = [[TAPSystem alloc] initWithSystem:peripheralMock];
        
    [service read:TAPropertyTypeUnknown system:system handler:^(NSDictionary* info, NSError* error){
        
        if(error)
        {
            XCTAssertEqual([[error domain] isEqualToString:TAPProtocolErrorDomain], YES);
            XCTAssertEqual([error code], TAPErrorCodeNotSupported);
        }
        
    }];
}

- (void)testReadUnknownPropertyTPSignalMode{
    
    NSString* type = [NSString stringWithFormat:@"BLE-%@", @"unit-testing"];
    
    NSDictionary* serviceInfo = @{ @"serviceInfo" : @{
                                           @"services" : @[
                                                   @{ @"characteristic" : @[@"6409D79D-CD28-479C-A639-92F9E1948B43"],
                                                      @"description" : @"TP Service",
                                                      @"identifier" : @"1FEE6ACF-A826-4E37-9635-4D8A01642C5D"
                                                      }
                                                   ],
                                           @"mode" : @"tp-signal"
                                           }
                                   };
    
    TAPService* service = [[TAPService alloc] initWithType:type config:serviceInfo];
    
    id peripheralMock = OCMClassMock([CBPeripheral class]);
    TAPSystem* system = [[TAPSystem alloc] initWithSystem:peripheralMock];
    
    [service read:TAPropertyTypeUnknown system:system handler:^(NSDictionary* info, NSError* error){
        
        if(error)
        {
            XCTAssertEqual([[error domain] isEqualToString:TAPProtocolErrorDomain], YES);
            XCTAssertEqual([error code], TAPErrorCodeNotSupported);
        }
        
    }];
}

- (void)testWriteUnknownPropertyStandardMode{
    
    NSString* type = [NSString stringWithFormat:@"BLE-%@", @"unit-testing"];
    
    NSDictionary* serviceInfo = @{ @"serviceInfo" : @{
                                           @"services" : @[
                                                   @{ @"characteristic" : @[@"2A24"],
                                                      @"description" : @"DEVICE_INFO_SERVICE",
                                                      @"identifier" : @"180A",
                                                      }
                                                   ],
                                           @"mode" : @"standard"
                                           }
                                   };
    
    TAPService* service = [[TAPService alloc] initWithType:type config:serviceInfo];
    
    id peripheralMock = OCMClassMock([CBPeripheral class]);
    TAPSystem* system = [[TAPSystem alloc] initWithSystem:peripheralMock];
    
    NSData* data = [NSData data];
    
    [service write:TAPropertyTypeUnknown data:data system:system handler:^(id info, NSError* error){
       
        if(error)
        {
            XCTAssertEqual([[error domain] isEqualToString:TAPProtocolErrorDomain], YES);
            XCTAssertEqual([error code], TAPErrorCodeNotSupported);
        }
        
    }];
}

- (void)testWriteUnknownPropertyTPSignalMode{
    
    NSString* type = [NSString stringWithFormat:@"BLE-%@", @"unit-testing"];
    
    NSDictionary* serviceInfo = @{ @"serviceInfo" : @{
                                           @"services" : @[
                                                   @{ @"characteristic" : @[@"6409D79D-CD28-479C-A639-92F9E1948B43"],
                                                      @"description" : @"TP Service",
                                                      @"identifier" : @"1FEE6ACF-A826-4E37-9635-4D8A01642C5D"
                                                      }
                                                   ],
                                           @"mode" : @"tp-signal"
                                           }
                                   };
    
    TAPService* service = [[TAPService alloc] initWithType:type config:serviceInfo];
    
    id peripheralMock = OCMClassMock([CBPeripheral class]);
    TAPSystem* system = [[TAPSystem alloc] initWithSystem:peripheralMock];
    
    NSData* data = [NSData data];
    
    [service write:TAPropertyTypeUnknown data:data system:system handler:^(id info, NSError* error){
        
        if(error)
        {
            XCTAssertEqual([[error domain] isEqualToString:TAPProtocolErrorDomain], YES);
            XCTAssertEqual([error code], TAPErrorCodeNotSupported);
        }
        
    }];
}

@end
