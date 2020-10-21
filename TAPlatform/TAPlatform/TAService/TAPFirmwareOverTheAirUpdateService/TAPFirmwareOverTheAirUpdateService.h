//
//  TAPFirmwareOverTheAirUpdateService.h
//  TAPlatform
//
//  Created by Alain Hsu on 14/02/2017.
//  Copyright © 2017 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TAPService.h"

typedef NS_ENUM(NSInteger, TAPFirmwareUpdateResponse){
    TAPFirmwareUpdateResponseFinish = 0,
    TAPFirmwareUpdateResponseReceiveError,
    TAPFirmwareUpdateResponseNoResponse,
    TAPFirmwareUpdateResponseUnknown
};

@protocol TAPFirmwareOverTheAirUpdateServiceDelegate;

@interface TAPFirmwareOverTheAirUpdateService : TAPService

@property (nonatomic, strong) id<TAPFirmwareOverTheAirUpdateServiceDelegate> delegate;

/*!
 *  @method checkFirmwareIsDFUMode:
 *
 *  @param system           The target system
 *
 *  @brief                  check whether system is under DFU mode
 *
 */
- (BOOL)checkFirmwareIsDFUMode:(id)system;
/*!
 *  @method system:getProductName:
 *
 *  @param system           The target system
 *  @param complete         The product name
 *
 *  @brief                  read product name for under-DFU-mode device
 *
 */
- (void)system:(id)system getProductName:(void (^)(NSString*))complete;

/*!
 *  @method system:saveDFUDeviceWithVersion:
 *
 *  @param system           The target system
 *  @param version          the target software version
 *
 *  @brief                  save system with DFU version
 *
 */
- (void)system:(id)system  saveDFUDeviceWithVersion:(NSString*)version;

/*!
 *  @method cleanDeviceFromStorage:
 *
 *  @param system           The target system
 *
 *  @brief                  clean DFU record with system from storage
 *
 */
- (void)cleanDeviceFromStorage:(id)system;

/*!
 *  @method system:startUpdateWithfile:
 *
 *  @param system           The target system
 *  @param path             The DFU file path
 *
 *  @brief                  get DFU file and start update
 *
 */
- (void)system:(id)system startUpdateWithfile:(NSString*)path;

/*!
 *  @method startMonitorACKOfSystem:
 *
 *  @param system           The target system
 *
 *  @brief  Starts monitoring the ACK of the target system.
 *
 *  @discussion On BLE DFU mode, calling this method will switch defaultMode to TAPBluetoothLowEnergyModeDFU in protocolProxy, will also trigger the App subscribes to the Bootloader response. Whenever there's a response or non-response for long time, the system will choose to  send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TAPFirmwareOverTheAirUpdateService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TAPFirmwareOverTheAirUpdateService} , {@link system:didUpdateStatus:} will be triggered and provide the response data.
 *
 *  @see {@link system:didUpdateEqualizer:}
 */
- (void)startMonitorACKOfSystem:(id)system;

/*!
 *  @method stopMonitorACKOfSystem:
 *
 *  @param system           The target system
 *
 *  @brief  Stops monitoring the ACK info of the target system.
 *
 *  @discussion On BLE DFU mode, calling this method will switch defaultMode to last BLE mode in protocolProxy, will also trigger the App unsubscribe to the Bootloader response.
 *  @see {@link startMonitorEqualizerOfSystem:}
 */
- (void)stopMonitorACKOfSystem:(id)system;

@end

@protocol TAPFirmwareOverTheAirUpdateServiceDelegate <NSObject>

@required

/*!
 *  @method system:didUpdateStatus:
 *
 *  @param system       The system which has this update
 *  @param status       The new battery level
 *
 *  @brief              Invoked when a the system has a status update
 */
- (void)system:(id)system didUpdateStatus:(TAPFirmwareUpdateResponse)status;

@optional

/*!
 *  @method system:didUpdateProgress:
 *
 *  @param system       The system which has this update
 *  @param progress     The new progress
 *
 *  @brief              Invoked when a the system has a progress update
 */
- (void)system:(id)system didUpdateProgress:(int)progress;

@end
