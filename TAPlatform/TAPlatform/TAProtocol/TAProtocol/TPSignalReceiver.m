//
//  TPSignalReceiver.m
//  TPSignal
//
//  Created by John Xu on 5/4/15.
//  Copyright (c) 2015 JohnXu. All rights reserved.
//

#import "TPSignalReceiver.h"
#import "TPSignalHeader.h"
#import "TPSignalDataPacketEncoder.h"
#import "TAPError.h"
#import "Crc16.h"

#define CAPACITY_BUFFER (256)
#define kBufferDataLifeTime (2)

@interface TPSignalReceiver()

@property (strong, nonatomic) NSMutableData *receive_buffer;
@property (strong, nonatomic) TPSignalHeader *header;
@property (strong, nonatomic) TPSignalDataPacketEncoder *body;
@property (strong, nonatomic) Crc16 *crc_check;

@property (strong, nonatomic) NSDate* lastPushTimeStamp;

@property int size_complete_packet;

@end

@implementation TPSignalReceiver


- (id) initWithDelegate:(id<TPSignalReceiverDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.receive_buffer = [NSMutableData dataWithCapacity:CAPACITY_BUFFER];
        self.header = [[TPSignalHeader alloc] init];
        self.body = [[TPSignalDataPacketEncoder alloc] init];
        self.crc_check = [[Crc16 alloc] init];
    }
    return self;
}

- (void)pushRawData:(NSData *)raw_data
{
    //First, check if there's garbage push into buffer which could screw up the good.
    if(self.lastPushTimeStamp)
    {
        if([[NSDate date] timeIntervalSince1970] - [self.lastPushTimeStamp timeIntervalSince1970] > kBufferDataLifeTime)
        {
            //renew buffer
            self.receive_buffer = [NSMutableData dataWithCapacity:CAPACITY_BUFFER];
            
            DDLogVerbose(@"Buffer renewed as the old data inside buffer should be expired, after %d seconds", kBufferDataLifeTime);
        }
    }
    
    //push to buffer
    [self.receive_buffer appendData:raw_data];
    
    //mark timestamp
    self.lastPushTimeStamp = [NSDate date];
    
    DDLogDebug(@"rawData(size: %lu): %@",(unsigned long)[raw_data length], [raw_data description]);
    DDLogDebug(@"buffer after added(size: %lu): %@",(unsigned long)[_receive_buffer length], [_receive_buffer description]);
    
    //interpreting the buffer data
    BOOL seqExist = NO;
    
    const Byte *byte_stream =[_receive_buffer bytes];
    
    for (int i = 0; i< _receive_buffer.length; i++)
    {
        if (byte_stream[i] == SEQ)
        {
            DDLogVerbose(@"header exist in buffer %d", i);
            
            seqExist = YES;
            
            NSRange range = {i, _receive_buffer.length - i};
            NSData *rest_data = [[NSData alloc] init];
            rest_data = [self.receive_buffer subdataWithRange:range];
            // complete or zero
            self.size_complete_packet = [self getLengthCompletePacket:rest_data];
            
            if (self.size_complete_packet) // packet complete
            {
                NSRange range = NSMakeRange(i , i + self.size_complete_packet);
                
                if(_receive_buffer.length < range.location + range.length)
                {
                    break;
                }
                
                NSData* completePacket = [_receive_buffer subdataWithRange:range];
                
                DDLogDebug(@"package found with size: %d data:%@", self.size_complete_packet, [completePacket description]);
                
                if(![self.crc_check checkCRCWithWholePacket:completePacket])
                {
                    DDLogError(@"CRC check failed. This header might be a garbage fragment. Search the rest of the buffer");
                    
                }else{
                    
                    DDLogVerbose(@"package is correct. handle it.");
                    
                    //removed the matched signal packet
                    [self removeBuffer:range];
                    
                    DDLogDebug(@"buffer after remove packet(size: %lu): %@",(unsigned long)[_receive_buffer length], [_receive_buffer description]);
                    
                    //debug purpose
                    BOOL cleanUpevenWithHeader = NO;
                    
                    if(cleanUpevenWithHeader)
                    {
                        DDLogVerbose(@"Force remove");
                    }
                    
                    //the remaining buffer can be rubbish. if with header exists, if not, clear it up.
                    //TODO: we should really wrap up these bytes handling method into external class
                    if(_receive_buffer.length > 0){
                        
                        BOOL seqExistInRemainder = NO;
                        for (int j = 0; j< _receive_buffer.length; j++)
                        {
                            if (byte_stream[j] == SEQ)
                            {
                                DDLogVerbose(@"header exist in buffer after remove packet");
                                seqExistInRemainder = YES;
                                break;
                            }
                        }
                        
                        if(cleanUpevenWithHeader || !seqExistInRemainder){
                            DDLogVerbose(@"Clear up the buffer");
                            [self clearBuffer];
                        }
                    }
                    
                    //return the packet
                    [self parseCompletePacket:completePacket];
                }
                
            }else{
                
                DDLogVerbose(@"Packet not complete");
            }
        }
    }
}

////////public API end

// helper function

- (void) parseCompletePacket:(NSData *)complete_packet
{
    NSUInteger length_packet = complete_packet.length;
    [self.header setupHeaderWithBlock:[complete_packet subdataWithRange:NSMakeRange(0,SIZE_HEADER)]];

    if ([self.crc_check checkCRCWithWholePacket:complete_packet])
    {
      // return data packet to upper layer
        NSRange range_data_packet = NSMakeRange(SIZE_HEADER, length_packet - sizeof(UInt16) - SIZE_HEADER);
        
        NSData* data = [complete_packet subdataWithRange:range_data_packet];
        
        DDLogVerbose(@"data part in the packet:%@", data);
        
        [self.delegate didParseDataPacket:data type:[self.header getTypePacket:complete_packet]];
    }else{

        DDLogError(@"CRC check failed");
        NSError* error = [NSError errorWithDomain:TAPProtocolErrorDomain code:TAPErrorCodeIncorrectPacket userInfo:nil];
        [self.delegate didFailToParseDataPackage:complete_packet error:error];
    }

}

//TODO: put all bytes manipulation methods into a util class
- (int)integerFromReveresedData:(NSData*)data
{
    if([data length] == 2)
    {
        Byte *stream = (Byte*)[data bytes];
        int value = stream[1];
        value = (value << 8) | stream[0];
        return value;
    }
    return 0;
}


- (int) getLengthCompletePacket:(NSData *)whole_packet
{
    // find length
  
    int length_packet = [self.header getLengthPacket:whole_packet];
    
    if (length_packet > whole_packet.length) // packet not complete
    {
        length_packet = 0;
    }
    
    return length_packet;
}

- (void) appendBuffer:(NSData *)buf
{
    [self.receive_buffer appendData:buf];
}

- (void) clearBuffer
{
    [self.receive_buffer resetBytesInRange:NSMakeRange(0,self.receive_buffer.length)];
    [self.receive_buffer setLength:0];
}

- (void)removeBuffer: (NSRange)range
{
    DDLogVerbose(@"range location:%lu length:%lu", (unsigned long)range.location, (unsigned long)range.length);
    [self.receive_buffer replaceBytesInRange:range withBytes:NULL length:0];
}

@end
