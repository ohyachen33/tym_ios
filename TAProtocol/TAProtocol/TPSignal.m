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

// TODO: move to config file
#define KEY_STATE_SIG (7)
#define KEY_SRV_ID (4)

#define SETTING_WRITE_OFFSET_REQ_SIG (89)
#define SETTING_WRITE_STR_OFFSET_REQ_SIG (89)
#define SETTING_READ_OFFSET_REQ_SIG (90)
#define SETTING_READ_STR_REQ_SIG (90)
#define SETTING_READ_OFFSET_RESP_SIG (41)

#define SETTING_SRV_ID (11)

#define SEQ (0XAA)

#define OFFSET_SIZE (3)
#define OFFSET_TYPE_PACKET (1)
#define KEY_PAKCET_SIZE (19)

#define SETTING_WRITE_PAKCET_SIZE (25)
#define SETTING_READ_PAKCET_SIZE (23)
#define SETTING_WRITE_STR_PAKCET_SIZE (23)
#define SETTING_READ_STR_PAKCET_SIZE (23)
#define KEY_EVT_SHORT_PRESS (7)

#define SETID_MENU_DATA (12)

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
    
    NSLog(@"keySignalWithKeyIdData: %@", packet);
    return packet;
}

- (NSData*)settingReadSignalWithType:(TPSignalType)type
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
 
    TPSignalReadSettingPacketEncoder* setting_packet = [[TPSignalReadSettingPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getReadSettingHeaderBlock] encoder:setting_packet body:[self getReadSettingDataBodyWithOffset:[self getOffset:type]] value:nil];
    
    NSLog(@"settingReadSignalWithValueData: %@", packet);
    return packet;
}

- (NSData*)settingReadSignalWithType:(TPSignalType)type size:(NSInteger)size
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalReadSettingPacketEncoder* setting_packet = [[TPSignalReadSettingPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getReadSettingHeaderBlock] encoder:setting_packet body:[self getReadSettingDataBodyWithOffset:[self getOffset:type] size:size] value:nil];
    
    NSLog(@"settingReadSignalWithValueData: %@", packet);
    return packet;
}

- (NSData*)settingWriteSignalWithData:(NSData*)data type:(TPSignalType)type
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalWriteSettingPacketEncoder* setting_packet = [[TPSignalWriteSettingPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getWriteSettingHeaderBlock] encoder:setting_packet body:[self getWriteSettingDataBodyWithOffset:[self getOffset:type]] value:data];
    
    NSLog(@"settingWriteSignalWithData: %@", packet);
    return packet;
}

- (NSData*)stringReadSignalWithType:(TPSignalStringType)type
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    TPSignalReadSettingPacketEncoder* setting_packet = [[TPSignalReadSettingPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getReadStringsHeaderBlock] encoder:setting_packet body:[self getReadStringDataBodyWithSettingId:type] value:nil];
    
    NSLog(@"settingReadSignalWithValueData: %@", packet);
    return packet;
}

- (NSData*)stringWriteSignalWithData:(NSData*)data type:(TPSignalStringType)type
{
    TPSignalSender *sender = [[TPSignalSender alloc] init];
    
    Byte size = [data length];
    
    TPSignalWriteStringsPacketEncoder* setting_packet = [[TPSignalWriteStringsPacketEncoder alloc] init];
    NSData* packet  = [sender assemblePacketWithHeaderBlock:[self getWriteStringsHeaderBlockWithSize:size] encoder:setting_packet body:[self getWriteStringDataBodyWithSettingId:type size:size] value:data];
    
    NSLog(@"stringWriteSignalWithData: %@", packet);
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
        
    }

    [self.delegate didReceiveMessageItem:item type:item_type];
}

- (void)didFailToParseDataPackage:(NSData*)data error:(NSError*)error
{
    [self.delegate didFailToParseItem:data error:error];
}

- (TPSignalDataPacketEncoder*) encoderForSignalType:(Byte)type
{
    NSLog(@"%d", (int)type);
    
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
        case KEY_STATE_SIG:
        {
            encoder = [[TPSignalButtonPacketEncoder alloc] init];
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
    else if(signalType == TPSignalTypeTunningSetting)
    {
        type = TAPropertyTypeTunning;
    }
    else if(signalType == TPSignalTypeEQ1BoostSetting)
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
    header_stream[2] = SETTING_SRV_ID;
    header_stream[3] = SETTING_READ_PAKCET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getWriteSettingHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = SETTING_WRITE_OFFSET_REQ_SIG;
    header_stream[2] = SETTING_SRV_ID;
    header_stream[3] = SETTING_WRITE_PAKCET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getReadStringsHeaderBlock
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = SETTING_READ_STR_REQ_SIG;
    header_stream[2] = SETTING_SRV_ID;
    header_stream[3] = SETTING_READ_STR_PAKCET_SIZE;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getWriteStringsHeaderBlockWithSize:(NSInteger)size
{
    Byte header_stream[5];
    header_stream[0] = 0xaa;
    header_stream[1] = SETTING_WRITE_STR_OFFSET_REQ_SIG;
    header_stream[2] = SETTING_SRV_ID;
    header_stream[3] = SETTING_WRITE_STR_PAKCET_SIZE + size;
    header_stream[4] = 0;
    NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
    return header_block;
}

- (NSData*) getReadSettingDataBodyWithOffset:(Byte)offset
{
    Byte data_stream[18] = {0};
    data_stream[8] = SETID_MENU_DATA;
    data_stream[12] = offset;
    data_stream[14] = 2;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getReadSettingDataBodyWithOffset:(Byte)offset size:(Byte)size
{
    Byte data_stream[18] = {0};
    data_stream[8] = SETID_MENU_DATA;
    data_stream[12] = offset;
    data_stream[14] = size;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getWriteSettingDataBodyWithOffset:(Byte)offset
{
    Byte data_stream[18] = {0};
    data_stream[8] = SETID_MENU_DATA;
    data_stream[12] = offset;
    data_stream[14] = 2; //size
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getReadStringDataBodyWithSettingId:(Byte)settingId
{
    Byte data_stream[16] = {0};
    data_stream[8] = settingId;
    data_stream[12] = 0;
    data_stream[14] = 8;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (NSData*) getWriteStringDataBodyWithSettingId:(Byte)settingId size:(Byte)size
{
    Byte data_stream[24] = {0};
    data_stream[8] = settingId;
    data_stream[12] = 0;
    data_stream[14] = size;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}

- (Byte) getOffset:(TPSignalType) type
{
    //offset need to be multiple by two and this is defined in system side
    return type * 2;
}

- (TPSignalType) getType:(Byte)offset
{
    return offset / 2;
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
    data_stream[8] = KEY_EVT_SHORT_PRESS;
    NSData* data_block = [NSData dataWithBytes:data_stream length:sizeof(data_stream)];
    return data_block;
}


@end
