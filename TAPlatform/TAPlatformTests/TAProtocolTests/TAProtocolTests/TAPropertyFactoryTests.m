//
//  TAPropertyFactoryTests.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 13/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TAPProtocolAdaptor.h"
#import "TAPropertyFactory.h"

@interface TAPropertyFactoryTests : XCTestCase

@end

@implementation TAPropertyFactoryTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreatePropertyWithType {
    
    TAProperty* property = nil;
    
    //volume
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeVolume];    
    XCTAssertTrue([property isKindOfClass:[TAPropertyVolume class]]);
    
    //Low pass filter
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeLowPassOnOff];
    XCTAssertTrue([property isKindOfClass:[TAPropertyLowPassFilter class]]);
    XCTAssertEqual(((TAPropertyLowPassFilter*)property).subType, TAPropertyLowPassFilterSubTypeOnOff);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeLowPassFrequency];
    XCTAssertTrue([property isKindOfClass:[TAPropertyLowPassFilter class]]);
    XCTAssertEqual(((TAPropertyLowPassFilter*)property).subType, TAPropertyLowPassFilterSubTypeFrequency);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeLowPassSlope];
    XCTAssertTrue([property isKindOfClass:[TAPropertyLowPassFilter class]]);
    XCTAssertEqual(((TAPropertyLowPassFilter*)property).subType, TAPropertyLowPassFilterSubTypeSlope);
    
    //RGC
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeRGCOnOff];
    XCTAssertTrue([property isKindOfClass:[TAPropertyRGC class]]);
    XCTAssertEqual(((TAPropertyRGC*)property).subType, TAPropertyRGCSubTypeOnOff);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeRGCFrequency];
    XCTAssertTrue([property isKindOfClass:[TAPropertyRGC class]]);
    XCTAssertEqual(((TAPropertyRGC*)property).subType, TAPropertyRGCSubTypeFrequency);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeRGCSlope];
    XCTAssertTrue([property isKindOfClass:[TAPropertyRGC class]]);
    XCTAssertEqual(((TAPropertyRGC*)property).subType, TAPropertyRGCSubTypeSlope);
    
    //Phase
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypePhase];
    XCTAssertTrue([property isKindOfClass:[TAPropertyPhase class]]);
    XCTAssertEqual(((TAPropertyPhase*)property).subType, TAPropertyPhaseSubTypePhase);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypePolarity];
    XCTAssertTrue([property isKindOfClass:[TAPropertyPhase class]]);
    XCTAssertEqual(((TAPropertyPhase*)property).subType, TAPropertyPhaseSubTypePolarity);
    
    //Port tuning
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeTuning];
    XCTAssertTrue([property isKindOfClass:[TAPropertyPortTuning class]]);
    
    //PEQ1
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypePEQ1OnOff];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeOnOff);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 0);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeEQ1Boost];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeBoost);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 0);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeEQ1Frequency];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeFrequency);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 0);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeEQ1QFactor];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeQFactor);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 0);
    
    //PEQ2
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypePEQ2OnOff];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeOnOff);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 1);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeEQ2Boost];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeBoost);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 1);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeEQ2Frequency];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeFrequency);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 1);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeEQ2QFactor];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeQFactor);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 1);
    
    //PEQ3
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypePEQ3OnOff];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeOnOff);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 2);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeEQ3Boost];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeBoost);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 2);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeEQ3Frequency];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeFrequency);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 2);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeEQ3QFactor];
    XCTAssertTrue([property isKindOfClass:[TAPropertyParametricEQ class]]);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).subType, TAPropertyParametricEQSubTypeQFactor);
    XCTAssertEqual(((TAPropertyParametricEQ*)property).index, 2);
    
    //Settings
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeDisplay];
    XCTAssertTrue([property isKindOfClass:[TAPropertySettings class]]);
    XCTAssertEqual(((TAPropertySettings*)property).subType, TAPropertySettingsSubTypeDisplay);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeStandby];
    XCTAssertTrue([property isKindOfClass:[TAPropertySettings class]]);
    XCTAssertEqual(((TAPropertySettings*)property).subType, TAPropertySettingsSubTypeStandby);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeTimeout];
    XCTAssertTrue([property isKindOfClass:[TAPropertySettings class]]);
    XCTAssertEqual(((TAPropertySettings*)property).subType, TAPropertySettingsSubTypeTimeout);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeFactoryReset];
    XCTAssertTrue([property isKindOfClass:[TAPropertySettings class]]);
    XCTAssertEqual(((TAPropertySettings*)property).subType, TAPropertySettingsSubTypeFactoryReset);
    
    //Display
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeBrightness];
    XCTAssertTrue([property isKindOfClass:[TAPropertyScreenDisplay class]]);
    XCTAssertEqual(((TAPropertyScreenDisplay*)property).subType, TAPropertyScreenDisplaySubTypeBrightness);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypeScreenOnOff];
    XCTAssertTrue([property isKindOfClass:[TAPropertyScreenDisplay class]]);
    XCTAssertEqual(((TAPropertyScreenDisplay*)property).subType, TAPropertyScreenDisplaySubTypeToggleOnOff);
    
    //Preset save/load
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypePresetLoading];
    XCTAssertTrue([property isKindOfClass:[TAPropertyPreset class]]);
    XCTAssertEqual(((TAPropertyPreset*)property).subType, TAPropertyPresetSubTypeLoad);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypePresetSaving];
    XCTAssertTrue([property isKindOfClass:[TAPropertyPreset class]]);
    XCTAssertEqual(((TAPropertyPreset*)property).subType, TAPropertyPresetSubTypeSave);
    
    //Preset name
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypePresetName1];
    XCTAssertTrue([property isKindOfClass:[TAPropertyPreset class]]);
    XCTAssertEqual(((TAPropertyPreset*)property).subType, TAPropertyPresetSubTypeName);
    XCTAssertEqual(((TAPropertyPreset*)property).index, 0);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypePresetName2];
    XCTAssertTrue([property isKindOfClass:[TAPropertyPreset class]]);
    XCTAssertEqual(((TAPropertyPreset*)property).subType, TAPropertyPresetSubTypeName);
    XCTAssertEqual(((TAPropertyPreset*)property).index, 1);
    
    property = [TAPropertyFactory createPropertyWithType:TAPropertyTypePresetName3];
    XCTAssertTrue([property isKindOfClass:[TAPropertyPreset class]]);
    XCTAssertEqual(((TAPropertyPreset*)property).subType, TAPropertyPresetSubTypeName);
    XCTAssertEqual(((TAPropertyPreset*)property).index, 2);
}


@end
