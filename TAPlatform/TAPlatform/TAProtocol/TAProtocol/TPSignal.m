//
//  TPSignalSVS.m
//  TPSignal
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import "TPSignal.h"
#import "TPSignalSender.h"
#import "TPSignalReceiver.h"
#import "TPSignalDataPacketEncoder.h"
#import "TPSignalWriteSettingPacketEncoder.h"
#import "TPSignalReadSettingPacketEncoder.h"
#import "TPSignalReadSettingResponseEncoder.h"
#import "TPSignalButtonPacketEncoder.h"
#import "TPSignalWriteStringsPacketEncoder.h"
#import "TPSignalResetItemPacketEncoder.h"
#import "TPSignalReadFeaturesPacketEncoder.h"
#import "TPSignalReadFeaturesResponseEncoder.h"
#import "TPSignalReadFactoryReset.h"
#import "TPSignalReadDFUPacketEncoder.h"
#import "TPSignalReadDFUResponseEncoder.h"
#import "TPSignalReadVersionEncoder.h"
#import "TPSignalReadVersionResponseEncoder.h"
#import "TPSignalReadProductPacketEncoder.h"
#import "TPSignalReadProductResponseDataPacketEncoder.h"
#import "TPSignalConfig.h"

@interface TPSignal() <TPSignalReceiverDelegate>

@property(nonatomic, strong)TPSignalReceiver *receiver;

@end

@implementation TPSignal


// extract a whole tp-sneak packet
- (void) parseTPSignalPacket:(NSData *)received_packet
{
    [self.receiver pushRawData:received_packet];
}

- (NSData*)keySignalWithKeyIdData:(NSData*)data type:(TPSignalType)type
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalButtonPacketEncoder* encoder = [[TPSignalButtonPacketEncoder alloc] init];
    NSData* packet = [sender assemblePacketWithHeaderBlock:[self getKeyHeaderBlock] encoder:encoder body:[self getKeyDataBody] value:data];
    
    DDLogVerbose(@"keySignalWithKeyIdData: %@", packet);
    return packet;
}

- (NSData*)settingReadSignalWithType:(TPSignalType)type
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
 
    TPSignalReadSettingPacketEncoder* setting_packet = [[TPSignalReadSettingPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getReadSettingHeaderBlock] encoder:setting_packet body:[self getReadSettingDataBodyWithOffset:[self getOffset:type]] value:nil];
    
    DDLogVerbose(@"Packet: %@", packet);
    return packet;
}

- (NSData*)settingReadSignalWithType:(TPSignalType)type size:(NSInteger)size
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalReadSettingPacketEncoder* setting_packet = [[TPSignalReadSettingPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getReadSettingHeaderBlock] encoder:setting_packet body:[self getReadSettingDataBodyWithOffset:[self getOffset:type] size:size] value:nil];
    
    DDLogVerbose(@"settingReadSignalWithValueData: %@", packet);
    return packet;
}

- (NSData*)settingWriteSignalWithData:(NSData*)data type:(TPSignalType)type
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalWriteSettingPacketEncoder* setting_packet = [[TPSignalWriteSettingPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getWriteSettingHeaderBlock] encoder:setting_packet body:[self getWriteSettingDataBodyWithOffset:[self getOffset:type]] value:data];
    
    DDLogVerbose(@"settingWriteSignalWithData: %@", packet);
    return packet;
}

- (NSData*)stringReadSignalWithType:(TPSignalStringType)type
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalReadSettingPacketEncoder* setting_packet = [[TPSignalReadSettingPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getReadStringsHeaderBlock] encoder:setting_packet body:[self getReadStringDataBodyWithSettingId:type] value:nil];
    
    DDLogVerbose(@"settingReadSignalWithValueData: %@", packet);
    return packet;
}

- (NSData*)stringWriteSignalWithData:(NSData*)data type:(TPSignalStringType)type
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    Byte size = [data length];
    
    TPSignalWriteStringsPacketEncoder* setting_packet = [[TPSignalWriteStringsPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getWriteStringsHeaderBlock] encoder:setting_packet body:[self getWriteStringDataBodyWithSettingId:type size:size] value:data];
    
    DDLogVerbose(@"stringWriteSignalWithData: %@", packet);
    return packet;
}

- (NSData*)featuresReadSignal
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalReadFeaturesPacketEncoder* setting_packet = [[TPSignalReadFeaturesPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getReadFeatureHeaderBlock] encoder:setting_packet body:nil value:nil];
    
    DDLogVerbose(@"featuresReadSignal: %@", packet);
    return packet;
}

- (NSData*)resetSignalWithType:(TPSignalType)type
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalResetItemPacketEncoder* reset_packet = [[TPSignalResetItemPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getResetItemHeaderBlock] encoder:reset_packet body:[self getResetItemDataBodyWithResetOptionID:[self getResetOptionID:type]] value:nil];
    
    DDLogVerbose(@"settingReadSignalWithValueData: %@", packet);
    return packet;
}

- (NSData*)enterDFUModeSignal
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalReadDFUPacketEncoder* UDF_packet = [[TPSignalReadDFUPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getEnterDFUModeHeaderBlock] encoder:UDF_packet body:[self getEnterDFUModeDataBody] value:nil];
    
    DDLogVerbose(@"enterDFUModeSignal: %@", packet);
    return packet;
}

- (NSData*)softwareVersionSignal
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalReadVersionEncoder* verison_packet = [[TPSignalReadVersionEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getSoftwareVersionHeaderBlock] encoder:verison_packet body:[self getVersionDataBody] value:nil];
    
    DDLogVerbose(@"softwareVersionSignal: %@", packet);
    return packet;
}

- (NSData*)productNameSignal
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalReadProductPacketEncoder* verison_packet = [[TPSignalReadProductPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getProductNameHeaderBlock] encoder:verison_packet body:[self getProductNameBody] value:nil];
    
    DDLogVerbose(@"productNameSignal: %@", packet);
    return packet;
}

- (id) initWithDelegate:(id<TPSignalDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.receiver = [[TPSignalReceiver alloc] initWithDelegate:self];
    }
    return self;
}

//////////////////////////////////

- (void) didParseDataPacket:(NSData*)data_packet type:(Byte)type
{
    TPSignalDataPacketEncoder* encoder = [self encoderForSignalType:type];
    NSData *item;
    TPSignalType item_type;
    if([encoder isKindOfClass:[TPSignalButtonPacketEncoder class]])
    {
        TPSignalButtonPacketEncoder *button_packet = (TPSignalButtonPacketEncoder *)encoder;
        int len_item;
        Byte *item_data = [button_packet getKeyId:data_packet length:&len_item];
        item =[NSData dataWithBytes:item_data length:len_item];
        item_type = TPSignalTypeKey;
    }
    else if ([encoder isKindOfClass:[TPSignalWriteSettingPacketEncoder class]])
    {
        TPSignalWriteSettingPacketEncoder *setting_packet = (TPSignalWriteSettingPacketEncoder*)encoder;
        int len_item;
        Byte *item_data = [setting_packet getData:data_packet length:&len_item];
        item =[NSData dataWithBytes:item_data length:len_item];
        Byte *item_type_data = [setting_packet getOffset:data_packet length:&len_item];
        
        item_type = [self getType:item_type_data[0]];
    }
    else if([encoder isKindOfClass:[TPSignalReadSettingPacketEncoder class]])
    {
        TPSignalReadSettingPacketEncoder *setting_packet = (TPSignalReadSettingPacketEncoder *)encoder;
        int len_item;
        Byte *item_data = [setting_packet getData:data_packet length:&len_item];
        item =[NSData dataWithBytes:item_data length:len_item];
        Byte *item_type_data = [setting_packet getOffset:data_packet length:&len_item];
        
        item_type = [self getType:item_type_data[0]];
        
    }else if([encoder isKindOfClass:[TPSignalReadSettingResponseEncoder class]])
    {
        TPSignalReadSettingResponseEncoder *responseEncoder = (TPSignalReadSettingResponseEncoder *)encoder;
        
        NSData* settingIdData = [NSData dataWithBytes:[responseEncoder getSettingId:data_packet] length:4];
        
        int16_t settingId;
        [settingIdData getBytes:&settingId length:sizeof(settingId)];
        
        if(settingId == SETID_MENU_DATA)
        {
            //menu data
            
            int len_item;
            Byte *item_data = [responseEncoder getData:data_packet length:&len_item];
            item =[NSData dataWithBytes:item_data length:len_item];
            Byte *item_type_data = [responseEncoder getOffset:data_packet length:&len_item];
            
            
            item_type = [self getType:item_type_data[0]];
            
        }else{
            
            //string case
            
            int len_item;
            Byte *item_data = [responseEncoder getData:data_packet length:&len_item];
            item =[NSData dataWithBytes:item_data length:len_item];
            
            NSString* stringItem = [[NSString alloc] initWithData:item encoding:NSASCIIStringEncoding];
            
            TPSignalStringType stringType = (TPSignalStringType)settingId;
            
            [self.delegate didReceiveStringItem:stringItem type:stringType];
            
            //TODO: refactor this method to exclude this extra exit point
            return;

        }
        
    }else if([encoder isKindOfClass:[TPSignalReadFeaturesResponseEncoder class]])
    {
        TPSignalReadFeaturesResponseEncoder *responseEncoder = (TPSignalReadFeaturesResponseEncoder *)encoder;
        
        int len_item;
        Byte *item_data = [responseEncoder getData:data_packet length:&len_item];
        
        item =[NSData dataWithBytes:item_data length:len_item];

        item_type = TPSignalTypeFeatureList;
    }else if([encoder isKindOfClass:[TPSignalReadFactoryReset class]])
    {
        TPSignalReadFactoryReset *responseEncoder = (TPSignalReadFactoryReset *)encoder;
        
        item_type = TPSignalTypeFactoryReset;
    }else if([encoder isKindOfClass:[TPSignalReadDFUResponseEncoder class]])
    {
        TPSignalReadDFUResponseEncoder *responseEncoder = (TPSignalReadDFUResponseEncoder *)encoder;
    
        item = data_packet;
        item_type = TPSignalTypeDFU;
    }else if([encoder isKindOfClass:[TPSignalReadVersionResponseEncoder class]])
    {
        TPSignalReadVersionResponseEncoder *responseEncoder = (TPSignalReadVersionResponseEncoder *)encoder;
        
        item = [responseEncoder getVersionData:data_packet];
        
        item_type = TPSignalTypeSoftwareVersion;
    }else if([encoder isKindOfClass:[TPSignalReadProductResponseDataPacketEncoder class]])
    {
        TPSignalReadProductResponseDataPacketEncoder *responseEncoder = (TPSignalReadProductResponseDataPacketEncoder *)encoder;
        
        item = [responseEncoder getProductData:data_packet];
        
        item_type = TPSignalTypeProductName;
    }

    [self.delegate didReceiveMessageItem:item type:item_type];
}

- (void)didFailToParseDataPackage:(NSData*)data error:(NSError*)error
{
    [self.delegate didFailToParseItem:data error:error];
}

- (TPSignalDataPacketEncoder*) encoderForSignalType:(Byte)type
{
    DDLogVerbose(@"%d", (int)type);
    
    TPSignalDataPacketEncoder* encoder;

    switch (type)
    {
        case SETTING_WRITE_OFFSET_REQ_SIG:
        {
            encoder = [[TPSignalWriteSettingPacketEncoder alloc] init];
        }
            break;
        case SETTING_READ_OFFSET_REQ_SIG:
        {
            encoder = [[TPSignalReadSettingPacketEncoder alloc] init];
        }
            break;
        case SETTING_READ_OFFSET_RESP_SIG:
        {
            encoder = [[TPSignalReadSettingResponseEncoder alloc] init];
        }
            break;
        case FEATURE_READ_RESP_SIG:
        {
            encoder = [[TPSignalReadFeaturesResponseEncoder alloc] init];
        }
            break;
        case KEY_STATE_SIG:
        {
            encoder = [[TPSignalButtonPacketEncoder alloc] init];
        }
            break;
        case FACTORY_RESET_REQ_SIG:
        {
            encoder = [[TPSignalReadFactoryReset alloc] init];
        }
            break;
        case MAINAPP_DFU_RESP_SIG:
        {
            encoder = [[TPSignalReadDFUResponseEncoder alloc] init];
        }
            break;
        case MAINAPP_VERSION_RESP_SIG:
        {
            encoder = [[TPSignalReadVersionResponseEncoder alloc] init];
        }
            break;
        case PRODUCT_NAME_RESP_SIG:
        {
            encoder = [[TPSignalReadProductResponseDataPacketEncoder alloc] init];
        }
            break;
        default:
            break;
    }
    
    return encoder;
}

//Okay. So how we can get rid of this again?
- (TAPropertyType)propertyTypeFromSignalType:(TPSignalType)signalType
{
    TAPropertyType type = TAPropertyTypeUnknown;
    
    if(signalType == TPSignalTypeDisplaySetting)
    {
        type = TAPropertyTypeDisplay;
    }
    else if(signalType == TPSignalTypeTimeoutSetting)
    {
        type = TAPropertyTypeTimeout;
    }
    else if(signalType == TPSignalTypeStandbySetting)
    {
        type = TAPropertyTypeStandby;
    }
    else if(signalType == TPSignalTypeBrightnessSetting)
    {
        type = TAPropertyTypeBrightness;
    }
    else if(signalType == TPSignalTypeVolumeSetting)
    {
        type = TAPropertyTypeVolume;
    }
    else if(signalType == TPSignalTypeLPOnOffSetting)
    {
        type = TAPropertyTypeLowPassOnOff;
    }
    else if(signalType == TPSignalTypeLowPassFrequencySetting)
    {
        type = TAPropertyTypeLowPassFrequency;
    }
    else if(signalType == TPSignalTypeLowPassSlopeSetting)
    {
        type = TAPropertyTypeLowPassSlope;
    }
    else if(signalType == TPSignalTypePhaseSetting)
    {
        type = TAPropertyTypePhase;
    }
    else if(signalType == TPSignalTypePolaritySetting)
    {
        type = TAPropertyTypePolarity;
    }
    else if(signalType == TPSignalTypeRGCOnOffSetting)
    {
        type = TAPropertyTypeRGCOnOff;
    }
    else if(signalType == TPSignalTypeRGCFrequencySetting)
    {
        type = TAPropertyTypeRGCFrequency;
    }
    else if(signalType == TPSignalTypeRGCSlopeSetting)
    {
        type = TAPropertyTypeRGCSlope;
    }
    else if(signalType == TPSignalTypeTuningSetting)
    {
        type = TAPropertyTypeTuning;
    }
    else if(signalType == TPSignalTypePEQ1SaveLoadSetting)
    {
        type = TAPropertyTypePEQ1OnOff;
        
    }else if(signalType == TPSignalTypeEQ1BoostSetting)
    {
        type = TAPropertyTypeEQ1Boost;
    }
    else if(signalType == TPSignalTypeEQ1FrequencySetting)
    {
        type = TAPropertyTypeEQ1Frequency;
    }
    else if(signalType == TPSignalTypeEQ1QFactorSetting)
    {
        type = TAPropertyTypeEQ1QFactor;
    }
    else if(signalType == TPSignalTypePEQ2SaveLoadSetting)
    {
        type = TAPropertyTypePEQ2OnOff;
    }
    else if(signalType == TPSignalTypeEQ2BoostSetting)
    {
        type = TAPropertyTypeEQ2Boost;
    }
    else if(signalType == TPSignalTypeEQ2FrequencySetting)
    {
        type = TAPropertyTypeEQ2Frequency;
    }
    else if(signalType == TPSignalTypeEQ2QFactorSetting)
    {
        type = TAPropertyTypeEQ2QFactor;
    }
    else if(signalType == TPSignalTypePEQ3SaveLoadSetting)
    {
        type = TAPropertyTypePEQ3OnOff;
    }
    else if(signalType == TPSignalTypeEQ3BoostSetting)
    {
        type = TAPropertyTypeEQ3Boost;
    }
    else if(signalType == TPSignalTypeEQ3FrequencySetting)
    {
        type = TAPropertyTypeEQ3Frequency;
    }
    else if(signalType == TPSignalTypeEQ3QFactorSetting)
    {
        type = TAPropertyTypeEQ3QFactor;
    }else if(signalType == TPSignalTypeFeatureList)
    {
        type = TAPropertyTypeAvailableFeatures;
    }else if (signalType == TPSignalTypeFactoryReset)
    {
        type = TAPropertyTypeFactoryReset;
    }else if (signalType == TPSignalTypeDFU)
    {
        type = TAPropertyTypeDFU;
    }else if (signalType == TPSignalTypeSoftwareVersion)
    {
        type = TAPropertyTypeSoftwareVersion;
    }else if (signalType == TPSignalTypeProductName)
    {
        type = TAPropertyTypeProductName;
    }

    return type;
}



// helper function
// TODO: read from a config file
- (NSData*) getReadSettingHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = SETTING_READ_OFFSET_REQ_SIG;
    header_stream[2] = SRV_ID;
    header_stream[3] = SETTING_READ_PACKET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getWriteSettingHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = SETTING_WRITE_OFFSET_REQ_SIG;
    header_stream[2] = SRV_ID;
    header_stream[3] = SETTING_WRITE_PACKET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getReadStringsHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = STRING_READ_REQ_SIG;
    header_stream[2] = SRV_ID;
    header_stream[3] = STRING_READ_PACKET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getWriteStringsHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = STRING_WRITE_OFFSET_REQ_SIG;
    header_stream[2] = SRV_ID;
    header_stream[3] = STRING_WRITE_PACKET_SIZE + STRING_WRITE_DATA_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getReadFeatureHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = FEATURE_READ_REQ_SIG;
    header_stream[2] = SRV_ID;
    header_stream[3] = FEATURE_READ_PACKET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getResetItemHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = RESET_ITEM_REQ_SIG;
    header_stream[2] = SRV_ID;
    header_stream[3] = RESET_ITEM_PACKET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getEnterDFUModeHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = MAINAPP_DFU_REQ_SIG;
    header_stream[2] = SRV_ID;
    header_stream[3] = MAINAPP_DFU_PACKET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
    
}

- (NSData*) getSoftwareVersionHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = MAINAPP_VERSION_REQ_SIG;
    header_stream[2] = SRV_ID;
    header_stream[3] = MAINAPP_VERSION_PACKET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
    
}

- (NSData*) getProductNameHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = PRODUCT_NAME_REQ_SIG;
    header_stream[2] = SRV_ID;
    header_stream[3] = PRODUCT_NAME_PACKET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
    
}


- (NSData*) getReadSettingDataBodyWithOffset:(Byte)offset
{
    Byte data_stream[10] = {0};
    data_stream[0] = SETID_MENU_DATA;
    data_stream[4] = offset;
    data_stream[6] = 2;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getReadSettingDataBodyWithOffset:(Byte)offset size:(Byte)size
{
    Byte data_stream[10] = {0};
    data_stream[0] = SETID_MENU_DATA;
    data_stream[4] = offset;
    data_stream[6] = size;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getWriteSettingDataBodyWithOffset:(Byte)offset
{
    Byte data_stream[10] = {0};
    data_stream[0] = SETID_MENU_DATA;
    data_stream[4] = offset;
    data_stream[6] = 2; //size
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getReadStringDataBodyWithSettingId:(Byte)settingId
{
    Byte data_stream[10] = {0};
    data_stream[0] = settingId;
    data_stream[4] = 0;
    data_stream[6] = 8;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getWriteStringDataBodyWithSettingId:(Byte)settingId size:(Byte)size
{
    Byte data_stream[10] = {0};
    data_stream[0] = settingId;
    data_stream[4] = 0;
    data_stream[6] = 8;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getResetItemDataBodyWithResetOptionID:(Byte)resetOptionId
{
    Byte data_stream[1] = {0};
    data_stream[0] = resetOptionId;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getEnterDFUModeDataBody
{
    Byte data_stream[1] = {0};
    data_stream[0] = 0;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getVersionDataBody
{
    Byte data_stream[1] = {0};
    data_stream[0] = 0;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getProductNameBody
{
    Byte data_stream[1] = {0};
    data_stream[0] = 0;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (Byte)getOffset:(TPSignalType)type
{
    //offset need to be multiple by two and this is defined in system side
    return type * 2;
}

- (TPSignalType) getType:(Byte)offset
{
    return offset / 2;
}

- (Byte)getResetOptionID:(TPSignalType)type
{
    switch (type) {
        case TPSignalTypeDisplaySetting:
        case TPSignalTypeTimeoutSetting:
        case TPSignalTypeStandbySetting:
        {
            return type;
        }
            break;
        case TPSignalTypeLPOnOffSetting:
        case TPSignalTypeLowPassFrequencySetting:
        case TPSignalTypeLowPassSlopeSetting:
        {
            return 3;
        }
            break;
        case TPSignalTypePEQ1SaveLoadSetting:
        case TPSignalTypeEQ1BoostSetting:
        case TPSignalTypeEQ1FrequencySetting:
        case TPSignalTypeEQ1QFactorSetting:
        {
            return 5;
        }
            break;
        case TPSignalTypePEQ2SaveLoadSetting:
        case TPSignalTypeEQ2BoostSetting:
        case TPSignalTypeEQ2FrequencySetting:
        case TPSignalTypeEQ2QFactorSetting:
        {
            return 6;
        }
            break;
        case TPSignalTypePEQ3SaveLoadSetting:
        case TPSignalTypeEQ3BoostSetting:
        case TPSignalTypeEQ3FrequencySetting:
        case TPSignalTypeEQ3QFactorSetting:
        {
            return 7;
        }
            break;
        case TPSignalTypeRGCOnOffSetting:
        case TPSignalTypeRGCFrequencySetting:
        case TPSignalTypeRGCSlopeSetting:
        {
            return 8;
        }
            break;
        case TPSignalTypePhaseSetting:
        {
            return 9;
        }
            break;
        case TPSignalTypePolaritySetting:
        {
            return 10;
        }
            break;
        case TPSignalTypeTuningSetting:
        {
            return 11;
        }
            break;
        case TPSignalTypeVolumeSetting:
        {
            return 12;
        }
            break;
        case TPSignalTypePresetName:
        {
            return 13;
        }
            break;
        case TPSignalTypeBrightnessSetting:
        {
            return 14;
        }
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (NSData*) getKeyHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = KEY_STATE_SIG;
    header_stream[2] = KEY_SRV_ID;
    header_stream[3] = KEY_PAKCET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getKeyDataBody
{
    Byte data_stream[12] = {0};
    data_stream[4] = KEY_EVT_DOWN;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}


@end
