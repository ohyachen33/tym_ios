//
//  TAPBluetoothLowEnergyDefaultsTests.m
//  TAPProtocol
//
//  Created by Lam Yick Hong on 27/3/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import "TAPBluetoothLowEnergyDefaults.h"
#import "TAPBluetoothLowEnergyService.h"

#define kDEFAULT @{ @"services" : @[ @{ @"identifier" : @"7D23", @"description" : @"TP Service", @"characteristic" : @[@"4000"] },@{ @"identifier" : @"7D24", @"description" : @"8670", @"characteristic" : @[@"9876", @"9875", @"9874", @"5345", @"5342", @"5341"] }] }

@interface TAPBluetoothLowEnergyDefaultsTests : XCTestCase

@end

@implementation TAPBluetoothLowEnergyDefaultsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[TAPBluetoothLowEnergyDefaults sharedDefaults] createDefault:kDEFAULT];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testServiceUuids {
    // This is an example of a functional test case.
    
    NSArray* uuids = [[TAPBluetoothLowEnergyDefaults sharedDefaults] serviceUuids];
    
    XCTAssertEqual([uuids count], 2);
    
    BOOL equal = [((CBUUID*)[uuids objectAtIndex:1]).UUIDString isEqualToString:[TYM_SERVICE_UUID uppercaseString]];
    
    XCTAssertEqual(equal, YES);
}

- (void)testCharacteristicUuidsOfServiceUuid {
    // This is an example of a functional test case.
    
    NSArray* uuids = [[TAPBluetoothLowEnergyDefaults sharedDefaults] characteristicUuidsOfServiceUuid:@"7D24"];
    
    XCTAssertEqual([uuids count], 6);
    
    BOOL equal = [((CBUUID*)[uuids objectAtIndex:1]).UUIDString isEqualToString:[TYM_CHARACTERISTIC_BATTERY_READ uppercaseString]];
    
    XCTAssertEqual(equal, YES);
}

- (void)testServiceUuidFromCharacteristicUuid{
    
    NSString* serviceUuid = [[TAPBluetoothLowEnergyDefaults sharedDefaults] serviceUuidFromCharacteristicUuid:@"5345"];
    
    XCTAssertEqual([serviceUuid isEqualToString:@"7D24"], YES);
    
    serviceUuid = [[TAPBluetoothLowEnergyDefaults sharedDefaults] serviceUuidFromCharacteristicUuid:@"4000"];
    
    XCTAssertEqual([serviceUuid isEqualToString:@"7D23"], YES);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
