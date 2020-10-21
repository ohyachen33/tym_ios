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
#import "Crc16.h"

#define CAPACITY_BUFFER (256)
@interface TPSignalReceiver()

@property (strong, nonatomic) NSMutableData *receive_buffer;
@property (strong, nonatomic) TPSignalHeader *header;
@property (strong, nonatomic) TPSignalDataPacketEncoder *body;
@property (strong, nonatomic) Crc16 *crc_check;

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
    
    [self.receive_buffer appendData:raw_data];
    const Byte *byte_stream =[_receive_buffer bytes];
    
    NSLog(@"pushRawData(lenght: %lu): %@",(unsigned long)[raw_data length], [raw_data description]);
    
    BOOL seqExist = NO;
    
    for (int i = 0; i< _receive_buffer.length; i++)
    {
        if (byte_stream[i] == SEQ)
        {
            NSLog(@"header seq found");
            
            seqExist = YES;
            
            NSRange range = {i, _receive_buffer.length - i};
            NSData *rest_data = [[NSData alloc] init];
            rest_data = [self.receive_buffer subdataWithRange:range];
            // complete or zero
            self.size_complete_packet = [self getLengthCompletePacket:rest_data];
            
            if (self.size_complete_packet) // packet complete
            {
                NSRange range = NSMakeRange(i , i + self.size_complete_packet);
                NSData* completePacket = [_receive_buffer subdataWithRange:range];
                
                //removed the matched signal packet
                [self removeBuffer:range];
                
                //the remaining buffer can be rubbish. if with header exists, if not, clear it up.
                //TODO: we should really wrap up these bytes handling method into external class
                if(_receive_buffer.length > 0){
                    
                    BOOL seqExistInRemainder = NO;
                    for (int j = 0; j< _receive_buffer.length; j++)
                    {
                        if (byte_stream[j] == SEQ)
                        {
                            seqExistInRemainder = YES;
                            break;
                        }
                    }
                    
                    if(!seqExistInRemainder){
                        NSLog(@"Clear up the remainder - %@", [_receive_buffer description]);
                        [self clearBuffer];
                    }
                }
                
                //return the packet
                [self parseCompletePacket:completePacket];
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
        
        [self.delegate didParseDataPacket:[complete_packet subdataWithRange:range_data_packet] type:[self.header getTypePacket:complete_packet]];
    }else{

        NSLog(@"CRC check failed");
        //TODO: setup protocol domain error code
        NSError* error = [NSError errorWithDomain:@"TAProtocolErrorDomainProtocol" code:1 userInfo:nil];
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
    [self.receive_buffer replaceBytesInRange:range withBytes:NULL length:0];
}

@end
