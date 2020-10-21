//
//  TAPDigitalSignalProcessingService.h
//  TAPDigitalSignalProcessingService
//
//  Created by Lam Yick Hong on 20/4/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPService.h"

FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyLowPassFrequency;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyLowPassSlope;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyPhase;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyPolarity;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyEQ1Frequency;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyEQ1Boost;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyEQ1QFactor;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyEQ2Frequency;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyEQ2Boost;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyEQ2QFactor;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyEQ3Frequency;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyEQ3Boost;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyEQ3QFactor;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyRGCFrequency;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyRGCSlope;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyLowPassOnOff;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyPEQ1OnOff;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyPEQ2OnOff;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyPEQ3OnOff;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyRGCOnOff;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyVolume;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyDisplay;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyTimeout;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyStandby;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyBrightness;
FOUNDATION_EXPORT NSString * const TAPDigitalSignalProcessingKeyTunning;


@protocol TAPDigitalSignalProcessingServiceDelegate;

/*!
 *  @warning This is a prelimenary document. The TAP libraries and interfaces are under development and will have heavy changes along.
 *
 *  @interface TAPDigitalSignalProcessingService
 *  @brief     TAP Service for controlling the digital signal processing feature. Helps exchange DSP related information.
 *  @author    Hong Lam
 *  @date      20/4/15
 *  @copyright Tymphany Ltd.
 *
 *  @discussion {@link TAPDigitalSignalProcessingService} objects are used to control the Digital Signal Processing(DSP) function on the system.
 *
 *  You should implement the {@link TAPDigitalSignalProcessingServiceDelegate} and assign to the TAPDigitalSignalProcessingService object to receive any status update related to the DSP.
 */
@interface TAPDigitalSignalProcessingService : TAPService

/*!
 *  @property   delegate
 *  @discussion A TAPDigitalSignalProcessingService delegate object
 */
@property (nonatomic, strong) id<TAPDigitalSignalProcessingServiceDelegate> delegate;

/*!
 *  @method system:equalizer:
 *
 *  @param system           The target system
 *  @param equalizer        The block which taking the equalizer as a parameter
 *  @brief                  Reads the equalizer from the target system
 *
 *  @discussion On BLE, the complete block will return an NSDictionary object consist of the current equalizer settings info.
 */
- (void)system:(id)system equalizer:(void (^)(NSDictionary*, NSError*))equalizer;

/*!
 *  @method system:equalizer:
 *
 *  @param system           The target system
 *  @param equalizer        The block which taking the equalizer as a parameter
 *  @brief                  Reads the equalizer from the target system
 *
 *  @discussion On BLE, the complete block will return an NSDictionary object consist of the current equalizer settings info.
 */
- (void)system:(id)system targetKeys:(NSArray*)targetKeys equalizer:(void (^)(NSDictionary*, NSError*))equalizer;

/*!
 *  @method system:writeEqualizerType:completion:
 *
 *  @param system           The target system
 *  @param type             The type of value to be written
 *
 *  @brief                  Writes the equalizer to the target system
 *
 *
 */
- (void)system:(TAPSystem*)system writeEqualizerType:(NSString*)type value:(id)value completion:(void (^)(id))complete;

/*!
 *  @method startMonitorEqualizerOfSystem:
 *
 *  @param system           The target system
 *
 *  @brief  Starts monitoring the equalizer of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE equalizer charateristic provided by the system in audio service. Whenever there's a equalizer update, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TAPDigitalSignalProcessingService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TAPDigitalSignalProcessingService} , {@link system:didUpdateEqualizer:} will be triggered and provide the response data.
 *
 *  @see {@link system:didUpdateEqualizer:}
 */
- (void)startMonitorEqualizerOfSystem:(id)system;

/*!
 *  @method stopMonitorEqualizerOfSystem:
 *
 *  @param system           The target system
 *
 *  @brief  Stops monitoring the equalizer info of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App unsubscribe to the BLE equalizer charateristic provided by the system in audio service.
 *  @see {@link startMonitorEqualizerOfSystem:}
 */
- (void)stopMonitorEqualizerOfSystem:(id)system;

/*!
 *  @method system:resetEqualizerType:completion:
 *
 *  @param system           The target system
 *  @param type             The type of value to be reset
 *
 *  @brief                  reset the equalizer to the target system
 *
 */
- (void)system:(TAPSystem*)system resetEqualizerType:(NSString*)type completion:(void (^)(id))complete;


@end

/*!
 *  @protocol TAPDigitalSignalProcessingServiceDelegate
 *
 *  @brief    Delegate define methods for receive notifications from TAPDigitalSignalProcessingService object.
 *
 */
@protocol TAPDigitalSignalProcessingServiceDelegate <NSObject>

@required

@optional

/*!
 *  @method system:didUpdateEqualizer:
 *
 *  @param system        The system which has this update
 *  @param equalize     The new equalizer
 *
 *  @brief              Invoked when a the system has a equalizer update
 */
- (void)system:(id)system didUpdateEqualizer:(NSDictionary*)equalizer;

@end
