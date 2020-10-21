//
//  TADigitalSignalProcessingService.h
//  TADigitalSignalProcessingService
//
//  Created by Lam Yick Hong on 20/4/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAService.h"

FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyLowPassFrequency;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyLowPassSlope;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyPhase;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyPolarity;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyEQ1Frequency;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyEQ1Boost;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyEQ1QFactor;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyEQ2Frequency;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyEQ2Boost;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyEQ2QFactor;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyEQ3Frequency;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyEQ3Boost;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyEQ3QFactor;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyRGCFrequency;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyRGCSlope;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyLowPassOnOff;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyPEQ1OnOff;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyPEQ2OnOff;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyPEQ3OnOff;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyRGCOnOff;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyVolume;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyDisplay;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyTimeout;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyStandby;
FOUNDATION_EXPORT NSString * const TADigitalSignalProcessingKeyTunning;


@protocol TADigitalSignalProcessingServiceDelegate;

/*!
 *  @warning This is a prelimenary document. The TAP libraries and interfaces are under development and will have heavy changes along.
 *
 *  @interface TADigitalSignalProcessingService
 *  @brief     TAP Service for controlling the digital signal processing feature. Helps exchange DSP related information.
 *  @author    Hong Lam
 *  @date      20/4/15
 *  @copyright Tymphany Ltd.
 *
 *  @discussion {@link TADigitalSignalProcessingService} objects are used to control the Digital Signal Processing(DSP) function on the system.
 *
 *  You should implement the {@link TADigitalSignalProcessingServiceDelegate} and assign to the TADigitalSignalProcessingService object to receive any status update related to the DSP.
 */
@interface TADigitalSignalProcessingService : TAService

/*!
 *  @property   delegate
 *  @discussion A TADigitalSignalProcessingService delegate object
 */
@property (nonatomic, strong) id<TADigitalSignalProcessingServiceDelegate> delegate;

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
- (void)system:(TASystem*)system writeEqualizerType:(NSString*)type value:(id)value completion:(void (^)(id))complete;

/*!
 *  @method startMonitorEqualizerOfSystem:
 *
 *  @param system           The target system
 *
 *  @brief  Starts monitoring the equalizer of the target system.
 *
 *  @discussion On BLE common mode, calling this method will trigger the App subscribes to the BLE equalizer charateristic provided by the system in audio service. Whenever there's a equalizer update, the system will send a BLE notification to the App, where the TAP protocol module will receive and notify {@link TADigitalSignalProcessingService} object. If you have implemented the delegate method and assigned to the delegate property of {@link TADigitalSignalProcessingService} , {@link system:didUpdateEqualizer:} will be triggered and provide the response data.
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

@end

/*!
 *  @protocol TADigitalSignalProcessingServiceDelegate
 *
 *  @brief    Delegate define methods for receive notifications from TADigitalSignalProcessingService object.
 *
 */
@protocol TADigitalSignalProcessingServiceDelegate <NSObject>

@required

@optional

/*!
 *  @method system:didUpdateEqualizer:
 *
 *  @param syste        The system which has this update
 *  @param equalize     The new equalizer
 *
 *  @brief              Invoked when a the system has a equalizer update
 */
- (void)system:(id)system didUpdateEqualizer:(NSDictionary*)equalizer;

@end
