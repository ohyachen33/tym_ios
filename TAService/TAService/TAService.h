//
//  TAService.h
//  TAService
//
//  Created by Lam Yick Hong on 29/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAProtocolAdaptor.h"
#import "TAProtocol.h"

/*!
 *  @warning This is a prelimenary document. The TAP libraries and interfaces are under development and will have heavy changes along.
 *
 *  @interface TAService
 *  @brief     TAP Service base class. Abstract default service operations.
 *  @author    Hong Lam
 *  @date      29/1/15
 *  @copyright Tymphany Ltd.
 *
 *  @discussion {@link TAService} is the base class for any classes to be used as a TAP service module within entire platform.
 *
 *  This base class provided extension private methods which can be re-used to communicate with TAP protocol modules. Subclass will need to include the {@link TAService(Private)} extension methods declaration in their implementation files to inherit those.
 *  @see {@link TAService(Private)}
 */
@interface TAService : NSObject

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

- (void)system:(id)system didReceiveUpdateValue:(NSDictionary*)data type:(TAPropertyType)targetType;

@end
