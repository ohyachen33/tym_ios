//
//  TAPBluetoothLowEnergyProxyTests.m
//  TAPProtocol
//
//  Created by Lam Yick Hong on 16/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "TAPBluetoothLowEnergyProxy.h"
#import "TAPSystem.h"

@interface TAPBluetoothLowEnergyProxy(Private)

- (void)writeTPSignal:(NSData*)data peripheral:(TAPSystem*)system;

@end

@interface TAPBluetoothLowEnergyProxyTests : XCTestCase

@end

@implementation TAPBluetoothLowEnergyProxyTests

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
    
    TAPBluetoothLowEnergyProxy* proxy = [[TAPBluetoothLowEnergyProxy alloc] initWithConfig:serviceInfo];
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
    
    TAPBluetoothLowEnergyProxy* proxy = [[TAPBluetoothLowEnergyProxy alloc] initWithConfig:serviceInfo];
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
                                                   @{ @"characteristic" : @[@"6409D79D-CD28-479C-A639-92F9E1948B43"],
                                                      @"description" : @"TP Service",
                                                      @"identifier" : @"1FEE6ACF-A826-4E37-9635-4D8A01642C5D",
                                                      @"mode" : @"TPSignal",
                                                      }
                                                   ],
                                           @"mode" : @"tp-signal"
                                           }
                                   };
    
    TAPBluetoothLowEnergyProxy* proxy = [[TAPBluetoothLowEnergyProxy alloc] initWithConfig:serviceInfo];
    
    //setup the set of object and stub the called method so it return the correct value to go with the flow
    id deviceMock = OCMClassMock([CBPeripheral class]);
    id serviceMock = OCMClassMock([CBService class]);
    id characteristicMock = OCMClassMock([CBCharacteristic class]);
    
    CBUUID * uuid = [CBUUID UUIDWithString:@"1FEE6ACF-A826-4E37-9635-4D8A01642C5D"];
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
