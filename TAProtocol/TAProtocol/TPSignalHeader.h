//
//  TPSignalHeader.h
//  TYM Transfer
//
//  Created by John Xu on 4/5/15.
//  Copyright (c) 2015 TYMPHANY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TASignalType.h"

#define KEY_STATE_SIG (7)

#define KEY_SRV_ID (4)

#define SETTING_WRITE_OFFSET_REQ_SIG (89)
#define SETTING_READ_OFFSET_REQ_SIG (90)
#define SETTING_READ_OFFSET_RESP_SIG (41)

#define SETTING_SRV_ID (11)
#define BLE_CTRL_SRV_ID (5)

#define SEQ (0XAA)
#define OFFSET_SIZE (3)
#define OFFSET_TYPE_PACKET (1)
#define KEY_PAKCET_SIZE (19)
#define SETTING_PAKCET_SIZE (25)

typedef struct{
    Byte sequence_number;
    Byte signal_id;
    Byte server_id;
    Byte LSB; // LSB size
    Byte MSB; // always 0 here. BLE packet should not larger than 256 bytes
    //   Byte data[1];
} TPSignalHeader_t;
#define SIZE_HEADER sizeof(TPSignalHeader_t)


typedef struct
{
    NSRange header_range;
    NSRange payload_range;
    NSRange crc_range;
    TPSignalPacketType type_packet;
} TPSignalHeaderParsedRlt_t;

typedef NS_ENUM (NSInteger, TPSignalHeaderParsedResult)
{
    TPSignalHeaderParsedResultNoHeader,
    TPSignalHeaderParsedResultSuccess,   // parse whole header successfully and return length and beginning of payload
    TPSignalHeaderParsedResultHeaderNotCompleted  // get header but not completed
};


@interface TPSignalHeader : NSObject

@property(strong, nonatomic) NSData* header;


- (id) initAndSetupHeaderWithSigId:(Byte)sig_id srvId:(Byte)srv_id andSize:(UInt16)size16;

- (id) initAndSetupHeaderWithHeaderBlock:(NSData *) header_block;

- (void)setupHeaderWithBlock:(NSData *) header_block;

- (NSData*) setupHeaderWithSigId:(Byte)sig_id srvId:(Byte)srv_id andSize:(UInt16)size16;

// packet must start with SEQ
- (int)getLengthPacket:(NSData *)packet;

- (Byte)getTypePacket:(NSData *)packet;
@end


