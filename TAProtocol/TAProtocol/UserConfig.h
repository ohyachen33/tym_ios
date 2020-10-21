//
//  UserConfig.h
//  TYM Transfer
//
//  Created by Ruben on 4/3/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#ifndef TYM_Transfer_UserConfig_h
#define TYM_Transfer_UserConfig_h


typedef NS_ENUM (NSInteger, TPSignalType){
    TPSignalTypeDisplaySetting = 0,
    TPSignalTypeTimeoutSetting,
    TPSignalTypeStandbySetting,
    
    TPSignalTypeLPOnOffSetting, //3
    TPSignalTypeLowPassFrequencySetting,
    TPSignalTypeLowPassSlopeSetting,

    TPSignalTypePEQ1SaveLoadSetting, //6
    TPSignalTypeEQ1FrequencySetting,
    TPSignalTypeEQ1BoostSetting,
    TPSignalTypeEQ1QFactorSetting,
    
    TPSignalTypePEQ2SaveLoadSetting, //10
    TPSignalTypeEQ2FrequencySetting,
    TPSignalTypeEQ2BoostSetting,
    TPSignalTypeEQ2QFactorSetting,
    
    TPSignalTypePEQ3SaveLoadSetting, //14
    TPSignalTypeEQ3FrequencySetting,
    TPSignalTypeEQ3BoostSetting,
    TPSignalTypeEQ3QFactorSetting,
    
    TPSignalTypeRGCOnOffSetting, //18
    TPSignalTypeRGCFrequencySetting,
    TPSignalTypeRGCSlopeSetting,
    
    TPSignalTypeVolumeSetting, //21
    TPSignalTypePhaseSetting,
    TPSignalTypePolaritySetting,
    TPSignalTypeTunningSetting, //24
    
    TPSignalTypeKey,
    
    TPSignalTypeTotalNumber
};

typedef NS_ENUM (NSInteger, TPSignalStringType){
    TPSignalStringTypeUserWelcomeInfo = 17,
    TPSignalStringTypePreset1Name,
    TPSignalStringTypePreset2Name,
    TPSignalStringTypePreset3Name,
    TPSignalStringTypeUnknown
};

typedef NS_ENUM (NSInteger, TPSignalPacketType){
    TPSignalPacketTypeWriteSetting = 0,
    TPSignalPacketTypeReadSetting,
    TPSignalPacketTypeKey
};

#define TPSignalTypeSettingBase TPSignalTypeLowPassFrequencySetting
#define TPSignalTypeSettingTop TPSignalTypeStandbySetting



#endif
