//
//  TASystemServiceTests.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 3/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "OCMock.h"

#import "TAPError.h"
#import "TAPSystem.h"

#import "TAPBluetoothLowEnergyProxy.h"
#import "TAPSystemService.h"

@interface TAPBluetoothLowEnergyProxy(Private)

- (void)connectSystem:(TAPSystem*)system;

@end

@interface TAPSystemService(Private)

@property (nonatomic, strong) id<TAPProtocolAdaptor> protocolProxy;

@end

@interface TASystemServiceTests : XCTestCase <TAPSystemServiceDelegate>

@end

@implementation TASystemServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBleTimeout {

    //To verify the proxy read the mode tp-signal correctly and write TP signal
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
    
    id peripheralMock = OCMClassMock([CBPeripheral class]);
    TAPSystem* system = [[TAPSystem alloc] initWithSystem:peripheralMock];
    
    TAPSystemService* systemService = [[TAPSystemService alloc] initWithType:@"BLE" config:@{@"serviceInfo" : serviceInfo, TAPSystemKeyConnectionDuration : [NSNumber numberWithInt:1.0] } delegate:self];
    
    TAPBluetoothLowEnergyProxy* proxy = [[TAPBluetoothLowEnergyProxy alloc] initWithConfig:serviceInfo];
    id proxyMock = OCMPartialMock(proxy);
    
    systemService.protocolProxy = proxyMock;
    
    //stub the "expected to be called method" and avoid to go further
    OCMStub([proxyMock connectSystem:[OCMArg any]]);

    //now connected and should established a timer...
    [systemService connectSystem:system];
    
    //Wait... delay to wait for the call back
    /*NSTimeInterval i = 0;
    NSTimeInterval delay = 2.0;
    while (i < delay)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
        i+=0.5;
    }*/
    
    //TODO: finish of testing the timer firing
    
}

- (void)didUpdateState:(TAPSystemServiceState)state
{
    
}

- (void)didConnectToSystem:(id)system success:(BOOL)success error:(NSError *)error
{
    //Failed
    XCTAssertEqual(success, NO);
    
    //Error is under service domain
    XCTAssertEqual([[error domain] isEqualToString:TAPServiceErrorDomain], YES);
    
    //Error code is timeout
    XCTAssertEqual([error code], TAPErrorCodeTimeout);
}


@end
