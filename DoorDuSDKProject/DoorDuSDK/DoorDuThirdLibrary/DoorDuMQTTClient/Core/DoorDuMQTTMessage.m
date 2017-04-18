//
// DoorDuMQTTMessage.m
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

#import "DoorDuMQTTMessage.h"

@implementation DoorDuMQTTMessage

+ (DoorDuMQTTMessage *)connectMessageWithClientId:(NSString *)clientId
                                  userName:(NSString *)userName
                                  password:(NSString *)password
                                 keepAlive:(NSInteger)keepAlive
                              cleanSession:(BOOL)cleanSessionFlag
                                      will:(BOOL)will
                                 willTopic:(NSString *)willTopic
                                   willMsg:(NSData *)willMsg
                                   willQoS:(DoorDuMQTTQosLevel)willQoS
                                willRetain:(BOOL)willRetainFlag
                             protocolLevel:(UInt8)protocolLevel {
    /*
     * setup flags w/o basic plausibility checks
     *
     */
    UInt8 flags = 0x00;
    
    if (cleanSessionFlag) {
        flags |= 0x02;
    }
    
    if (userName) {
        flags |= 0x80;
    }
    if (password) {
        flags |= 0x40;
    }
    
    if (will) {
        flags |= 0x04;
    }
    
    flags |= ((willQoS & 0x03) << 3);
    
    if (willRetainFlag) {
        flags |= 0x20;
    }
    
    NSMutableData* data = [NSMutableData data];
    
    switch (protocolLevel) {
        case 4:
            [data appendDoorDuMQTTString:@"MQTT"];
            [data appendByte:4];
            break;
        case 3:
            [data appendDoorDuMQTTString:@"MQIsdp"];
            [data appendByte:3];
            break;
        case 0:
            [data appendDoorDuMQTTString:@""];
            [data appendByte:protocolLevel];
            break;
        default:
            [data appendDoorDuMQTTString:@"MQTT"];
            [data appendByte:protocolLevel];
            break;
    }
    [data appendByte:flags];
    [data appendUInt16BigEndian:keepAlive];
    [data appendDoorDuMQTTString:clientId];
    if (willTopic) {
        [data appendDoorDuMQTTString:willTopic];
    }
    if (willMsg) {
        [data appendUInt16BigEndian:[willMsg length]];
        [data appendData:willMsg];
    }
    if (userName) {
        [data appendDoorDuMQTTString:userName];
    }
    if (password) {
        [data appendDoorDuMQTTString:password];
    }
    
    DoorDuMQTTMessage *msg = [[DoorDuMQTTMessage alloc] initWithType:DoorDuMQTTConnect
                                                    data:data];
    return msg;
}

+ (DoorDuMQTTMessage *)pingreqMessage {
    return [[DoorDuMQTTMessage alloc] initWithType:DoorDuMQTTPingreq];
}

+ (DoorDuMQTTMessage *)disconnectMessage {
    return [[DoorDuMQTTMessage alloc] initWithType:DoorDuMQTTDisconnect];
}

+ (DoorDuMQTTMessage *)subscribeMessageWithMessageId:(UInt16)msgId
                                       topics:(NSDictionary *)topics {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    for (NSString *topic in topics.allKeys) {
        [data appendDoorDuMQTTString:topic];
        [data appendByte:[topics[topic] intValue]];
    }
    DoorDuMQTTMessage* msg = [[DoorDuMQTTMessage alloc] initWithType:DoorDuMQTTSubscribe
                                                     qos:1
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (DoorDuMQTTMessage *)unsubscribeMessageWithMessageId:(UInt16)msgId
                                         topics:(NSArray *)topics {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    for (NSString *topic in topics) {
        [data appendDoorDuMQTTString:topic];
    }
    DoorDuMQTTMessage* msg = [[DoorDuMQTTMessage alloc] initWithType:DoorDuMQTTUnsubscribe
                                                     qos:1
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (DoorDuMQTTMessage *)publishMessageWithData:(NSData *)payload
                               onTopic:(NSString *)topic
                                   qos:(DoorDuMQTTQosLevel)qosLevel
                                 msgId:(UInt16)msgId
                            retainFlag:(BOOL)retain
                               dupFlag:(BOOL)dup {
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendDoorDuMQTTString:topic];
    if (msgId) [data appendUInt16BigEndian:msgId];
    [data appendData:payload];
    DoorDuMQTTMessage *msg = [[DoorDuMQTTMessage alloc] initWithType:DoorDuMQTTPublish
                                                     qos:qosLevel
                                              retainFlag:retain
                                                 dupFlag:dup
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (DoorDuMQTTMessage *)pubackMessageWithMessageId:(UInt16)msgId {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    DoorDuMQTTMessage *msg = [[DoorDuMQTTMessage alloc] initWithType:DoorDuMQTTPuback
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (DoorDuMQTTMessage *)pubrecMessageWithMessageId:(UInt16)msgId {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    DoorDuMQTTMessage *msg = [[DoorDuMQTTMessage alloc] initWithType:DoorDuMQTTPubrec
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (DoorDuMQTTMessage *)pubrelMessageWithMessageId:(UInt16)msgId {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    DoorDuMQTTMessage *msg = [[DoorDuMQTTMessage alloc] initWithType:DoorDuMQTTPubrel
                                                     qos:1
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

+ (DoorDuMQTTMessage *)pubcompMessageWithMessageId:(UInt16)msgId {
    NSMutableData* data = [NSMutableData data];
    [data appendUInt16BigEndian:msgId];
    DoorDuMQTTMessage *msg = [[DoorDuMQTTMessage alloc] initWithType:DoorDuMQTTPubcomp
                                                    data:data];
    msg.mid = msgId;
    return msg;
}

- (instancetype)init {
    self = [super init];
    self.type = 0;
    self.qos = DoorDuMQTTQosLevelAtMostOnce;
    self.retainFlag = false;
    self.mid = 0;
    self.data = nil;
    return self;
}

- (instancetype)initWithType:(DoorDuMQTTCommandType)type {
    self = [self init];
    self.type = type;
    return self;
}

- (instancetype)initWithType:(DoorDuMQTTCommandType)type
                        data:(NSData *)data {
    self = [self init];
    self.type = type;
    self.data = data;
    return self;
}

- (instancetype)initWithType:(DoorDuMQTTCommandType)type
                         qos:(DoorDuMQTTQosLevel)qos
                        data:(NSData *)data {
    self = [self init];
    self.type = type;
    self.qos = qos;
    self.data = data;
    return self;
}

- (instancetype)initWithType:(DoorDuMQTTCommandType)type
                         qos:(DoorDuMQTTQosLevel)qos
                  retainFlag:(BOOL)retainFlag
                     dupFlag:(BOOL)dupFlag
                        data:(NSData *)data {
    self = [self init];
    self.type = type;
    self.qos = qos;
    self.retainFlag = retainFlag;
    self.dupFlag = dupFlag;
    self.data = data;
    return self;
}

- (NSData *)wireFormat {
    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    // encode fixed header
    UInt8 header;
    header = (self.type & 0x0f) << 4;
    if (self.dupFlag) {
        header |= 0x08;
    }
    header |= (self.qos & 0x03) << 1;
    if (self.retainFlag) {
        header |= 0x01;
    }
    [buffer appendBytes:&header length:1];
    
    // encode remaining length
    NSInteger length = self.data.length;
    do {
        UInt8 digit = length % 128;
        length /= 128;
        if (length > 0) {
            digit |= 0x80;
        }
        [buffer appendBytes:&digit length:1];
    }
    while (length > 0);
    
    // encode message data
    if (self.data != nil) {
        [buffer appendData:self.data];
    }
    
    return buffer;
}

+ (DoorDuMQTTMessage *)messageFromData:(NSData *)data {
    DoorDuMQTTMessage *message = nil;
    if (data.length >= 2) {
        UInt8 header;
        [data getBytes:&header length:sizeof(header)];
        UInt8 type = (header >> 4) & 0x0f;
        UInt8 dupFlag = (header >> 3) & 0x01;
        UInt8 qos = (header >> 1) & 0x03;
        UInt8 retainFlag = header & 0x01;
        UInt32 remainingLength = 0;
        UInt32 multiplier = 1;
        UInt8 offset = 1;
        UInt8 digit;
        do {
            if (data.length < offset) {
                offset = -1;
                break;
            }
            [data getBytes:&digit range:NSMakeRange(offset, 1)];
            offset++;
            remainingLength += (digit & 0x7f) * multiplier;
            multiplier *= 128;
            if (multiplier > 128*128*128) {
                multiplier = -1;
                break;
            }
        } while ((digit & 0x80) != 0);
        
        if (type >= DoorDuMQTTConnect &&
            type <= DoorDuMQTTDisconnect) {
            if (offset > 0 &&
                multiplier > 0 &&
                data.length == remainingLength + offset) {
                if ((type == DoorDuMQTTPublish && (qos >= DoorDuMQTTQosLevelAtMostOnce && qos <= DoorDuMQTTQosLevelExactlyOnce)) ||
                    (type == DoorDuMQTTConnect && qos == 0) ||
                    (type == DoorDuMQTTConnack && qos == 0) ||
                    (type == DoorDuMQTTPuback && qos == 0) ||
                    (type == DoorDuMQTTPubrec && qos == 0) ||
                    (type == DoorDuMQTTPubrel && qos == 1) ||
                    (type == DoorDuMQTTPubcomp && qos == 0) ||
                    (type == DoorDuMQTTSubscribe && qos == 1) ||
                    (type == DoorDuMQTTSuback && qos == 0) ||
                    (type == DoorDuMQTTUnsubscribe && qos == 1) ||
                    (type == DoorDuMQTTUnsuback && qos == 0) ||
                    (type == DoorDuMQTTPingreq && qos == 0) ||
                    (type == DoorDuMQTTPingresp && qos == 0) ||
                    (type == DoorDuMQTTDisconnect && qos == 0)) {
                    message = [[DoorDuMQTTMessage alloc] init];
                    message.type = type;
                    message.dupFlag = dupFlag == 1;
                    message.retainFlag = retainFlag == 1;
                    message.qos = qos;
                    message.data = [data subdataWithRange:NSMakeRange(offset, remainingLength)];
                    if ((type == DoorDuMQTTPublish &&
                         (qos == DoorDuMQTTQosLevelAtLeastOnce ||
                          qos == DoorDuMQTTQosLevelExactlyOnce)
                         ) ||
                        type == DoorDuMQTTPuback ||
                        type == DoorDuMQTTPubrec ||
                        type == DoorDuMQTTPubrel ||
                        type == DoorDuMQTTPubcomp ||
                        type == DoorDuMQTTSubscribe ||
                        type == DoorDuMQTTSuback ||
                        type == DoorDuMQTTUnsubscribe ||
                        type == DoorDuMQTTUnsuback) {
                        if (message.data.length >= 2) {
                            [message.data getBytes:&digit range:NSMakeRange(0, 1)];
                            message.mid = digit * 256;
                            [message.data getBytes:&digit range:NSMakeRange(1, 1)];
                            message.mid += digit;
                        } else {
                            message = nil;
                        }
                    }
                    if (type == DoorDuMQTTPuback ||
                        type == DoorDuMQTTPubrec ||
                        type == DoorDuMQTTPubrel ||
                        type == DoorDuMQTTPubcomp ||
                        type == DoorDuMQTTUnsuback ) {
                        if (message.data.length > 2) {
                            message = nil;
                        }
                    }
                    if (type == DoorDuMQTTPingreq ||
                        type == DoorDuMQTTPingresp ||
                        type == DoorDuMQTTDisconnect) {
                        if (message.data.length > 2) {
                            message = nil;
                        }
                    }
                    if (type == DoorDuMQTTConnect) {
                        if (message.data.length < 3) {
                            message = nil;
                        }
                    }
                    if (type == DoorDuMQTTConnack) {
                        if (message.data.length != 2) {
                            message = nil;
                        }
                    }
                    if (type == DoorDuMQTTSubscribe) {
                        if (message.data.length < 3) {
                            message = nil;
                        }
                    }
                    if (type == DoorDuMQTTSuback) {
                        if (message.data.length < 3) {
                            message = nil;
                        }
                    }
                    if (type == DoorDuMQTTUnsubscribe) {
                        if (message.data.length < 3) {
                            message = nil;
                        }
                    }
                } else {
                }
            } else {
            }
        } else {
        }
    } else {
    }
    return message;
}

@end

@implementation NSMutableData (DoorDuMQTT)

- (void)appendByte:(UInt8)byte
{
    [self appendBytes:&byte length:1];
}

- (void)appendUInt16BigEndian:(UInt16)val
{
    [self appendByte:val / 256];
    [self appendByte:val % 256];
}

- (void)appendDoorDuMQTTString:(NSString *)string
{
    if (string) {
        //        UInt8 buf[2];
        //        if (DEBUGMSG) NSLog(@"String=%@", string);
        //        const char* utf8String = [string UTF8String];
        //        if (DEBUGMSG) NSLog(@"UTF8=%s", utf8String);
        //
        //        size_t strLen = strlen(utf8String);
        //        buf[0] = strLen / 256;
        //        buf[1] = strLen % 256;
        //        [self appendBytes:buf length:2];
        //        [self appendBytes:utf8String length:strLen];
        
        // This updated code allows for all kind or UTF characters including 0x0000
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        UInt8 buf[2];
        UInt16 len = data.length;
        buf[0] = len / 256;
        buf[1] = len % 256;
        
        [self appendBytes:buf length:2];
        [self appendData:data];
    }
}

@end

