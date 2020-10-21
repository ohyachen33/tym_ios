//
//  TAPFirmwareOverTheAirUpdateService.m
//  TAPlatform
//
//  Created by Alain Hsu on 14/02/2017.
//  Copyright © 2017 Tymphany. All rights reserved.
//

#import "TAPFirmwareOverTheAirUpdateService.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TAPSystem.h"
#import "parser.h"
#import "utils.h"

#define kDevicesInUpdatedKey @"DevicesInUpdated"
#define kRetryTimes 2

NSString * const TAPProtocolKeyProductName              =   @"TAPProtocolKeyProductName";

typedef NS_ENUM(NSUInteger, DFUCommand) {
    DFUCommandStart = 0,
    DFUCommandGet = 1,
    DFUCommandRead = 2,
    DFUCommandReadProductName = 3,
    DFUCommandErase = 4,
    DFUCommandWrite = 5,
    DFUCommandGo = 6,
};

typedef NS_ENUM(NSUInteger, DFUNextStep) {
    DFUNextStepBeginning = 0,
    DFUNextStepResume = 1,
    DFUNextStepProductName = 2,
};

typedef struct {
    size_t		data_len, offset;
    uint8_t		*data;
    uint8_t		base;
} hex_t;


@interface TAPService(Private)

@property (nonatomic, strong) id<TAPProtocolAdaptor> protocolProxy;
@property (nonatomic, strong) NSMutableDictionary* observers;

- (void)read:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)write:(TAPropertyType)targetType data:(id)data system:(id)system handler:(void (^)(id, NSError*))block;
- (void)reset:(TAPropertyType)targetType system:(id)system handler:(void (^)(NSDictionary*, NSError*))block;
- (void)subscribe:(TAPropertyType)targetType system:(id)system;
- (void)unsubscribe:(TAPropertyType)targetType system:(id)system;
- (NSError*)unsupportedErrorWithInfo:(NSDictionary*)info;
- (void)registerReadObserver:(id)observer forKey:(id)observerKey;

@end

@interface TAPFirmwareOverTheAirUpdateService (){
    BOOL _hasMadeHandShake;
    BOOL _shouldReceiveBuffer;
    
    int _eraseAddress;
    int _eraseLength;
    
    NSData* _headAddress;
    int _writeLine;
    int _writeLineNumber;
    NSMutableArray* _OTADataArray;
    NSMutableData* _readBuffer;
    
    NSData* _lastWrittenAddress;
    NSData* _lastWrittenData;
    
    NSData* _cmdBuffer; //store last sent bootloader command, use to retry when timeout
    
    int _retry;
    
    NSInteger _step;
    DFUCommand _command;
    DFUNextStep _stepIndicator;
    
    NSData* _lastSentCmd;
    
    hex_t* _st;
}

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) TAPSystem* currentSystem;

@end

@implementation TAPFirmwareOverTheAirUpdateService

void* hex_init() {
    return calloc(sizeof(hex_t), 1);
}

- (BOOL)checkFirmwareIsDFUMode:(id)system
{
    NSDictionary *updatedDeviceDic = [[NSUserDefaults standardUserDefaults] objectForKey:kDevicesInUpdatedKey]?:[NSDictionary new];
    
    if ([updatedDeviceDic.allKeys containsObject:((CBPeripheral*)[system instance]).identifier.UUIDString]) {
        return YES;
    }else{
        return NO;
    }
}

- (int)checkUpdateProgress:(id)system
{
    NSMutableDictionary *updatedDeviceDic = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kDevicesInUpdatedKey]]?:[NSMutableDictionary new];
    
    NSString *uuidString = ((CBPeripheral*)[system instance]).identifier.UUIDString;
    
    NSDictionary *deviceInfo = updatedDeviceDic[uuidString];
    NSNumber *progress;
    if (deviceInfo[@"progress"]) {
        progress = deviceInfo[@"progress"];
        return [progress intValue];
    }
    return 0;
}

- (void)system:(id)system getProductName:(void (^)(NSString*))complete
{
    self.currentSystem = system;
    
    NSString* observerKey = [self observerKeyFromTimestamp];
    
    _readBuffer= [NSMutableData new];
    _shouldReceiveBuffer = NO;
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TAPProtocolKeyProductName object:nil queue:nil usingBlock:^(NSNotification* note){
        
        //The return data should be 17 bytes (ACK 1byte + data 16bytes)
        //It can be divided into 2 pieces which cause by BLE polling, here we need to append the data
        
        NSData *valueData = [_readBuffer subdataWithRange:NSMakeRange(1, _readBuffer.length-1)];
        NSString *name = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
        
        NSRange range= [name rangeOfString:@"\0"];
        if (range.location == NSNotFound) {
            complete(nil);
            
        }else{
            name = [name substringToIndex:range.location];
            //only return result if we have a observer, it means it's the first result
            //Return the name
            complete(name);
            
        }
        
        id targetObserver = [[self.observers objectForKey:observerKey] objectForKey:@"observer"];
        
        if(targetObserver)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:targetObserver name:TAPProtocolKeyProductName object:nil];
            [self.observers removeObjectForKey:observerKey];
            _readBuffer = nil;
        }
        
    }];
    
    [self registerReadObserver:observer forKey:observerKey];
    
    _stepIndicator = DFUNextStepProductName;
    _command = DFUCommandStart;
    [self setUpHandshakeProtocol];
}
- (void)system:(id)system  saveDFUDeviceWithVersion:(NSString*)version;
{
    NSMutableDictionary *updatedDeviceDic = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kDevicesInUpdatedKey]]?:[NSMutableDictionary new];
    
    NSString *uuidString = ((CBPeripheral*)[system instance]).identifier.UUIDString;
    
    NSMutableDictionary *infoDic;
    
    if ([updatedDeviceDic.allKeys containsObject:uuidString]) {
        infoDic = [[NSMutableDictionary alloc]initWithDictionary:updatedDeviceDic[uuidString]];
    }else{
        infoDic = [NSMutableDictionary new];
    }
    
    if (version) {
        [infoDic setObject:version forKey:@"version"];
    }
    [updatedDeviceDic setObject:infoDic forKey:uuidString];
    [[NSUserDefaults standardUserDefaults] setObject:updatedDeviceDic forKey:kDevicesInUpdatedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)cleanDeviceFromStorage:(id)system;
{
    NSMutableDictionary *OTADeviceDic = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kDevicesInUpdatedKey]]?:[NSMutableDictionary new];
    
    [OTADeviceDic removeObjectForKey:((CBPeripheral*)[system instance]).identifier.UUIDString];
    [[NSUserDefaults standardUserDefaults] setObject:OTADeviceDic forKey:kDevicesInUpdatedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


- (void)system:(id)system startUpdateWithfile:(NSString*)path;
{
    self.currentSystem = system;
    
    [self readOTAHexFile:path];
    
    //TO DO: get erase address
    _eraseAddress = 6;
    
    /*
     {0x448, "STM32F072xx", 0x20001800, 0x20004000, 0x08000000, 0x08020000,  2, 2048, 0x1FFFF800, 0x1FFFF80F, 0x1FFFC800, 0x1FFFF800},
     number of pages == (0x0801B830 - 0x08003000) / 0x800
     */
    int STM32_page_size = 2048;
    
    NSData *startAddress = _OTADataArray[0][0];
    NSData *endAddress = (_OTADataArray.lastObject)[0];
    
    _eraseLength = (CFSwapInt32BigToHost(*(int*)([endAddress bytes])) - CFSwapInt32BigToHost(*(int*)([startAddress bytes]))) / STM32_page_size + 1;
    
    _writeLine = [self checkUpdateProgress:system];
    _writeLineNumber = (int)_OTADataArray.count;
    
    _step = 0;
    _shouldReceiveBuffer = NO;
    
    DDLogWarn(@"OTA start!");
    _command = DFUCommandStart;
    
    if (_stepIndicator == DFUNextStepProductName) {
        //has sent handshake protocol before, skip
        _stepIndicator = DFUNextStepBeginning;
        
        [self nextStep];
    }else{
        if (_writeLine > 0) {
            NSArray *dataArray = _OTADataArray[_writeLine-1];
            _lastWrittenAddress = dataArray.firstObject;
            _lastWrittenData = dataArray.lastObject;
            _stepIndicator = DFUNextStepResume;
        }else{
            _stepIndicator = DFUNextStepBeginning;
        }
        
        [self setUpHandshakeProtocol];
    }
}

- (void)readOTAHexFile:(NSString*)path {
    _OTADataArray = [NSMutableArray new];
    
    unsigned int bufferAddress = 0;
    
    void *p_st = NULL;
    p_st = hex_init();
    
    const char *filename = [path cStringUsingEncoding:NSUTF8StringEncoding];
    
    _st = p_st;
    
    char mark;
    int i, fd;
    uint8_t  checksum;
    unsigned int c;
    uint32_t base = 0;
    unsigned int last_address = 0x0;
    
    fd = open(filename, O_RDONLY);
    if (fd < 0){
        DDLogWarn(@"PARSER_ERR_SYSTEM");
        return;
    }
    
    while (read(fd, &mark, 1) != 0) {
        
        if (mark == '\n' || mark == '\r') {
            continue;
        }
        if (mark != ':'){
            DDLogWarn(@"PARSER_ERR_INVALID_FILE 0");
            return;
        }
        char buffer[9];
        unsigned int reclen, address, type;
        uint8_t *record = NULL;
        
        /* get the reclen, address, and type */
        buffer[8] = 0;
        if (read(fd, &buffer, 8) != 8){
            DDLogWarn(@"PARSER_ERR_INVALID_FILE 1");
            return;
        }
        if (sscanf(buffer, "%2x%4x%2x", &reclen, &address, &type) != 3) {
            DDLogWarn(@"PARSER_ERR_INVALID_FILE 2");
            return;
        }
        
        /* setup the checksum */
        checksum =
        reclen +
        ((address & 0xFF00) >> 8) +
        ((address & 0x00FF) >> 0) +
        type;
        
        switch(type) {
                /* data record */
            case 0:
                c = address - last_address;
                _st->data = realloc(_st->data, _st->data_len + c + reclen);
                
                /* if there is a gap, set it to 0xff and increment the length */
                if (c > 0) {
                    memset(&_st->data[_st->data_len], 0xff, c);
                    _st->data_len += c;
                }
                
                last_address = address + reclen;
                record = &_st->data[_st->data_len];
                _st->data_len += reclen;
                break;
                
                /* extended segment address record */
            case 2:
                base = 0;
                break;
                
                /* extended linear address record */
            case 4:
                base = address;
                break;
        }
        
        buffer[2] = 0;
        
        NSMutableArray *array = [NSMutableArray new];
        NSMutableData *data = [NSMutableData new];
        for(i = 0; i < reclen; ++i) {
            if (read(fd, &buffer, 2) != 2 || sscanf(buffer, "%2x", &c) != 1) {
                close(fd);
                DDLogWarn(@"PARSER_ERR_INVALID_FILE 3");
                return;            }
            
            /* add the byte to the checksum */
            checksum += c;
            
            Byte unit[1];
            
            [data appendData:[NSData dataWithBytes: &c length: sizeof(unit)]];
            
            switch(type) {
                case 0:
                    if (record != NULL) {
                        record[i] = c;
                    } else {
                        DDLogWarn(@"PARSER_ERR_INVALID_FILE 4");
                        return;
                    }
                    break;
                    
                case 2:
                case 4:
                    base = (base << 8) | c;
                    break;
            }
        }
        
        
        /* read, scan, and verify the checksum */
        if (
            read(fd, &buffer, 2 ) != 2 ||
            sscanf(buffer, "%2x", &c) != 1 ||
            (uint8_t)(checksum + c) != 0x00
            ) {
            close(fd);
            DDLogWarn(@"PARSER_ERR_INVALID_FILE 5");
            return;
        }
        
        switch(type) {
                /* EOF */
            case 1:
                close(fd);
                DDLogWarn(@"PARSER_ERR_OK 6");
                
                return;
                /* address record */
            case 2: base = base << 4;
                
                
            case 4:	base = be_u32(base);
                
                _headAddress = data;
                bufferAddress = 0;
                
                /* Reset last_address since our base changed */
                last_address = 0;
                
                if (_st->base == 0) {
                    _st->base = base;
                    break;
                }
                
                /* we cant cope with files out of order */
                if (base < _st->base) {
                    close(fd);
                    DDLogWarn(@"PARSER_ERR_INVALID_FILE 7");
                    return;                }
                
                /* if there is a gap, enlarge and fill with zeros */
                unsigned int len = base - _st->base;
                if (len > _st->data_len) {
                    _st->data = realloc(_st->data, len);
                    memset(&_st->data[_st->data_len], 0, len - _st->data_len);
                    _st->data_len = len;
                }
                break;
            case 5:
                
                break;
            default:
            {
                if (bufferAddress == 0) {
                    bufferAddress = address;
                }
                
                //if address is not the multiple of 4, it means the data is not valid which is constructed by 0xff. We should ignore this kind of data or bootloader can not repond correctly
                if (address % 4 == 0) {
                    if (address - bufferAddress == 16) {
                        if (_OTADataArray.count == 0) {
                            Byte header_stream[2];
                            header_stream[0] = (Byte)(address>>8) & 0xFF;
                            header_stream[1] = (Byte)(address) & 0xFF;
                            
                            NSMutableData *addrData = [[NSMutableData alloc]initWithData:_headAddress];
                            [addrData appendData:[NSData dataWithBytes:header_stream length:sizeof(header_stream)]];
                            [array addObject:addrData];
                            
                            
                            if (last_address - address != 16) {
                                for (int i = last_address - address; i < 16; i++) {
                                    Byte placeholder[1];
                                    placeholder[0] = 0xFF;
                                    [data appendBytes:placeholder length:sizeof(placeholder)];
                                }
                            }
                            [array addObject:data];
                            [_OTADataArray addObject:array];
                        }else{
                            NSMutableArray *bufferArray = [_OTADataArray lastObject];
                            NSMutableData *bufferData = [bufferArray lastObject];
                            
                            if (bufferData.length < 256) {
                                if (last_address - address != 16) {
                                    for (int i = last_address - address; i < 16; i++) {
                                        Byte placeholder[1];
                                        placeholder[0] = 0xFF;
                                        [data appendBytes:placeholder length:sizeof(placeholder)];
                                    }
                                }
                                
                                [bufferData appendData:data];
                                [bufferArray replaceObjectAtIndex:bufferArray.count-1 withObject:bufferData];
                                [_OTADataArray replaceObjectAtIndex:_OTADataArray.count-1 withObject:bufferArray];
                                
                            }else{
                                Byte header_stream[2];
                                header_stream[0] = (Byte)(address>>8) & 0xFF;
                                header_stream[1] = (Byte)(address) & 0xFF;
                                
                                NSMutableData *addrData = [[NSMutableData alloc]initWithData:_headAddress];
                                [addrData appendData:[NSData dataWithBytes:header_stream length:sizeof(header_stream)]];
                                [array addObject:addrData];
                                
                                if (last_address - address != 16) {
                                    for (int i = last_address - address; i < 16; i++) {
                                        Byte placeholder[1];
                                        placeholder[0] = 0xFF;
                                        [data appendBytes:placeholder length:sizeof(placeholder)];
                                    }
                                }
                                
                                [array addObject:data];
                                [_OTADataArray addObject:array];
                            }
                        }
                    }else{
                        Byte header_stream[2];
                        header_stream[0] = (Byte)(address>>8) & 0xFF;
                        header_stream[1] = (Byte)(address) & 0xFF;
                        
                        NSMutableData *addrData = [[NSMutableData alloc]initWithData:_headAddress];
                        [addrData appendData:[NSData dataWithBytes:header_stream length:sizeof(header_stream)]];
                        [array addObject:addrData];
                        
                        
                        if (last_address - address != 16) {
                            for (int i = last_address - address; i < 16; i++) {
                                Byte placeholder[1];
                                placeholder[0] = 0xFF;
                                [data appendBytes:placeholder length:sizeof(placeholder)];
                            }
                        }
                        [array addObject:data];
                        [_OTADataArray addObject:array];
                    }
                }
                
                bufferAddress = address;
                
            }
                break;
        }
    }
    close(fd);
}

- (void)startMonitorACKOfSystem:(id)system
{
    [self.protocolProxy isDFUMode:YES];
    
    [self subscribe:TAPropertyTypeBootloaderCommand system:system];
}

- (void)stopMonitorACKOfSystem:(id)system
{
    [self cancelTimer];
    
    _hasMadeHandShake = NO;
    [self.protocolProxy isDFUMode:NO];
    
    [self unsubscribe:TAPropertyTypeBootloaderCommand system:system];
    
    self.currentSystem = nil;
}

- (void)system:(id)system didReceiveUpdateValue:(NSDictionary*)data type:(TAPropertyType)targetType
{
    if (targetType == TAPropertyTypeBootloaderCommand) {
        
        NSData* values = [data objectForKey:@"value"];
        
        if (!_shouldReceiveBuffer) {
            if (![self checkACK:values]) {
                //receive NACK
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdateStatus:)]) {
                    
                    [self cancelTimer];

                    [self.delegate system:system didUpdateStatus:TAPFirmwareUpdateResponseReceiveError];
                    DDLogWarn(@"read:0x%@",values);
                }
                return;
            }
            _step++;
        }
        
        switch (_command) {
            case DFUCommandStart:
            {
                _hasMadeHandShake = YES;
                DDLogWarn(@"read:0x%@",values);
                
                [self cancelTimer];

                [self nextStep];
            }
                break;
            case DFUCommandGet:
                DDLogWarn(@"read:0x%@",values);
                
                [self cancelTimer];

                [self getCommandSteps];
                break;
            case DFUCommandReadProductName:
            {
                if (_step == 3) {
                    
                    [_readBuffer appendData:values];
                    
                    if (_readBuffer.length < 17) {
                        _shouldReceiveBuffer = YES;
                        return;
                    }
                    _shouldReceiveBuffer = NO;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:TAPProtocolKeyProductName object:values];
                    
                }
                
                [self cancelTimer];
                
                [self readProductNameSteps];
                
            }
                break;
            case DFUCommandRead:
            {
                if (_step == 3) {
                    //ACK(1 byte) + data(N bytes)
                    
                    [_readBuffer appendData:values];
                    if (_readBuffer.length < _lastWrittenData.length + 1) {
                        _shouldReceiveBuffer = YES;
                        return;
                        
                    }else{
                        _shouldReceiveBuffer = NO;
                    }
                }
                
                [self cancelTimer];
                
                [self readMemoryCommandSteps];
                
            }
                break;
            case DFUCommandErase:
            {
                DDLogWarn(@"read:0x%@",values);
                
                [self cancelTimer];
                
                [self eraseMemoryCommandSteps];
            }
                break;
            case DFUCommandWrite:
            {
                DDLogWarn(@"read:0x%@",values);
                if (_step == 3) {
                    _writeLine ++;
                    
                    //save OTA progress
                    NSMutableDictionary *OTADeviceDic = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kDevicesInUpdatedKey]];
                    NSString *uuidString = ((CBPeripheral*)[self.currentSystem instance]).identifier.UUIDString;
                    
                    NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc]initWithDictionary:OTADeviceDic[uuidString]];
                    [deviceInfo setObject:[NSNumber numberWithInt:_writeLine] forKey:@"progress"];
                    
                    [OTADeviceDic setObject:deviceInfo forKey:uuidString];
                    [[NSUserDefaults standardUserDefaults] setObject:OTADeviceDic forKey:kDevicesInUpdatedKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    if (_writeLine < _writeLineNumber) {
                        _step = 0;
                        
                        int temp = _writeLineNumber / 100;
                        if (_writeLine % temp == 0) {
                            
                            int percent = ((float)_writeLine / _writeLineNumber * 100);
                            
                            if (self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdateProgress:)]) {
                                [self.delegate system:system didUpdateProgress:percent];
                            }
                        }
                    }
                    
                }
                
                [self cancelTimer];
                
                [self writeMemoryCommandSteps];
                
            }
                break;
            case DFUCommandGo:
                DDLogWarn(@"read:0x%@",values);
                
                [self cancelTimer];
                
                [self goCommandSteps];
                break;
                
            default:
                break;
        }
        
    }
}

#pragma mark bootloader commands
- (void)setUpHandshakeProtocol {
    
    if (_hasMadeHandShake) {
        [self nextStep];
    }else{
        Byte header_stream0[2];
        header_stream0[0] = 0x7f;
        header_stream0[1] = 0x80;
        NSData* header_block0 = [NSData dataWithBytes:header_stream0 length:sizeof(header_stream0)];
        
        [self sendingBootloaderCommand:header_block0];
    }
}

- (void)nextStep
{
    switch (_stepIndicator) {
        case DFUNextStepProductName:
        {
            _command = DFUCommandReadProductName;
            _step = 0;
            NSDate *date2 = [NSDate date];
            DDLogWarn(@"read product name start!\ndate:%@",date2);
            
            [self readProductNameSteps];
        }
            break;
        case DFUNextStepBeginning:
        {
            _command = DFUCommandGet;
            _step = 0;
            NSDate *date2 = [NSDate date];
            DDLogWarn(@"get start!\ndate:%@",date2);
            
            [self getCommandSteps];
        }
            break;
        case DFUNextStepResume:
        {
            _command = DFUCommandRead;
            _step = 0;
            NSDate *date2 = [NSDate date];
            DDLogWarn(@"read start!\ndate:%@",date2);
            
            _readBuffer = [NSMutableData new];
            [self readMemoryCommandSteps];
        }
            break;
        default:
            break;
    }
    
}

- (void)getCommandSteps{
    //At this moment, get command is not necessary in OTA. Here we jump to next step.
    _step = 3;
    
    //use buffer to receive response data, data format should be <79>+<data>+<79>
    switch (_step) {
        case 0:
        {
            Byte header_stream[2];
            header_stream[0] = 0x01;
            header_stream[1] = 0xfe;
            NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
            
            [self sendingBootloaderCommand:header_block];
            
        }
            break;
        case 1:
        {
            Byte header_stream1[2];
            header_stream1[0] = 0x00;
            header_stream1[1] = 0xff;
            NSData* header_block1 = [NSData dataWithBytes:header_stream1 length:sizeof(header_stream1)];
            
            [self sendingBootloaderCommand:header_block1];
            
        }
            break;
        case 2:
        {
            Byte header_stream2[2];
            header_stream2[0] = 0x02;
            header_stream2[1] = 0xfd;
            NSData* header_block2 = [NSData dataWithBytes:header_stream2 length:sizeof(header_stream2)];
            
            
            [self sendingBootloaderCommand:header_block2];
        }
            break;
        case 3:
        {
            DDLogWarn(@"Get finished!");
            _command = DFUCommandErase;
            _step = 0;
            NSDate *date2 = [NSDate date];
            DDLogWarn(@"erase start!\ndate:%@",date2);
            
            [self eraseMemoryCommandSteps];
        }
        default:
            break;
    }
}

- (void)readProductNameSteps {
    switch (_step) {
        case 0:
        {
            Byte header_stream[2];
            header_stream[0] = 0x11;
            header_stream[1] = 0xee;
            NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
            
            [self sendingBootloaderCommand:header_block];
            
        }
            break;
        case 1:
        {
            Byte header_stream[5];
            header_stream[0] = 0x08;
            header_stream[1] = 0x00;
            header_stream[2] = 0x28;
            header_stream[3] = 0x00;
            header_stream[4] = header_stream[0] ^ header_stream[1] ^ header_stream[2] ^ header_stream[3];
            NSData* sumData = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
            
            [self sendingBootloaderCommand:sumData];
            
        }
            break;
        case 2:
        {
            Byte header_stream[2];
            header_stream[0] = 0x0f;
            header_stream[1] = 0xf0;
            NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
            
            [self sendingBootloaderCommand:header_block];
        }
            break;
        case 3:
        {
            _step = 0;
        }
            break;
        default:
            break;
    }
}

- (void)readMemoryCommandSteps {
    switch (_step) {
        case 0:
        {
            Byte header_stream[2];
            header_stream[0] = 0x11;
            header_stream[1] = 0xee;
            NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
            
            [self sendingBootloaderCommand:header_block];
            
        }
            break;
        case 1:
        {
            NSMutableData *addressData = [[NSMutableData alloc]initWithData:_lastWrittenAddress];
            
            addressData = [self checkSum:addressData length:addressData.length complement:NO];
            
            [self sendingBootloaderCommand:addressData];
            
        }
            break;
        case 2:
        {
            
            Byte num_stream[1];
            num_stream[0] = (Byte)(_lastWrittenData.length-1);
            NSData *numData = [NSData dataWithBytes:num_stream length:sizeof(num_stream)];
            
            NSMutableData *sumData = [[NSMutableData alloc]initWithData:numData];
            sumData = [self checkSum:sumData length:sumData.length complement:YES];
            
            [self sendingBootloaderCommand:sumData];
            
        }
            break;
        case 3:
        {
            NSData *valueData = [_readBuffer subdataWithRange:NSMakeRange(1, _readBuffer.length-1)];
            _step = 0;
            
            if ([valueData isEqualToData:_lastWrittenData]) {
                DDLogWarn(@"verify succeed, continue writing");
                _command = DFUCommandWrite;
                NSDate *date2 = [NSDate date];
                DDLogWarn(@"resume start!\ndate:%@",date2);
                [self writeMemoryCommandSteps];
                
            }else{
                DDLogWarn(@"verify fail, erase memory");
                _writeLine = 0;
                
                //clean OTA progress
                NSMutableDictionary *OTADeviceDic = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kDevicesInUpdatedKey]];
                NSString *uuidString = ((CBPeripheral*)[self.currentSystem instance]).identifier.UUIDString;
                NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc]initWithDictionary:OTADeviceDic[uuidString]];
                if (deviceInfo) {
                    [deviceInfo removeObjectForKey:@"progress"];
                }
                [OTADeviceDic setObject:deviceInfo forKey:uuidString];
                [[NSUserDefaults standardUserDefaults] setObject:OTADeviceDic forKey:kDevicesInUpdatedKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                _command = DFUCommandErase;
                NSDate *date2 = [NSDate date];
                DDLogWarn(@"erase start!\ndate:%@",date2);
                [self eraseMemoryCommandSteps];
                
            }
            
            _readBuffer = nil;
            _lastWrittenAddress = nil;
            _lastWrittenData = nil;
        }
            break;
        default:
            break;
    }
}

- (void)eraseMemoryCommandSteps {
    switch (_step) {
            //extend-erase command
        case 0:
        {
            Byte header_stream[2];
            header_stream[0] = 0x44;
            header_stream[1] = 0xbb;
            NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
            
            [self sendingBootloaderCommand:header_block];
            
        }
            break;
            //number of pages - 1 (2bytes) + page numbers(2nbytes) + checksum(1byte)
        case 1:
        {
            NSMutableData *pagesData = [NSMutableData new];
            
            Byte header_stream[2];
            header_stream[0] = ((_eraseLength-1) >> 8) & 0xff;
            header_stream[1] = (_eraseLength-1) & 0xff;
            [pagesData appendData:[NSData dataWithBytes:header_stream length:sizeof(header_stream)]];
            
            for (int i = 0; i < _eraseLength; i++) {
                Byte page_stream[2];
                page_stream[0] = (Byte)(_eraseAddress>>8);
                page_stream[1] = (Byte)(_eraseAddress) & 0xFF;
                [pagesData appendData:[NSData dataWithBytes:page_stream length:sizeof(page_stream)]];
                _eraseAddress+=1;
            }
            
            pagesData = [self checkSum:pagesData length:pagesData.length complement:NO];
            
            [self sendingBootloaderCommand:pagesData];
            
        }
            break;
        case 2:
        {
            NSDate *date = [NSDate date];
            DDLogWarn(@"erase finished!\ndate:%@",date);
            
            _command = DFUCommandWrite;
            _step = 0;
            NSDate *date2 = [NSDate date];
            DDLogWarn(@"write start!\ndate:%@",date2);
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdateProgress:)]) {
                [self.delegate system:self.currentSystem didUpdateProgress:0];
            }
            
            //Once receive ACK from "erase" command, it means mcu have verified the data and start erasing (not finish erasing) . From testing, go on sending "write" command will sometimes block the mcu. Setting timer reduced the failure rate. Need more study.
            [self performSelector:@selector(writeMemoryCommandSteps) withObject:nil afterDelay:1.0];
            
        }
            break;
        default:
            break;
    }
}

- (void)writeMemoryCommandSteps {
    switch (_step) {
        case 0:
        {
            Byte header_stream[2];
            header_stream[0] = 0x31;
            header_stream[1] = 0xce;
            
            NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
            
            [self sendingBootloaderCommand:header_block];
            
        }
            break;
        case 1:
        {
            NSArray *dataArray = _OTADataArray[_writeLine];
            
            NSMutableData *addressData = [[NSMutableData alloc]initWithData:dataArray.firstObject];
            addressData = [self checkSum:addressData length:addressData.length complement:NO];
            
            [self sendingBootloaderCommand:addressData];
            
        }
            break;
        case 2:
        {
            NSArray *dataArray = _OTADataArray[_writeLine];
            NSData *writeData = dataArray.lastObject;
            NSLog(@"writeAddress:%@",_OTADataArray[_writeLine][0]);
            
            NSMutableData *sumData = [NSMutableData new];
            Byte num_stream[1];
            num_stream[0] = (Byte)(writeData.length-1);
            NSData *numData = [NSData dataWithBytes:num_stream length:sizeof(num_stream)];
            [sumData appendData:numData];
            
            [sumData appendData:writeData];
            
            sumData = [self checkSum:sumData length:sumData.length complement:NO];
            
            [self sendingBootloaderCommand:sumData];
            
        }
            break;
        case 3:
        {
            NSDate *date2 = [NSDate date];
            DDLogWarn(@"write finish!\ndate:%@",date2);
            
            _command = DFUCommandGo;
            _step = 0;
            [self goCommandSteps];
        }
            
        default:
            break;
    }
    
}

- (void)goCommandSteps {
    switch (_step) {
        case 0:
        {
            Byte header_stream[2];
            header_stream[0] = 0x21;
            header_stream[1] = 0xde;
            
            NSData* header_block = [NSData dataWithBytes:header_stream length:sizeof(header_stream)];
            
            [self sendingBootloaderCommand:header_block];
            
        }
            break;
        case 1:
        {
            NSArray *dataArray = _OTADataArray.firstObject;
            
            NSMutableData *addressData = [[NSMutableData alloc]initWithData:dataArray.firstObject];
            addressData = [self checkSum:addressData length:addressData.length complement:NO];
            
            [self sendingBootloaderCommand:addressData];
            
        }
            break;
        case 2:
        {
            [self stopMonitorACKOfSystem:self.currentSystem];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdateStatus:)]) {
                [self.delegate system:self.currentSystem didUpdateStatus:TAPFirmwareUpdateResponseFinish];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark helper method

- (void)sendingBootloaderCommand:(NSData*)cmd {
    
    _cmdBuffer = cmd;
    DDLogWarn(@"send:0x%@",cmd);
    [self write:TAPropertyTypeBootloaderCommand data:cmd system:self.currentSystem handler:^(id result, NSError* error){
    }];
    [self fireTimer];
}

- (NSMutableData *)checkSum:(NSMutableData *)data length:(NSInteger)length complement:(BOOL)comp {
    Byte *testByte = (Byte*)malloc(length);
    
    memcpy(testByte, [data bytes], length);
    
    Byte checksum[1];
    checksum[0] = testByte[0];
    
    for (int i = 1; i < length; i++) {
        
        checksum[0] = checksum[0] ^ testByte[i];
    }
    
    if (comp) {
        checksum[0] = ~checksum[0];
    }
    NSData *sumdata = [NSData dataWithBytes:checksum length:sizeof(checksum)];
    [data appendData:sumdata];
    
    return data;
    
}

-(BOOL)checkACK:(NSData*)data {
    Byte ACK[1];
    ACK[0] = 0x79;
    NSData *ACKData = [NSData dataWithBytes:ACK length:sizeof(ACK)];
    
    NSRange ACKRange = [data rangeOfData:ACKData options:0 range:NSMakeRange(0, data.length)];
    
    if (ACKRange.location == NSNotFound) {
        return NO;
    }
    
    return YES;
}

- (void)fireTimer {
    
    DDLogWarn(@"fire timer!");
    
    NSTimeInterval delayTime = 15.0f;
    
    NSTimeInterval timeInterval = 15.0f;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    
    dispatch_source_set_timer(_timer, startDelayTime, timeInterval * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        
        DDLogWarn(@"time out! cancel timer");
        dispatch_source_cancel(_timer);
        
        if (!_retry) {
            _retry = 0;
        }
        
        //try 3 times
        if (_retry >= kRetryTimes) {
            _retry = 0;
            if (self.delegate && [self.delegate respondsToSelector:@selector(system:didUpdateStatus:)]) {
                [self.delegate system:self.currentSystem didUpdateStatus:TAPFirmwareUpdateResponseNoResponse];
            }
        }else{
            _retry ++;
            [self sendingBootloaderCommand:_cmdBuffer];
        }
        
        
    });
    
    dispatch_resume(_timer);
    
}

- (void)cancelTimer {
    if (_timer) {
        DDLogWarn(@"stop monitoring, cancel timer");
        _retry = 0;
        dispatch_source_cancel(_timer);
    }
}


- (NSString*)observerKeyFromTimestamp{
    
    return [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
}

@end
