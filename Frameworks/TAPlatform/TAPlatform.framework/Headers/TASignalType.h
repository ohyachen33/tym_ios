//
//  TASignalType.h
//  TYM Transfer
//
//  Created by John.Xu on 4/3/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#ifndef TYM_Transfer_UserConfig_h
#define TYM_Transfer_UserConfig_h

// TODO: move to config file
#define KEY_STATE_SIG (7)
#define KEY_SRV_ID (4)

#define SETTING_WRITE_OFFSET_REQ_SIG (240)
#define STRING_WRITE_OFFSET_REQ_SIG (240)
#define SETTING_READ_OFFSET_REQ_SIG (241)
#define STRING_READ_REQ_SIG (241)
#define SETTING_READ_OFFSET_RESP_SIG (242)
#define RESET_ITEM_REQ_SIG (243)
#define FEATURE_READ_REQ_SIG (244)
#define FEATURE_READ_RESP_SIG (245)
#define FACTORY_RESET_REQ_SIG (246)
#define MAINAPP_DFU_REQ_SIG (250)
#define MAINAPP_DFU_RESP_SIG (251)
#define MAINAPP_VERSION_REQ_SIG (252)
#define MAINAPP_VERSION_RESP_SIG (253)
#define PRODUCT_NAME_REQ_SIG (254)
#define PRODUCT_NAME_RESP_SIG (255)


#define SRV_ID (31)

#define SEQ (0XAA)

#define OFFSET_SIZE (3)
#define OFFSET_TYPE_PACKET (1)
#define KEY_PAKCET_SIZE (15)

#define SETTING_WRITE_PACKET_SIZE (17)
#define SETTING_READ_PACKET_SIZE (15)
#define RESET_ITEM_PACKET_SIZE (8)
#define STRING_WRITE_PACKET_SIZE (15)
#define STRING_WRITE_DATA_SIZE (8)
#define STRING_READ_PACKET_SIZE (15)
#define FEATURE_READ_PACKET_SIZE (7)
#define KEY_EVT_SHORT_PRESS (7)
#define KEY_EVT_DOWN (1)
#define MAINAPP_DFU_PACKET_SIZE (8)
#define MAINAPP_VERSION_PACKET_SIZE (8)
#define PRODUCT_NAME_PACKET_SIZE (8)

#define SETID_MENU_DATA (4)


typedef NS_ENUM (NSInteger, TPSignalType){
    TPSignalTypeDisplaySetting = 0,
    TPSignalTypeTimeoutSetting,
    TPSignalTypeStandbySetting,
    TPSignalTypeBrightnessSetting,
    
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
    TPSignalTypeTuningSetting, //24
    
    TPSignalTypePresetName,
    
    TPSignalTypeKey,
    
    TPSignalTypeFeatureList,
    
    TPSignalTypeTotalNumber,
    
    TPSignalTypeFactoryReset,
    
    TPSignalTypeDFU,
    
    TPSignalTypeSoftwareVersion,
    TPSignalTypeProductName
};

typedef NS_ENUM (NSInteger, TPSignalStringType){
    TPSignalStringTypePreset1Name = 8,
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
