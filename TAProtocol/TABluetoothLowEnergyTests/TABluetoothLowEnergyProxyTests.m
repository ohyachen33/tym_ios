//
//  TABluetoothLowEnergyProxyTests.m
//  TAProtocol
//
//  Created by Lam Yick Hong on 16/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "TABluetoothLowEnergyProxy.h"
#import "TASystem.h"

@interface TABluetoothLowEnergyProxy(Private)

- (void)writeTPSignal:(NSData*)data peripheral:(TASystem*)system;

@end

@interface TABluetoothLowEnergyProxyTests : XCTestCase

@end

@implementation TABluetoothLowEnergyProxyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//Test and make sure the code handling the read action as TP Signal Mode
- (void)testReadType {
    
    //To verify the proxy read the mode tp-signal correctly and write TP signal
    NSDictionary* serviceInfo = @{ @"serviceInfo" : @{
                                           @"services" : @[
                                                   @{ @"characteristic" : @[@"2D73"],
                                                      @"description" : @"TP Service",
                                                      @"identifier" : @"2567"
                                                      }
                                                   ],
                                           @"mode" : @"tp-signal"
                                           }
                                   };
    
    TASystem* system = [[TASystem alloc] initWithSystem:nil];
    
    TABluetoothLowEnergyProxy* proxy = [[TABluetoothLowEnergyProxy alloc] initWithConfig:serviceInfo];
    id proxyMock = OCMPartialMock(proxy);
    
    //stub the "expected to be called method"
    OCMStub([proxyMock writeTPSignal:[OCMArg any] peripheral:[OCMArg any]]);
    
    //call the method to be tested
    [proxy read:system type:TAPropertyTypeDisplay];
    
    //verify if the "expected to be called method" has really been called
    OCMVerify([proxyMock writeTPSignal:[OCMArg any] peripheral:[OCMArg any]]);
}

//Test and make sure the code handling the write action as TP Signal Mode
- (void)testWriteType {
    
    //To verify the proxy read the mode tp-signal correctly and will behave as expected
    NSDictionary* serviceInfo = @{ @"serviceInfo" : @{
                                           @"services" : @[
                                                   @{ @"characteristic" : @[@"2D73"],
                                                      @"description" : @"TP Service",
                                                      @"identifier" : @"2567"
                                                      }
                                                   ],
                                           @"mode" : @"tp-signal"
                                           }
                                   };
    
    TASystem* system = [[TASystem alloc] initWithSystem:nil];
    TABluetoothLowEnergyProxy* proxy = [[TABluetoothLowEnergyProxy alloc] initWithConfig:serviceInfo];
    id proxyMock = OCMPartialMock(proxy);
    
    //stub the "expected to be called method"
    OCMStub([proxyMock writeTPSignal:[OCMArg any] peripheral:[OCMArg any]]);
    
    //call the method to be tested
    [proxy write:system type:TAPropertyTypeDisplay data:[NSData data]];
    
    //verify if the "expected to be called method" has really been called
    OCMVerify([proxyMock writeTPSignal:[OCMArg any] peripheral:[OCMArg any]]);
}

//Test and made sure the code will subscribe to the TP Servivce
- (void)testSubscribe
{
    //To verify the proxy read the mode tp-signal correctly and will behave as expected
    NSDictionary* serviceInfo = @{ @"serviceInfo" : @{
                                           @"services" : @[
                                                   @{ @"characteristic" : @[@"2D73"],
                                                      @"description" : @"TP Service",
                                                      @"identifier" : @"2567",
                                                      @"mode" : @"TPSignal",
                                                      }
                                                   ],
                                           @"mode" : @"tp-signal"
                                           }
                                   };
    
    TABluetoothLowEnergyProxy* proxy = [[TABluetoothLowEnergyProxy alloc] initWithConfig:serviceInfo];
    
    //setup the set of object and stub the called method so it return the correct value to go with the flow
    id deviceMock = OCMClassMock([CBPeripheral class]);
    id serviceMock = OCMClassMock([CBService class]);
    id characteristicMock = OCMClassMock([CBCharacteristic class]);
    
    CBUUID * uuid = [CBUUID UUIDWithString:@"2567"];
    [OCMStub([serviceMock UUID]) andReturn:uuid];
    [OCMStub([serviceMock characteristics]) andReturn:@[characteristicMock]];
     
    [OCMStub([deviceMock services]) andReturn:@[serviceMock]];
    OCMStub([deviceMock setNotifyValue:YES forCharacteristic:characteristicMock]);
    
    //test it
    [proxy bluetoothLowEnergyCentralDidConnectDevice:deviceMock didDiscoverCharacteristicsForService:@[characteristicMock]];
    
    //verify if the "expected to be called method" has really been called
    OCMVerify([deviceMock setNotifyValue:YES forCharacteristic:characteristicMock]);
}



@end
