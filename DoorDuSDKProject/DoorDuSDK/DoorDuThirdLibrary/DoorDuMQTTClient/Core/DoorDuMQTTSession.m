//
// DoorDuMQTTSession.m
// DoorDuMQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//


#import "DoorDuMQTTSession.h"
#import "DoorDuMQTTDecoder.h"
#import "DoorDuMQTTMessage.h"

//#define myLogLevel DDLogLevelVerbose

NSString * const DoorDuMQTTSessionErrorDomain = @"DoorDuMQTT";

@interface DoorDuMQTTSession() <DoorDuMQTTDecoderDelegate, DoorDuMQTTTransportDelegate>

@property (nonatomic, readwrite) DoorDuMQTTSessionStatus status;
@property (nonatomic, readwrite) BOOL sessionPresent;

@property (strong, nonatomic) NSTimer *keepAliveTimer;
@property (strong, nonatomic) NSTimer *checkDupTimer;

@property (strong, nonatomic) DoorDuMQTTDecoder *decoder;

@property (copy, nonatomic) DoorDuMQTTDisconnectHandler disconnectHandler;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, DoorDuMQTTSubscribeHandler> *subscribeHandlers;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, DoorDuMQTTUnsubscribeHandler> *unsubscribeHandlers;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, DoorDuMQTTPublishHandler> *publishHandlers;

@property (nonatomic) UInt16 txMsgId;

@property (nonatomic) BOOL synchronPub;
@property (nonatomic) UInt16 synchronPubMid;
@property (nonatomic) BOOL synchronUnsub;
@property (nonatomic) UInt16 synchronUnsubMid;
@property (nonatomic) BOOL synchronSub;
@property (nonatomic) UInt16 synchronSubMid;
@property (nonatomic) BOOL synchronConnect;
@property (nonatomic) BOOL synchronDisconnect;

@end

#define DUPTIMEOUT 20.0
#define DUPLOOP 1.0

@implementation DoorDuMQTTSession
@synthesize certificates;

- (void)setCertificates:(NSArray *)newCertificates {
    certificates = newCertificates;
    if (self.transport) {
        if ([self.transport respondsToSelector:@selector(setCertificates:)]) {
            [self.transport performSelector:@selector(setCertificates:) withObject:certificates];
        }
    }
}

- (instancetype)init {
    self = [super init];
    self.txMsgId = 1;
    self.subscribeHandlers = [[NSMutableDictionary alloc] init];
    self.unsubscribeHandlers = [[NSMutableDictionary alloc] init];
    self.publishHandlers = [[NSMutableDictionary alloc] init];
    
    self.clientId = nil;
    self.userName = nil;
    self.password = nil;
    self.keepAliveInterval = 60;
    self.cleanSessionFlag = true;
    self.willFlag = false;
    self.willTopic = nil;
    self.willMsg = nil;
    self.willQoS = DoorDuMQTTQosLevelAtMostOnce;
    self.willRetainFlag = false;
    self.protocolLevel = DoorDuMQTTProtocolVersion311;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    
    self.status = DoorDuMQTTSessionStatusCreated;
    
    return self;
}

- (void)setClientId:(NSString *)clientId
{
    if (!clientId) {
        clientId = [NSString stringWithFormat:@"DoorDuMQTTClient%.0f",fmod([[NSDate date] timeIntervalSince1970], 1.0) * 1000000.0];
    }
    
    //NSAssert(clientId.length > 0 || self.cleanSessionFlag, @"clientId must be at least 1 character long if cleanSessionFlag is off");
    
    //NSAssert([clientId dataUsingEncoding:NSUTF8StringEncoding], @"clientId contains non-UTF8 characters");
    //NSAssert([clientId dataUsingEncoding:NSUTF8StringEncoding].length <= 65535L, @"clientId may not be longer than 65535 bytes in UTF8 representation");
    
    _clientId = clientId;
}

- (void)setUserName:(NSString *)userName
{
    if (userName) {
        //NSAssert([userName dataUsingEncoding:NSUTF8StringEncoding], @"userName contains non-UTF8 characters");
        //NSAssert([userName dataUsingEncoding:NSUTF8StringEncoding].length <= 65535L, @"userName may not be longer than 65535 bytes in UTF8 representation");
    }
    
    _userName = userName;
}

- (void)setPassword:(NSString *)password
{
    if (password) {
        //NSAssert(self.userName, @"password specified without userName");
        //NSAssert([password dataUsingEncoding:NSUTF8StringEncoding], @"password contains non-UTF8 characters");
        //NSAssert([password dataUsingEncoding:NSUTF8StringEncoding].length <= 65535L, @"password may not be longer than 65535 bytes in UTF8 representation");
    }
    _password = password;
}

- (void)setProtocolLevel:(DoorDuMQTTProtocolVersion)protocolLevel
{
    //NSAssert(protocolLevel == DoorDuMQTTProtocolVersion31 || protocolLevel == DoorDuMQTTProtocolVersion311, @"allowed protocolLevel values are 3 or 4 only");
    _protocolLevel = protocolLevel;
}

- (void)setRunLoop:(NSRunLoop *)runLoop
{
    if (!runLoop ) {
        runLoop = [NSRunLoop currentRunLoop];
    }
    _runLoop = runLoop;
}

- (void)setRunLoopMode:(NSString *)runLoopMode
{
    if (!runLoopMode) {
        runLoopMode = NSRunLoopCommonModes;
    }
    _runLoopMode = runLoopMode;
}

- (UInt16)subscribeToTopic:(NSString *)topic
                   atLevel:(DoorDuMQTTQosLevel)qosLevel {
    return [self subscribeToTopic:topic atLevel:qosLevel subscribeHandler:nil];
}

- (UInt16)subscribeToTopic:(NSString *)topic
                   atLevel:(DoorDuMQTTQosLevel)qosLevel
          subscribeHandler:(DoorDuMQTTSubscribeHandler)subscribeHandler {
    return [self subscribeToTopics:topic ? @{topic: @(qosLevel)} : @{} subscribeHandler:subscribeHandler];
}

- (UInt16)subscribeToTopics:(NSDictionary<NSString *, NSNumber *> *)topics {
    return [self subscribeToTopics:topics subscribeHandler:nil];
}

- (UInt16)subscribeToTopics:(NSDictionary<NSString *, NSNumber *> *)topics subscribeHandler:(DoorDuMQTTSubscribeHandler)subscribeHandler {
    
    //for (NSNumber *qos in [topics allValues]) {
    //NSAssert([qos intValue] >= 0 && [qos intValue] <= 2, @"qosLevel must be 0, 1, or 2");
    //}
    
    UInt16 mid = [self nextMsgId];
    if (subscribeHandler) {
        [self.subscribeHandlers setObject:[subscribeHandler copy] forKey:@(mid)];
    } else {
        [self.subscribeHandlers removeObjectForKey:@(mid)];
    }
    (void)[self encode:[DoorDuMQTTMessage subscribeMessageWithMessageId:mid
                                                           topics:topics]];
    
    return mid;
}

- (UInt16)unsubscribeTopic:(NSString*)topic {
    return [self unsubscribeTopic:topic unsubscribeHandler:nil];
}

- (UInt16)unsubscribeTopic:(NSString *)topic unsubscribeHandler:(DoorDuMQTTUnsubscribeHandler)unsubscribeHandler {
    return [self unsubscribeTopics:topic ? @[topic] : @[] unsubscribeHandler:unsubscribeHandler];
}

- (UInt16)unsubscribeTopics:(NSArray<NSString *> *)topics {
    return [self unsubscribeTopics:topics unsubscribeHandler:nil];
}

- (UInt16)unsubscribeTopics:(NSArray<NSString *> *)topics unsubscribeHandler:(DoorDuMQTTUnsubscribeHandler)unsubscribeHandler {
    UInt16 mid = [self nextMsgId];
    if (unsubscribeHandler) {
        [self.unsubscribeHandlers setObject:[unsubscribeHandler copy] forKey:@(mid)];
    } else {
        [self.unsubscribeHandlers removeObjectForKey:@(mid)];
    }
    (void)[self encode:[DoorDuMQTTMessage unsubscribeMessageWithMessageId:mid
                                                             topics:topics]];
    return mid;
}

- (UInt16)publishData:(NSData*)data
              onTopic:(NSString*)topic
               retain:(BOOL)retainFlag
                  qos:(DoorDuMQTTQosLevel)qos {
    return [self publishData:data onTopic:topic retain:retainFlag qos:qos publishHandler:nil];
}

- (UInt16)publishData:(NSData *)data
              onTopic:(NSString *)topic
               retain:(BOOL)retainFlag
                  qos:(DoorDuMQTTQosLevel)qos
       publishHandler:(DoorDuMQTTPublishHandler)publishHandler
{
    
    //NSAssert(qos >= 0 && qos <= 2, @"qos must be 0, 1, or 2");
    
    UInt16 msgId = 0;
    if (qos) {
        msgId = [self nextMsgId];
    }
    DoorDuMQTTMessage *msg = [DoorDuMQTTMessage publishMessageWithData:data
                                                   onTopic:topic
                                                       qos:qos
                                                     msgId:msgId
                                                retainFlag:retainFlag
                                                   dupFlag:FALSE];
    if (qos) {
        id<DoorDuMQTTFlow> flow;
        if ([self.persistence windowSize:self.clientId] <= self.persistence.maxWindowSize &&
            self.status == DoorDuMQTTSessionStatusConnected) {
            flow = [self.persistence storeMessageForClientId:self.clientId
                                                       topic:topic
                                                        data:data
                                                  retainFlag:retainFlag
                                                         qos:qos
                                                       msgId:msgId
                                                incomingFlag:NO
                                                 commandType:DoorDuMQTTPublish
                                                    deadline:[NSDate dateWithTimeIntervalSinceNow:DUPTIMEOUT]];
        } else {
            flow = [self.persistence storeMessageForClientId:self.clientId
                                                       topic:topic
                                                        data:data
                                                  retainFlag:retainFlag
                                                         qos:qos
                                                       msgId:msgId
                                                incomingFlag:NO
                                                 commandType:DoorDuMQTT_None
                                                    deadline:[NSDate date]];
        }
        if (!flow) {
            NSError *error = [NSError errorWithDomain:DoorDuMQTTSessionErrorDomain
                                                 code:DoorDuMQTTSessionErrorDroppingOutgoingMessage
                                             userInfo:@{NSLocalizedDescriptionKey : @"Dropping outgoing Message"}];
            if (publishHandler) {
                [self onPublish:publishHandler error:error];
            }
            msgId = 0;
        } else {
            [self.persistence sync];
            if (publishHandler) {
                [self.publishHandlers setObject:[publishHandler copy] forKey:@(msgId)];
            } else {
                [self.publishHandlers removeObjectForKey:@(msgId)];
            }
            
            if ([flow.commandType intValue] == DoorDuMQTTPublish) {
                if (![self encode:msg]) {
                    flow.commandType = [NSNumber numberWithUnsignedInt:DoorDuMQTT_None];
                    flow.deadline = [NSDate date];
                    [self.persistence sync];
                }
            } else {
            }
        }
    } else {
        NSError *error = nil;
        if (![self encode:msg]) {
            error = [NSError errorWithDomain:DoorDuMQTTSessionErrorDomain
                                        code:DoorDuMQTTSessionErrorEncoderNotReady
                                    userInfo:@{NSLocalizedDescriptionKey : @"Encoder not ready"}];
        }
        if (publishHandler) {
            [self onPublish:publishHandler error:error];
        }
    }
    [self tell];
    return msgId;
}


- (void)close {
    [self closeWithDisconnectHandler:nil];
}

- (void)closeWithDisconnectHandler:(DoorDuMQTTDisconnectHandler)disconnectHandler {
    self.disconnectHandler = disconnectHandler;
    
    if (self.status == DoorDuMQTTSessionStatusConnected) {
        self.status = DoorDuMQTTSessionStatusDisconnecting;
        (void)[self encode:[DoorDuMQTTMessage disconnectMessage]];
    } else {
        [self closeInternal];
    }
}

- (void)closeInternal
{
    
    if (self.checkDupTimer) {
        [self.checkDupTimer invalidate];
        self.checkDupTimer = nil;
    }
    
    if (self.keepAliveTimer) {
        [self.keepAliveTimer invalidate];
        self.keepAliveTimer = nil;
    }
    
    if (self.transport) {
        [self.transport close];
        self.transport.delegate = nil;
    }
    
    if(self.decoder){
        [self.decoder close];
        self.decoder.delegate = nil;
    }
    
    self.status = DoorDuMQTTSessionStatusClosed;
    if ([self.delegate respondsToSelector:@selector(handleEvent:event:error:)]) {
        [self.delegate handleEvent:self event:DoorDuMQTTSessionEventConnectionClosed error:nil];
    }
    if ([self.delegate respondsToSelector:@selector(connectionClosed:)]) {
        [self.delegate connectionClosed:self];
    }
    
    NSError *error = [NSError errorWithDomain:DoorDuMQTTSessionErrorDomain
                                         code:DoorDuMQTTSessionErrorNoResponse
                                     userInfo:@{NSLocalizedDescriptionKey : @"No response"}];
    
    NSArray *allSubscribeHandlers = self.subscribeHandlers.allValues;
    [self.subscribeHandlers removeAllObjects];
    for (DoorDuMQTTSubscribeHandler subscribeHandler in allSubscribeHandlers) {
        subscribeHandler(error, nil);
    }
    
    NSArray *allUnsubscribeHandlers = self.unsubscribeHandlers.allValues;
    [self.unsubscribeHandlers removeAllObjects];
    for (DoorDuMQTTUnsubscribeHandler unsubscribeHandler in allUnsubscribeHandlers) {
        unsubscribeHandler(error);
    }
    
    DoorDuMQTTDisconnectHandler disconnectHandler = self.disconnectHandler;
    if (disconnectHandler) {
        self.disconnectHandler = nil;
        disconnectHandler(nil);
    }
    
    [self tell];
    self.synchronPub = FALSE;
    self.synchronPubMid = 0;
    self.synchronSub = FALSE;
    self.synchronSubMid = 0;
    self.synchronUnsub = FALSE;
    self.synchronUnsubMid = 0;
}


- (void)keepAlive:(NSTimer *)timer
{
    (void)[self encode:[DoorDuMQTTMessage pingreqMessage]];
}

- (void)checkDup:(NSTimer *)timer
{
    [self checkTxFlows];
}

- (void)checkTxFlows {
    NSUInteger windowSize;
    DoorDuMQTTMessage *message;
    if (self.status != DoorDuMQTTSessionStatusConnected) {
        return;
    }
    
    NSArray *flows = [self.persistence allFlowsforClientId:self.clientId
                                              incomingFlag:NO];
    windowSize = 0;
    message = nil;
    
    for (id<DoorDuMQTTFlow> flow in flows) {
        if ([flow.commandType intValue] != DoorDuMQTT_None) {
            windowSize++;
        }
    }
    for (id<DoorDuMQTTFlow> flow in flows) {
        if ([flow.deadline compare:[NSDate date]] == NSOrderedAscending) {
            switch ([flow.commandType intValue]) {
                case 0:
                    if (windowSize <= self.persistence.maxWindowSize) {
                        message = [DoorDuMQTTMessage publishMessageWithData:flow.data
                                                              onTopic:flow.topic
                                                                  qos:[flow.qosLevel intValue]
                                                                msgId:[flow.messageId intValue]
                                                           retainFlag:[flow.retainedFlag boolValue]
                                                              dupFlag:NO];
                        if ([self encode:message]) {
                            flow.commandType = @(DoorDuMQTTPublish);
                            flow.deadline = [NSDate dateWithTimeIntervalSinceNow:DUPTIMEOUT];
                            [self.persistence sync];
                            windowSize++;
                        }
                    }
                    break;
                case DoorDuMQTTPublish:
                    message = [DoorDuMQTTMessage publishMessageWithData:flow.data
                                                          onTopic:flow.topic
                                                              qos:[flow.qosLevel intValue]
                                                            msgId:[flow.messageId intValue]
                                                       retainFlag:[flow.retainedFlag boolValue]
                                                          dupFlag:YES];
                    if ([self encode:message]) {
                        flow.deadline = [NSDate dateWithTimeIntervalSinceNow:DUPTIMEOUT];
                        [self.persistence sync];
                    }
                    break;
                case DoorDuMQTTPubrel:
                    message = [DoorDuMQTTMessage pubrelMessageWithMessageId:[flow.messageId intValue]];
                    if ([self encode:message]) {
                        flow.deadline = [NSDate dateWithTimeIntervalSinceNow:DUPTIMEOUT];
                        [self.persistence sync];
                    }
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)decoder:(DoorDuMQTTDecoder*)sender handleEvent:(DoorDuMQTTDecoderEvent)eventCode error:(NSError *)error {
    __unused NSArray *events = @[
                        @"DoorDuMQTTDecoderEventProtocolError",
                        @"DoorDuMQTTDecoderEventConnectionClosed",
                        @"DoorDuMQTTDecoderEventConnectionError"
                        ];
    switch (eventCode) {
        case DoorDuMQTTDecoderEventConnectionClosed:
            [self error:DoorDuMQTTSessionEventConnectionClosedByBroker error:error];
            break;
        case DoorDuMQTTDecoderEventConnectionError:
            [self connectionError:error];
            break;
        case DoorDuMQTTDecoderEventProtocolError:
            [self protocolError:error];
            break;
    }
    DoorDuMQTTConnectHandler connectHandler = self.connectHandler;
    if (connectHandler) {
        self.connectHandler = nil;
        [self onConnect:connectHandler error:error];
    }
}

- (void)decoder:(DoorDuMQTTDecoder*)sender didReceiveMessage:(NSData *)data {
    DoorDuMQTTMessage *message = [DoorDuMQTTMessage messageFromData:data];
    if (!message) {
        NSError * error = [NSError errorWithDomain:DoorDuMQTTSessionErrorDomain
                                              code:DoorDuMQTTSessionErrorIllegalMessageReceived
                                          userInfo:@{NSLocalizedDescriptionKey : @"DoorDuMQTT illegal message received"}];
        [self protocolError:error];
        
        return;
    }
    
    @synchronized(sender) {
        if ([self.delegate respondsToSelector:@selector(received:type:qos:retained:duped:mid:data:)]) {
            [self.delegate received:self
                               type:message.type
                                qos:message.qos
                           retained:message.retainFlag
                              duped:message.dupFlag
                                mid:message.mid
                               data:message.data];
        }
        if ([self.delegate respondsToSelector:@selector(ignoreReceived:type:qos:retained:duped:mid:data:)]) {
            if ([self.delegate ignoreReceived:self
                                         type:message.type
                                          qos:message.qos
                                     retained:message.retainFlag
                                        duped:message.dupFlag
                                          mid:message.mid
                                         data:message.data]) {
                return;
            }
        }
        switch (self.status) {
            case DoorDuMQTTSessionStatusConnecting:
                switch (message.type) {
                    case DoorDuMQTTConnack:
                        if (message.data.length != 2) {
                            NSError *error = [NSError errorWithDomain:DoorDuMQTTSessionErrorDomain
                                                                 code:DoorDuMQTTSessionErrorInvalidConnackReceived
                                                             userInfo:@{NSLocalizedDescriptionKey : @"DoorDuMQTT protocol CONNACK expected"}];
                            
                            [self protocolError:error];
                            DoorDuMQTTConnectHandler connectHandler = self.connectHandler;
                            if (connectHandler) {
                                self.connectHandler = nil;
                                [self onConnect:connectHandler error:error];
                            }
                        } else {
                            const UInt8 *bytes = message.data.bytes;
                            if (bytes[1] == 0) {
                                self.status = DoorDuMQTTSessionStatusConnected;
                                self.sessionPresent = ((bytes[0] & 0x01) == 0x01);
                                
                                self.checkDupTimer = [NSTimer timerWithTimeInterval:DUPLOOP
                                                                             target:self
                                                                           selector:@selector(checkDup:)
                                                                           userInfo:nil
                                                                            repeats:YES];
                                [self.runLoop addTimer:self.checkDupTimer forMode:self.runLoopMode];
                                [self checkDup:self.checkDupTimer];
                                
                                self.keepAliveTimer = [NSTimer timerWithTimeInterval:self.keepAliveInterval
                                                                              target:self
                                                                            selector:@selector(keepAlive:)
                                                                            userInfo:nil
                                                                             repeats:YES];
                                [self.runLoop addTimer:self.keepAliveTimer forMode:self.runLoopMode];
                                
                                if ([self.delegate respondsToSelector:@selector(handleEvent:event:error:)]) {
                                    [self.delegate handleEvent:self event:DoorDuMQTTSessionEventConnected error:nil];
                                }
                                if ([self.delegate respondsToSelector:@selector(connected:)]) {
                                    [self.delegate connected:self];
                                }
                                if ([self.delegate respondsToSelector:@selector(connected:sessionPresent:)]) {
                                    [self.delegate connected:self sessionPresent:self.sessionPresent];
                                }
                                
                                if(self.connectionHandler){
                                    self.connectionHandler(DoorDuMQTTSessionEventConnected);
                                }
                                DoorDuMQTTConnectHandler connectHandler = self.connectHandler;
                                if (connectHandler) {
                                    self.connectHandler = nil;
                                    [self onConnect:connectHandler error:nil];
                                }
                                
                            } else {
                                NSString *errorDescription;
                                NSInteger errorCode = 0;
                                switch (bytes[1]) {
                                    case 1:
                                        errorDescription = @"DoorDuMQTT CONNACK: unacceptable protocol version";
                                        errorCode = DoorDuMQTTSessionErrorConnackUnacceptableProtocolVersion;
                                        break;
                                    case 2:
                                        errorDescription = @"DoorDuMQTT CONNACK: identifier rejected";
                                        errorCode = DoorDuMQTTSessionErrorConnackIdentifierRejected;
                                        break;
                                    case 3:
                                        errorDescription = @"DoorDuMQTT CONNACK: server unavailable";
                                        errorCode = DoorDuMQTTSessionErrorConnackServeUnavailable;
                                        break;
                                    case 4:
                                        errorDescription = @"DoorDuMQTT CONNACK: bad user name or password";
                                        errorCode = DoorDuMQTTSessionErrorConnackBadUsernameOrPassword;
                                        break;
                                    case 5:
                                        errorDescription = @"DoorDuMQTT CONNACK: not authorized";
                                        errorCode = DoorDuMQTTSessionErrorConnackNotAuthorized;
                                        break;
                                    default:
                                        errorDescription = @"DoorDuMQTT CONNACK: reserved for future use";
                                        errorCode = DoorDuMQTTSessionErrorConnackReserved;
                                        break;
                                }
                                
                                NSError *error = [NSError errorWithDomain:DoorDuMQTTSessionErrorDomain
                                                                     code:errorCode
                                                                 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
                                [self error:DoorDuMQTTSessionEventConnectionRefused error:error];
                                if ([self.delegate respondsToSelector:@selector(connectionRefused:error:)]) {
                                    [self.delegate connectionRefused:self error:error];
                                }
                                DoorDuMQTTConnectHandler connectHandler = self.connectHandler;
                                if (connectHandler) {
                                    self.connectHandler = nil;
                                    [self onConnect:connectHandler error:error];
                                }
                            }
                            
                            self.synchronConnect = FALSE;
                        }
                        break;
                    default: {
                        NSError * error = [NSError errorWithDomain:DoorDuMQTTSessionErrorDomain
                                                              code:DoorDuMQTTSessionErrorNoConnackReceived
                                                          userInfo:@{NSLocalizedDescriptionKey : @"DoorDuMQTT protocol no CONNACK"}];
                        [self protocolError:error];
                        DoorDuMQTTConnectHandler connectHandler = self.connectHandler;
                        if (connectHandler) {
                            self.connectHandler = nil;
                            [self onConnect:connectHandler error:error];
                        }
                        break;
                    }
                }
                break;
            case DoorDuMQTTSessionStatusConnected:
                switch (message.type) {
                    case DoorDuMQTTPublish:
                        [self handlePublish:message];
                        break;
                    case DoorDuMQTTPuback:
                        [self handlePuback:message];
                        break;
                    case DoorDuMQTTPubrec:
                        [self handlePubrec:message];
                        break;
                    case DoorDuMQTTPubrel:
                        [self handlePubrel:message];
                        break;
                    case DoorDuMQTTPubcomp:
                        [self handlePubcomp:message];
                        break;
                    case DoorDuMQTTSuback:
                        [self handleSuback:message];
                        break;
                    case DoorDuMQTTUnsuback:
                        [self handleUnsuback:message];
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
    }
}

- (void)handlePublish:(DoorDuMQTTMessage*)msg {
    NSData *data = [msg data];
    if ([data length] < 2) {
        return;
    }
    UInt8 const *bytes = [data bytes];
    UInt16 topicLength = 256 * bytes[0] + bytes[1];
    if ([data length] < 2 + topicLength) {
        return;
    }
    NSData *topicData = [data subdataWithRange:NSMakeRange(2, topicLength)];
    NSString *topic = [[NSString alloc] initWithData:topicData
                                            encoding:NSUTF8StringEncoding];
    if (!topic) {
        topic = [[NSString alloc] initWithData:topicData
                                      encoding:NSISOLatin1StringEncoding];
    }
    NSRange range = NSMakeRange(2 + topicLength, [data length] - topicLength - 2);
    data = [data subdataWithRange:range];
    if ([msg qos] == 0) {
        if ([self.delegate respondsToSelector:@selector(newMessage:data:onTopic:qos:retained:mid:)]) {
            [self.delegate newMessage:self
                                 data:data
                              onTopic:topic
                                  qos:msg.qos
                             retained:msg.retainFlag
                                  mid:0];
        }
        if ([self.delegate respondsToSelector:@selector(newMessageWithFeedback:data:onTopic:qos:retained:mid:)]) {
            [self.delegate newMessageWithFeedback:self
                                             data:data
                                          onTopic:topic
                                              qos:msg.qos
                                         retained:msg.retainFlag
                                              mid:0];
        }
        if (self.messageHandler) {
            self.messageHandler(data, topic);
        }
    } else {
        if ([data length] >= 2) {
            bytes = [data bytes];
            UInt16 msgId = 256 * bytes[0] + bytes[1];
            msg.mid = msgId;
            data = [data subdataWithRange:NSMakeRange(2, [data length] - 2)];
            if ([msg qos] == 1) {
                BOOL processed = true;
                if ([self.delegate respondsToSelector:@selector(newMessage:data:onTopic:qos:retained:mid:)]) {
                    [self.delegate newMessage:self
                                         data:data
                                      onTopic:topic
                                          qos:msg.qos
                                     retained:msg.retainFlag
                                          mid:msgId];
                }
                if ([self.delegate respondsToSelector:@selector(newMessageWithFeedback:data:onTopic:qos:retained:mid:)]) {
                    processed = [self.delegate newMessageWithFeedback:self
                                                                 data:data
                                                              onTopic:topic
                                                                  qos:msg.qos
                                                             retained:msg.retainFlag
                                                                  mid:msgId];
                }
                if (self.messageHandler) {
                    self.messageHandler(data, topic);
                }
                if (processed) {
                    (void)[self encode:[DoorDuMQTTMessage pubackMessageWithMessageId:msgId]];
                }
                return;
            } else {
                if (![self.persistence storeMessageForClientId:self.clientId
                                                         topic:topic
                                                          data:data
                                                    retainFlag:msg.retainFlag
                                                           qos:msg.qos
                                                         msgId:msgId
                                                  incomingFlag:YES
                                                   commandType:DoorDuMQTTPubrec
                                                      deadline:[NSDate dateWithTimeIntervalSinceNow:DUPTIMEOUT]]) {
                } else {
                    [self.persistence sync];
                    [self tell];
                    (void)[self encode:[DoorDuMQTTMessage pubrecMessageWithMessageId:msgId]];
                }
            }
        }
    }
}

- (void)handlePuback:(DoorDuMQTTMessage*)msg
{
    if ([[msg data] length] == 2) {
        UInt8 const *bytes = [[msg data] bytes];
        UInt16 messageId = (256 * bytes[0] + bytes[1]);
        msg.mid = messageId;
        id<DoorDuMQTTFlow> flow = [self.persistence flowforClientId:self.clientId
                                                 incomingFlag:NO
                                                    messageId:messageId];
        if (flow) {
            if ([flow.commandType intValue] == DoorDuMQTTPublish && [flow.qosLevel intValue] == DoorDuMQTTQosLevelAtLeastOnce) {
                [self.persistence deleteFlow:flow];
                [self.persistence sync];
                [self tell];
                if ([self.delegate respondsToSelector:@selector(messageDelivered:msgID:)]) {
                    [self.delegate messageDelivered:self msgID:messageId];
                }
                if (self.synchronPub && self.synchronPubMid == messageId) {
                    self.synchronPub = FALSE;
                }
                DoorDuMQTTPublishHandler publishHandler = [self.publishHandlers objectForKey:@(msg.mid)];
                if (publishHandler) {
                    [self.publishHandlers removeObjectForKey:@(msg.mid)];
                    [self onPublish:publishHandler error:nil];
                }
            }
        }
    }
}

- (void)handleSuback:(DoorDuMQTTMessage*)msg
{
    if ([[msg data] length] >= 3) {
        UInt8 const *bytes = [[msg data] bytes];
        UInt16 messageId = (256 * bytes[0] + bytes[1]);
        msg.mid = messageId;
        NSMutableArray *qoss = [[NSMutableArray alloc] init];
        for (int i = 2; i < [[msg data] length]; i++) {
            [qoss addObject:@(bytes[i])];
        }
        if ([self.delegate respondsToSelector:@selector(subAckReceived:msgID:grantedQoss:)]) {
            [self.delegate subAckReceived:self msgID:msg.mid grantedQoss:qoss];
        }
        if (self.synchronSub && self.synchronSubMid == msg.mid) {
            self.synchronSub = FALSE;
        }
        DoorDuMQTTSubscribeHandler subscribeHandler = [self.subscribeHandlers objectForKey:@(msg.mid)];
        if (subscribeHandler) {
            [self.subscribeHandlers removeObjectForKey:@(msg.mid)];
            [self onSubscribe:subscribeHandler error:nil gQoss:qoss];
        }
    }
}

- (void)handleUnsuback:(DoorDuMQTTMessage *)message {
    if ([self.delegate respondsToSelector:@selector(unsubAckReceived:msgID:)]) {
        [self.delegate unsubAckReceived:self msgID:message.mid];
    }
    if (self.synchronUnsub && self.synchronUnsubMid == message.mid) {
        self.synchronUnsub = FALSE;
    }
    DoorDuMQTTUnsubscribeHandler unsubscribeHandler = [self.unsubscribeHandlers objectForKey:@(message.mid)];
    if (unsubscribeHandler) {
        [self.unsubscribeHandlers removeObjectForKey:@(message.mid)];
        [self onUnsubscribe:unsubscribeHandler error:nil];
    }
}

- (void)handlePubrec:(DoorDuMQTTMessage *)message {
    DoorDuMQTTMessage *pubrelmessage = [DoorDuMQTTMessage pubrelMessageWithMessageId:message.mid];
    id<DoorDuMQTTFlow> flow = [self.persistence flowforClientId:self.clientId
                                             incomingFlag:NO
                                                messageId:message.mid];
    if (flow) {
        if ([flow.commandType intValue] == DoorDuMQTTPublish && [flow.qosLevel intValue] == DoorDuMQTTQosLevelExactlyOnce) {
            flow.commandType = @(DoorDuMQTTPubrel);
            flow.topic = nil;
            flow.data = nil;
            flow.deadline = [NSDate dateWithTimeIntervalSinceNow:DUPTIMEOUT];
            [self.persistence sync];
        }
    }
    (void)[self encode:pubrelmessage];
}

- (void)handlePubrel:(DoorDuMQTTMessage *)message {
    id<DoorDuMQTTFlow> flow = [self.persistence flowforClientId:self.clientId
                                             incomingFlag:YES
                                                messageId:message.mid];
    if (flow) {
        BOOL processed = true;
        if ([self.delegate respondsToSelector:@selector(newMessage:data:onTopic:qos:retained:mid:)]) {
            [self.delegate newMessage:self
                                 data:flow.data
                              onTopic:flow.topic
                                  qos:[flow.qosLevel intValue]
                             retained:[flow.retainedFlag boolValue]
                                  mid:[flow.messageId intValue]
             ];
        }
        if ([self.delegate respondsToSelector:@selector(newMessageWithFeedback:data:onTopic:qos:retained:mid:)]) {
            processed = [self.delegate newMessageWithFeedback:self
                                                         data:flow.data
                                                      onTopic:flow.topic
                                                          qos:[flow.qosLevel intValue]
                                                     retained:[flow.retainedFlag boolValue]
                                                          mid:[flow.messageId intValue]
                         ];
        }
        if(self.messageHandler){
            self.messageHandler(flow.data, flow.topic);
        }
        if (processed) {
            [self.persistence deleteFlow:flow];
            [self.persistence sync];
            [self tell];
            (void)[self encode:[DoorDuMQTTMessage pubcompMessageWithMessageId:message.mid]];
        }
    }
}

- (void)handlePubcomp:(DoorDuMQTTMessage *)message {
    id<DoorDuMQTTFlow> flow = [self.persistence flowforClientId:self.clientId
                                             incomingFlag:NO
                                                messageId:message.mid];
    if (flow && [flow.commandType intValue] == DoorDuMQTTPubrel) {
        [self.persistence deleteFlow:flow];
        [self.persistence sync];
        [self tell];
        if ([self.delegate respondsToSelector:@selector(messageDelivered:msgID:)]) {
            [self.delegate messageDelivered:self msgID:message.mid];
        }
        if (self.synchronPub && self.synchronPubMid == message.mid) {
            self.synchronPub = FALSE;
        }
        DoorDuMQTTPublishHandler publishHandler = [self.publishHandlers objectForKey:@(message.mid)];
        if (publishHandler) {
            [self.publishHandlers removeObjectForKey:@(message.mid)];
            [self onPublish:publishHandler error:nil];
        }
    }
}

- (void)connectionError:(NSError *)error {
    [self error:DoorDuMQTTSessionEventConnectionError error:error];
    if ([self.delegate respondsToSelector:@selector(connectionError:error:)]) {
        [self.delegate connectionError:self error:error];
    }
    if (self.connectHandler) {
        DoorDuMQTTConnectHandler connectHandler = self.connectHandler;
        self.connectHandler = nil;
        [self onConnect:connectHandler error:error];
    }
}

- (void)protocolError:(NSError *)error {
    [self error:DoorDuMQTTSessionEventProtocolError error:error];
    if ([self.delegate respondsToSelector:@selector(protocolError:error:)]) {
        [self.delegate protocolError:self error:error];
    }
}

- (void)error:(DoorDuMQTTSessionEvent)eventCode error:(NSError *)error {
    
    self.status = DoorDuMQTTSessionStatusError;
    [self closeInternal];
    if ([self.delegate respondsToSelector:@selector(handleEvent:event:error:)]) {
        [self.delegate handleEvent:self event:eventCode error:error];
    }
    
    if(self.connectionHandler){
        self.connectionHandler(eventCode);
    }

    if(eventCode == DoorDuMQTTSessionEventConnectionClosedByBroker && self.connectHandler) {
        error = [NSError errorWithDomain:DoorDuMQTTSessionErrorDomain
                                    code:DoorDuMQTTSessionErrorConnectionRefused
                                userInfo:@{NSLocalizedDescriptionKey : @"Server has closed connection without connack."}];

        DoorDuMQTTConnectHandler connectHandler = self.connectHandler;
        self.connectHandler = nil;
        [self onConnect:connectHandler error:error];
    }
    
    self.synchronPub = FALSE;
    self.synchronPubMid = 0;
    self.synchronSub = FALSE;
    self.synchronSubMid = 0;
    self.synchronUnsub = FALSE;
    self.synchronUnsubMid = 0;
    self.synchronConnect = FALSE;
    self.synchronDisconnect = FALSE;
}

- (UInt16)nextMsgId {
    @synchronized(self) {
        self.txMsgId++;
        while (self.txMsgId == 0 || [self.persistence flowforClientId:self.clientId
                                                         incomingFlag:NO
                                                            messageId:self.txMsgId] != nil) {
            self.txMsgId++;
        }
        return self.txMsgId;
    }
}

- (void)tell {
    NSUInteger incoming = [self.persistence allFlowsforClientId:self.clientId
                                                   incomingFlag:YES].count;
    NSUInteger outflowing = [self.persistence allFlowsforClientId:self.clientId
                                                     incomingFlag:NO].count;
    if ([self.delegate respondsToSelector:@selector(buffered:flowingIn:flowingOut:)]) {
        [self.delegate buffered:self
                      flowingIn:incoming
                     flowingOut:outflowing];
    }
    if ([self.delegate respondsToSelector:@selector(buffered:queued:flowingIn:flowingOut:)]) {
        [self.delegate buffered:self
                         queued:0
                      flowingIn:incoming
                     flowingOut:outflowing];
    }
}

/*
 * Threaded block callbacks
 */
- (void)onConnect:(DoorDuMQTTConnectHandler)connectHandler error:(NSError *)error {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:connectHandler forKey:@"Block"];
    if (error) {
        [dict setObject:error forKey:@"Error"];
    }
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(onConnectExecute:) object:dict];
    [thread start];
}

- (void)onConnectExecute:(NSDictionary *)dict {
    DoorDuMQTTConnectHandler connectHandler = [dict objectForKey:@"Block"];
    NSError *error = [dict objectForKey:@"Error"];
    connectHandler(error);
}

- (void)onDisconnect:(DoorDuMQTTDisconnectHandler)disconnectHandler error:(NSError *)error {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:disconnectHandler forKey:@"Block"];
    if (error) {
        [dict setObject:error forKey:@"Error"];
    }
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(onDisconnectExecute:) object:dict];
    [thread start];
}

- (void)onDisconnectExecute:(NSDictionary *)dict {
    DoorDuMQTTDisconnectHandler disconnectHandler = [dict objectForKey:@"Block"];
    NSError *error = [dict objectForKey:@"Error"];
    disconnectHandler(error);
}

- (void)onSubscribe:(DoorDuMQTTSubscribeHandler)subscribeHandler error:(NSError *)error gQoss:(NSArray *)gqoss{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:subscribeHandler forKey:@"Block"];
    if (error) {
        [dict setObject:error forKey:@"Error"];
    }
    if (gqoss) {
        [dict setObject:gqoss forKey:@"GQoss"];
    }
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(onSubscribeExecute:) object:dict];
    [thread start];
}

- (void)onSubscribeExecute:(NSDictionary *)dict {
    DoorDuMQTTSubscribeHandler subscribeHandler = [dict objectForKey:@"Block"];
    NSError *error = [dict objectForKey:@"Error"];
    NSArray *gqoss = [dict objectForKey:@"GQoss"];
    subscribeHandler(error, gqoss);
}

- (void)onUnsubscribe:(DoorDuMQTTUnsubscribeHandler)unsubscribeHandler error:(NSError *)error {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:unsubscribeHandler forKey:@"Block"];
    if (error) {
        [dict setObject:error forKey:@"Error"];
    }
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(onUnsubscribeExecute:) object:dict];
    [thread start];
}

- (void)onUnsubscribeExecute:(NSDictionary *)dict {
    DoorDuMQTTUnsubscribeHandler unsubscribeHandler = [dict objectForKey:@"Block"];
    NSError *error = [dict objectForKey:@"Error"];
    unsubscribeHandler(error);
}

- (void)onPublish:(DoorDuMQTTPublishHandler)publishHandler error:(NSError *)error {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:publishHandler forKey:@"Block"];
    if (error) {
        [dict setObject:error forKey:@"Error"];
    }
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(onPublishExecute:) object:dict];
    [thread start];
}

- (void)onPublishExecute:(NSDictionary *)dict {
    DoorDuMQTTPublishHandler publishHandler = [dict objectForKey:@"Block"];
    NSError *error = [dict objectForKey:@"Error"];
    publishHandler(error);
}

#pragma mark - DoorDuMQTTTransport interface

- (void)connect {
    if (self.cleanSessionFlag) {
        [self.persistence deleteAllFlowsForClientId:self.clientId];
        [self.subscribeHandlers removeAllObjects];
        [self.unsubscribeHandlers removeAllObjects];
        [self.publishHandlers removeAllObjects];
    }
    [self tell];
    
    self.status = DoorDuMQTTSessionStatusConnecting;
    
    self.decoder = [[DoorDuMQTTDecoder alloc] init];
    self.decoder.runLoop = self.runLoop;
    self.decoder.runLoopMode = self.runLoopMode;
    self.decoder.delegate = self;
    [self.decoder open];
    
    self.transport.delegate = self;
    [self.transport open];
}

- (void)connectWithConnectHandler:(DoorDuMQTTConnectHandler)connectHandler {
    self.connectHandler = connectHandler;
    [self connect];
}

- (void)disconnect {
    self.status = DoorDuMQTTSessionStatusDisconnecting;
    
    (void)[self encode:[DoorDuMQTTMessage disconnectMessage]];
}

- (BOOL)encode:(DoorDuMQTTMessage *)message {
    if (message) {
        NSData *wireFormat = message.wireFormat;
        if (wireFormat) {
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(sending:type:qos:retained:duped:mid:data:)]) {
                    [self.delegate sending:self
                                      type:message.type
                                       qos:message.qos
                                  retained:message.retainFlag
                                     duped:message.dupFlag
                                       mid:message.mid
                                      data:message.data];
                }
            }
            return [self.transport send:wireFormat];
        } else {
            return false;
        }
    } else {
        return false;
    }
}

#pragma mark - DoorDuMQTTTransport delegate
- (void)DoorDuMQTTTransport:(id<DoorDuMQTTTransport>)DoorDuMQTTTransport didReceiveMessage:(NSData *)message {
    
    [self.decoder decodeMessage:message];
    
}

- (void)DoorDuMQTTTransportDidClose:(id<DoorDuMQTTTransport>)DoorDuMQTTTransport {
    
    [self error:DoorDuMQTTSessionEventConnectionClosedByBroker error:nil];
    
}

- (void)DoorDuMQTTTransportDidOpen:(id<DoorDuMQTTTransport>)DoorDuMQTTTransport {
    
    if (!self.connectMessage) {
        (void)[self encode:[DoorDuMQTTMessage connectMessageWithClientId:self.clientId
                                                          userName:self.userName
                                                          password:self.password
                                                         keepAlive:self.keepAliveInterval
                                                      cleanSession:self.cleanSessionFlag
                                                              will:self.willFlag
                                                         willTopic:self.willTopic
                                                           willMsg:self.willMsg
                                                           willQoS:self.willQoS
                                                        willRetain:self.willRetainFlag
                                                     protocolLevel:self.protocolLevel]];
    } else {
        (void)[self encode:self.connectMessage];
    }
}

- (void)DoorDuMQTTTransport:(id<DoorDuMQTTTransport>)DoorDuMQTTTransport didFailWithError:(NSError *)error {
    
    [self connectionError:error];
}
@end
