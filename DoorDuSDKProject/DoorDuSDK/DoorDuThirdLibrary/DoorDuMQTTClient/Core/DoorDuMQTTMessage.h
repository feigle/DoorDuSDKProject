//
// DoorDuMQTTMessage.h
// DoorDuMQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//
// based on
//
// Copyright (c) 2011, 2013, 2lemetry LLC
//
// All rights reserved. This program and the accompanying materials
// are made available under the terms of the Eclipse Public License v1.0
// which accompanies this distribution, and is available at
// http://www.eclipse.org/legal/epl-v10.html
//
// Contributors:
//    Kyle Roche - initial API and implementation and/or initial documentation
//

#import <Foundation/Foundation.h>
/**
 Enumeration of DoorDuMQTT Quality of Service levels
 */
typedef NS_ENUM(UInt8, DoorDuMQTTQosLevel) {
    DoorDuMQTTQosLevelAtMostOnce = 0,
    DoorDuMQTTQosLevelAtLeastOnce = 1,
    DoorDuMQTTQosLevelExactlyOnce = 2
};

/**
 Enumeration of DoorDuMQTT protocol version
 */
typedef NS_ENUM(UInt8, DoorDuMQTTProtocolVersion) {
    DoorDuMQTTProtocolVersion31 = 3,
    DoorDuMQTTProtocolVersion311 = 4
};

typedef NS_ENUM(UInt8, DoorDuMQTTCommandType) {
    DoorDuMQTT_None = 0,
    DoorDuMQTTConnect = 1,
    DoorDuMQTTConnack = 2,
    DoorDuMQTTPublish = 3,
    DoorDuMQTTPuback = 4,
    DoorDuMQTTPubrec = 5,
    DoorDuMQTTPubrel = 6,
    DoorDuMQTTPubcomp = 7,
    DoorDuMQTTSubscribe = 8,
    DoorDuMQTTSuback = 9,
    DoorDuMQTTUnsubscribe = 10,
    DoorDuMQTTUnsuback = 11,
    DoorDuMQTTPingreq = 12,
    DoorDuMQTTPingresp = 13,
    DoorDuMQTTDisconnect = 14
};

@interface DoorDuMQTTMessage : NSObject
@property (nonatomic) DoorDuMQTTCommandType type;
@property (nonatomic) DoorDuMQTTQosLevel qos;
@property (nonatomic) BOOL retainFlag;
@property (nonatomic) BOOL dupFlag;
@property (nonatomic) UInt16 mid;
@property (strong, nonatomic) NSData * data;

/**
 Enumeration of DoorDuMQTT Connect return codes
 */

typedef NS_ENUM(NSUInteger, DoorDuMQTTConnectReturnCode) {
    DoorDuMQTTConnectAccepted = 0,
    DoorDuMQTTConnectRefusedUnacceptableProtocolVersion,
    DoorDuMQTTConnectRefusedIdentiferRejected,
    DoorDuMQTTConnectRefusedServerUnavailable,
    DoorDuMQTTConnectRefusedBadUserNameOrPassword,
    DoorDuMQTTConnectRefusedNotAuthorized
};

// factory methods
+ (DoorDuMQTTMessage *)connectMessageWithClientId:(NSString*)clientId
                                   userName:(NSString*)userName
                                   password:(NSString*)password
                                  keepAlive:(NSInteger)keeplive
                               cleanSession:(BOOL)cleanSessionFlag
                                       will:(BOOL)will
                                  willTopic:(NSString*)willTopic
                                    willMsg:(NSData*)willData
                                    willQoS:(DoorDuMQTTQosLevel)willQoS
                                 willRetain:(BOOL)willRetainFlag
                              protocolLevel:(UInt8)protocolLevel;

+ (DoorDuMQTTMessage *)pingreqMessage;
+ (DoorDuMQTTMessage *)disconnectMessage;
+ (DoorDuMQTTMessage *)subscribeMessageWithMessageId:(UInt16)msgId
                                        topics:(NSDictionary *)topics;
+ (DoorDuMQTTMessage *)unsubscribeMessageWithMessageId:(UInt16)msgId
                                          topics:(NSArray *)topics;
+ (DoorDuMQTTMessage *)publishMessageWithData:(NSData*)payload
                                onTopic:(NSString*)topic
                                    qos:(DoorDuMQTTQosLevel)qosLevel
                                  msgId:(UInt16)msgId
                             retainFlag:(BOOL)retain
                                dupFlag:(BOOL)dup;
+ (DoorDuMQTTMessage *)pubackMessageWithMessageId:(UInt16)msgId;
+ (DoorDuMQTTMessage *)pubrecMessageWithMessageId:(UInt16)msgId;
+ (DoorDuMQTTMessage *)pubrelMessageWithMessageId:(UInt16)msgId;
+ (DoorDuMQTTMessage *)pubcompMessageWithMessageId:(UInt16)msgId;
+ (DoorDuMQTTMessage *)messageFromData:(NSData *)data;

// instance methods
- (instancetype)initWithType:(DoorDuMQTTCommandType)type;
- (instancetype)initWithType:(DoorDuMQTTCommandType)type
                        data:(NSData *)data;
- (instancetype)initWithType:(DoorDuMQTTCommandType)type
                         qos:(DoorDuMQTTQosLevel)qos
                        data:(NSData *)data;
- (instancetype)initWithType:(DoorDuMQTTCommandType)type
                         qos:(DoorDuMQTTQosLevel)qos
                  retainFlag:(BOOL)retainFlag
                     dupFlag:(BOOL)dupFlag
                        data:(NSData *)data;

- (NSData *)wireFormat;


@end

@interface NSMutableData (DoorDuMQTT)
- (void)appendByte:(UInt8)byte;
- (void)appendUInt16BigEndian:(UInt16)val;
- (void)appendDoorDuMQTTString:(NSString*)s;

@end
