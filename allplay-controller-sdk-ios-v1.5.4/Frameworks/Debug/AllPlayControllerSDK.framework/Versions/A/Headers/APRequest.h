/**************************************************************
 * Copyright (C) 2014, Qualcomm Connected Experiences, Inc.
 * All rights reserved. Confidential and Proprietary.
 **************************************************************/

#import <Foundation/Foundation.h>

/**
 Enumeration of request status states for asynchronous operations.
 */
typedef enum {
    /*
     The requested operation is ready to send.
     */
	APRequestStatusReady = 0,
    /*
     The requested operation is in progress.
     */
	APRequestStatusStarted,
    /*
     The requested operation was canceled.
     */
	APRequestStatusCanceled,
    /*
     The requested operation completed successfully.
     */
	APRequestStatusFinished,
    /*
     The requested operation failed.
     */
	APRequestStatusFailed
} APRequestStatus;


@class APRequestData;

/**
 Do not instantiate this class directly.
 
 APRequest instances are returned when performing asynchronous operations to keep track of their completion.
 
 See APPlayer async methods and delegate.
 */
@interface APRequest : NSObject {
@private
    APRequestData * _data;
}

/**
 The current status of the requested operation.
 */
@property (nonatomic, readonly) APRequestStatus requestStatus;
/**
 The error reported by a failed request.
 */
@property (nonatomic, readonly) NSError * error;

/**
 Cancel the requested operation.
 */
- (void)cancel;

/**
  Returns NO if the requested operation is still pending. Returns YES if the requested operation has completed successfully, failed or been canceled.
  */ 
- (BOOL)hasFinished;

@end
