//
//  TAPropertyPreset.m
//  TAPlatform
//
//  Created by Lam Yick Hong on 12/5/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "TAPropertyPreset.h"
#import "TASignalType.h"
#import "TPSignalConfig.h"

@interface TAPropertyPreset()

@property (readwrite) TAPropertyPresetSubType subType;
@property (readwrite) NSInteger index;

@end

@implementation TAPropertyPreset

- (id)initWithSubType:(TAPropertyPresetSubType)subType index:(NSInteger)index
{
    if(self = [super init])
    {
        self.subType = subType;
        self.index = index;
    }
    
    return self;
}

- (NSData*)dataBySignal:(TPSignal*)signal writeData:(NSData*)data
{
    NSData* result;
    
    switch (self.subType) {
        case TAPropertyPresetSubTypeLoad:
        {
            NSString* presetId = (NSString*)data;
            
            NSData* value = nil;
            
            if([presetId isEqualToString:@"1"]){
                
                value = [TPSignalConfig dataForLoadPresetOne];
                
            }else if([presetId isEqualToString:@"2"]){
                
                value = [TPSignalConfig dataForLoadPresetTwo];
                
            }else if([presetId isEqualToString:@"3"]){
                
                value = [TPSignalConfig dataForLoadPresetThree];
                
            }else if([presetId isEqualToString:@"4"]){
                
                value = [TPSignalConfig dataForLoadPresetDefault];
                
            }
            
            result = [signal keySignalWithKeyIdData:value type:TPSignalTypeKey];
            
        }
            break;
        case TAPropertyPresetSubTypeSave:
        {
            NSString* presetId = (NSString*)data;
            
            NSData* value = nil;
            
            if([presetId isEqualToString:@"1"]){
                
                value = [TPSignalConfig dataForSavePresetOne];
                
            }else if([presetId isEqualToString:@"2"]){
                
                value = [TPSignalConfig dataForSavePresetTwo];
                
            }else if([presetId isEqualToString:@"3"]){
                
                value = [TPSignalConfig dataForSavePresetThree];
                
            }
            
            result = [signal keySignalWithKeyIdData:value type:TPSignalTypeKey];
        }
            break;
        case TAPropertyPresetSubTypeName:
        {
            TPSignalStringType stringType;
            switch (self.index) {
                case 0:
                {
                    stringType = TPSignalStringTypePreset1Name ;
                }
                    break;
                case 1:
                {
                    stringType = TPSignalStringTypePreset2Name;
                }
                    break;
                case 2:
                {
                    stringType = TPSignalStringTypePreset3Name;
                }
                    break;
                default:
                    break;
            }
            
            result = [signal stringWriteSignalWithData:data type:stringType];
        }
            break;
            
        default:
            break;
    }
    
    return result;
}

- (TPSignalType)signalType
{
    TPSignalType signalType = TPSignalTypeTotalNumber;
    
    switch (self.subType) {
        case TAPropertyPresetSubTypeLoad:
        {
            signalType = TPSignalTypeKey;
        }
            break;
        case TAPropertyPresetSubTypeSave:
        {
            signalType = TPSignalTypeKey;
        }
            break;
        case TAPropertyPresetSubTypeName:
        {
            signalType = TPSignalTypePresetName;
        }
            break;

        default:
            break;
    };
    
    return signalType;
}

@end
