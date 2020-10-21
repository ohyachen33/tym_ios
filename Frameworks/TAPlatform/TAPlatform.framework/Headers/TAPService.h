//
//  TAPService.h
//  TAPService
//
//  Created by Lam Yick Hong on 29/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPProtocolAdaptor.h"
#import "TAPProtocol.h"

/*!
 *  @warning This is a prelimenary document. The TAP libraries and interfaces are under development and will have heavy changes along.
 *
 *  @interface TAPService
 *  @brief     TAP Service base class. Abstract default service operations.
 *  @author    Hong Lam
 *  @date      29/1/15
 *  @copyright Tymphany Ltd.
 *
 *  @discussion {@link TAPService} is the base class for any classes to be used as a TAP service module within entire platform.
 *
 *  This base class provided extension private methods which can be re-used to communicate with TAP protocol modules. Subclass will need to include the {@link TAPService(Private)} extension methods declaration in their implementation files to inherit those.
 *  @see {@link TAPService(Private)}
 */
@interface TAPService : NSObject

/*!
 *  @method initWithType:config:
 *
 *  @param type     The type of the protocol.
 *  @param config   The configuration dictionary
 *
 *  @brief              Initiates a service instance which make use of a protocol object, with a custom config
 *
 */
- (id)initWithType:(NSString*)type config:(NSDictionary*)config;

/*!
 *  @method initWithType:
 *
 *  @param type     The type of the protocol.
 *
 *  @brief              Initiates a service instance which make use of a protocol object 
 *
 */
- (id)initWithType:(NSString*)type;
/*!
 *  @method perform:
 *
 *  @param operationInfo    Dictionary which encapsulates all info related to the operation
 *
 *  @return A info dictionary encapsulate all the information. Including errors.
 *
 *  @brief A flexible interface for executing operation to protocol proxy
 *
 */
- (NSDictionary*)perform:(NSDictionary*)operationInfo;

- (void)system:(id)system didReceiveUpdateValue:(NSDictionary*)data type:(TAPropertyType)targetType;

@end
