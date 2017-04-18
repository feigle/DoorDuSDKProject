//
//  DoorDuMQTTTransport.h
//  DoorDuMQTTClient
//
//  Created by Christoph Krey on 06.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DoorDuMQTTTransportDelegate;

/** DoorDuMQTTTransport is a protocol abstracting the underlying transport level for DoorDuMQTTClient
 *
 */
@protocol DoorDuMQTTTransport <NSObject>

/** DoorDuMQTTTransport state defines the possible state of an abstract transport
 *
 */
 typedef NS_ENUM(NSInteger, DoorDuMQTTTransportState) {
     
     /** DoorDuMQTTTransportCreated indicates an initialized transport */
     DoorDuMQTTTransportCreated = 0,
     
     /** DoorDuMQTTTransportOpening indicates a transport in the process of opening a connection */
     DoorDuMQTTTransportOpening,
     
     /** DoorDuMQTTTransportCreated indicates a transport opened ready for communication */
     DoorDuMQTTTransportOpen,
     
     /** DoorDuMQTTTransportCreated indicates a transport in the process of closing */
     DoorDuMQTTTransportClosing,
     
     /** DoorDuMQTTTransportCreated indicates a closed transport */
     DoorDuMQTTTransportClosed
 };

/** runLoop The runLoop where the streams are scheduled. If nil, defaults to [NSRunLoop currentRunLoop]. */
@property (strong, nonatomic) NSRunLoop * _Nonnull runLoop;

/** runLoopMode The runLoopMode where the streams are scheduled. If nil, defaults to NSRunLoopCommonModes. */
@property (strong, nonatomic) NSString * _Nonnull runLoopMode;

/** DoorDuMQTTTransportDelegate needs to be set to a class implementing th DoorDuMQTTTransportDelegate protocol
 * to receive delegate messages.
 */
@property (strong, nonatomic) _Nullable id<DoorDuMQTTTransportDelegate> delegate;

/** state contains the current DoorDuMQTTTransportState of the transport */
@property (nonatomic) DoorDuMQTTTransportState state;

/** open opens the transport and prepares it for communication
 * actual transports may require additional parameters to be set before opening
 */
- (void)open;

/** send transmits a data message
 * @param data data to be send, might be zero length
 * @result a boolean indicating if the data could be send or not
 */
- (BOOL)send:(nonnull NSData *)data;

/** close closes the transport */
- (void)close;

@end

/** DoorDuMQTTTransportDelegate protocol
 * Note: the implementation of the didReceiveMessage method is mandatory, the others are optional 
 */
@protocol DoorDuMQTTTransportDelegate <NSObject>

/** didReceiveMessage gets called when a message was received
 * @param DoorDuMQTTTransport the transport on which the message was received
 * @param message the data received which may be zero length
 */
 - (void)DoorDuMQTTTransport:(nonnull id<DoorDuMQTTTransport>)DoorDuMQTTTransport didReceiveMessage:(nonnull NSData *)message;

@optional

/** DoorDuMQTTTransportDidOpen gets called when a transport is successfully opened
 * @param DoorDuMQTTTransport the transport which was successfully opened
 */
- (void)DoorDuMQTTTransportDidOpen:(_Nonnull id<DoorDuMQTTTransport>)DoorDuMQTTTransport;

/** didFailWithError gets called when an error was detected on the transport
 * @param DoorDuMQTTTransport the transport which detected the error
 * @param error available error information, might be nil
 */
- (void)DoorDuMQTTTransport:(_Nonnull id<DoorDuMQTTTransport>)DoorDuMQTTTransport didFailWithError:(nullable NSError *)error;

/** DoorDuMQTTTransportDidClose gets called when the transport closed
 * @param DoorDuMQTTTransport the transport which was closed
 */
- (void)DoorDuMQTTTransportDidClose:(_Nonnull id<DoorDuMQTTTransport>)DoorDuMQTTTransport;

@end

@interface DoorDuMQTTTransport : NSObject <DoorDuMQTTTransport>
@end

