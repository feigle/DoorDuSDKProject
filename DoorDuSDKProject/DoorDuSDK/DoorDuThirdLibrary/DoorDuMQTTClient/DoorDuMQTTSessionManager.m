//
//  DoorDuMQTTSessionManager.m
//  DoorDuMQTTClient
//
//  Created by Christoph Krey on 09.07.14.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "DoorDuMQTTSessionManager.h"

@interface DoorDuMQTTSessionManager()
@property (nonatomic, readwrite) DoorDuMQTTSessionManagerState state;
@property (nonatomic, readwrite) NSError *lastErrorCode;

@property (strong, nonatomic) NSTimer *reconnectTimer;
@property (nonatomic) double reconnectTime;
@property (nonatomic) BOOL reconnectFlag;

@property (strong, nonatomic) DoorDuMQTTSession *session;

@property (strong, nonatomic) NSString *host;
@property (nonatomic) UInt32 port;
@property (nonatomic) BOOL tls;
@property (nonatomic) NSInteger keepalive;
@property (nonatomic) BOOL clean;
@property (nonatomic) BOOL auth;
@property (nonatomic) BOOL will;
@property (strong, nonatomic) NSString *user;
@property (strong, nonatomic) NSString *pass;
@property (strong, nonatomic) NSString *willTopic;
@property (strong, nonatomic) NSData *willMsg;
@property (nonatomic) NSInteger willQos;
@property (nonatomic) BOOL willRetainFlag;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) DoorDuMQTTSSLSecurityPolicy *securityPolicy;
@property (strong, nonatomic) NSArray *certificates;
@property (nonatomic) DoorDuMQTTProtocolVersion protocolLevel;

@property (strong, nonatomic) NSTimer *disconnectTimer;
@property (strong, nonatomic) NSTimer *activityTimer;
#if TARGET_OS_IPHONE == 1
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
#endif

@property (nonatomic) BOOL persistent;
@property (nonatomic) NSUInteger maxWindowSize;
@property (nonatomic) NSUInteger maxSize;
@property (nonatomic) NSUInteger maxMessages;

@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> *internalSubscriptions;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> *effectiveSubscriptions;

@end

#define RECONNECT_TIMER 1.0
#define RECONNECT_TIMER_MAX 64.0
#define BACKGROUND_DISCONNECT_AFTER 8.0

@implementation DoorDuMQTTSessionManager

- (void)dealloc {
#if TARGET_OS_IPHONE == 1
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
#endif
}

- (id)init {
    self = [super init];
    
    self.state = DoorDuMQTTSessionManagerStateStarting;
    self.internalSubscriptions = [[NSMutableDictionary alloc] init];
    self.effectiveSubscriptions = [[NSMutableDictionary alloc] init];
    
    //Use the default value
    self.persistent = DoorDuMQTT_PERSISTENT;
    self.maxSize = DoorDuMQTT_MAX_SIZE;
    self.maxMessages = DoorDuMQTT_MAX_MESSAGES;
    self.maxWindowSize = DoorDuMQTT_MAX_WINDOW_SIZE;
    
    self.persistent = DoorDuMQTT_PERSISTENT;
    self.maxWindowSize = DoorDuMQTT_MAX_WINDOW_SIZE;
    self.maxSize = DoorDuMQTT_MAX_SIZE;
    self.maxMessages = DoorDuMQTT_MAX_MESSAGES;
    
#if TARGET_OS_IPHONE == 1
    self.backgroundTask = UIBackgroundTaskInvalid;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self
                      selector:@selector(appWillResignActive)
                          name:UIApplicationWillResignActiveNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(appDidEnterBackground)
                          name:UIApplicationDidEnterBackgroundNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(appDidBecomeActive)
                          name:UIApplicationDidBecomeActiveNotification
                        object:nil];
#endif
    return self;
}

- (DoorDuMQTTSessionManager *)initWithPersistence:(BOOL)persistent
                                    maxWindowSize:(NSUInteger)maxWindowSize
                                      maxMessages:(NSUInteger)maxMessages
                                          maxSize:(NSUInteger)maxSize {
    self = [self init];
    self.persistent = persistent;
    self.maxWindowSize = maxWindowSize;
    self.maxSize = maxSize;
    self.maxMessages = maxMessages;
    return self;
}

#if TARGET_OS_IPHONE == 1
- (void)appWillResignActive {
    [self disconnect];
}

- (void)appDidEnterBackground {
    __weak DoorDuMQTTSessionManager *weakSelf = self;
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        __strong DoorDuMQTTSessionManager *strongSelf = weakSelf;
        if (strongSelf.backgroundTask) {
            [[UIApplication sharedApplication] endBackgroundTask:strongSelf.backgroundTask];
            strongSelf.backgroundTask = UIBackgroundTaskInvalid;
        }
    }];
}

- (void)appDidBecomeActive {
    [self connectToLast];
}
#endif

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
        willTopic:(NSString *)willTopic
             will:(NSData *)will
          willQos:(DoorDuMQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId {
    [self connectTo:host
               port:port
                tls:tls
          keepalive:keepalive
              clean:clean
               auth:auth
               user:user
               pass:pass
               will:YES
          willTopic:willTopic
            willMsg:will
            willQos:willQos
     willRetainFlag:willRetainFlag
       withClientId:clientId];
}

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
             will:(BOOL)will
        willTopic:(NSString *)willTopic
          willMsg:(NSData *)willMsg
          willQos:(DoorDuMQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId {
    [self connectTo:host
               port:port
                tls:tls
          keepalive:keepalive
              clean:clean
               auth:auth
               user:user
               pass:pass
               will:will
          willTopic:willTopic
            willMsg:willMsg
            willQos:willQos
     willRetainFlag:willRetainFlag
       withClientId:clientId
     securityPolicy:nil
       certificates:nil];
}

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
             will:(BOOL)will
        willTopic:(NSString *)willTopic
          willMsg:(NSData *)willMsg
          willQos:(DoorDuMQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId
   securityPolicy:(DoorDuMQTTSSLSecurityPolicy *)securityPolicy
     certificates:(NSArray *)certificates {
    [self connectTo:host
               port:port
                tls:tls
          keepalive:keepalive
              clean:clean
               auth:auth
               user:user
               pass:pass
               will:will
          willTopic:willTopic
            willMsg:willMsg
            willQos:willQos
     willRetainFlag:willRetainFlag
       withClientId:clientId
     securityPolicy:securityPolicy
       certificates:certificates
      protocolLevel:DoorDuMQTTProtocolVersion311]; // use this level as default, keeps it backwards compatible
}

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
             will:(BOOL)will
        willTopic:(NSString *)willTopic
          willMsg:(NSData *)willMsg
          willQos:(DoorDuMQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId
   securityPolicy:(DoorDuMQTTSSLSecurityPolicy *)securityPolicy
     certificates:(NSArray *)certificates
    protocolLevel:(DoorDuMQTTProtocolVersion)protocolLevel {
    BOOL shouldReconnect = self.session != nil;
    if (!self.session ||
        ![host isEqualToString:self.host] ||
        port != self.port ||
        tls != self.tls ||
        keepalive != self.keepalive ||
        clean != self.clean ||
        auth != self.auth ||
        ![user isEqualToString:self.user] ||
        ![pass isEqualToString:self.pass] ||
        ![willTopic isEqualToString:self.willTopic] ||
        ![willMsg isEqualToData:self.willMsg] ||
        willQos != self.willQos ||
        willRetainFlag != self.willRetainFlag ||
        ![clientId isEqualToString:self.clientId] ||
        securityPolicy != self.securityPolicy ||
        certificates != self.certificates) {
        self.host = host;
        self.port = (int)port;
        self.tls = tls;
        self.keepalive = keepalive;
        self.clean = clean;
        self.auth = auth;
        self.user = user;
        self.pass = pass;
        self.will = will;
        self.willTopic = willTopic;
        self.willMsg = willMsg;
        self.willQos = willQos;
        self.willRetainFlag = willRetainFlag;
        self.clientId = clientId;
        self.securityPolicy = securityPolicy;
        self.certificates = certificates;
        self.protocolLevel = protocolLevel;
        
        self.session = [[DoorDuMQTTSession alloc] initWithClientId:clientId
                                                          userName:auth ? user : nil
                                                          password:auth ? pass : nil
                                                         keepAlive:keepalive
                                                      cleanSession:clean
                                                              will:will
                                                         willTopic:willTopic
                                                           willMsg:willMsg
                                                           willQoS:willQos
                                                    willRetainFlag:willRetainFlag
                                                     protocolLevel:protocolLevel
                                                           runLoop:[NSRunLoop currentRunLoop]
                                                           forMode:NSDefaultRunLoopMode
                                                    securityPolicy:securityPolicy
                                                      certificates:certificates];
        
        self.session.delegate = self;
        self.reconnectTime = RECONNECT_TIMER;
        self.reconnectFlag = FALSE;
    }
    if(shouldReconnect){
        [self disconnect];
        [self reconnect];
    }else{
        [self connectToInternal];
    }
}

- (UInt16)sendData:(NSData *)data topic:(NSString *)topic qos:(DoorDuMQTTQosLevel)qos retain:(BOOL)retainFlag
{
    if (self.state != DoorDuMQTTSessionManagerStateConnected) {
        [self connectToLast];
    }
    UInt16 msgId = [self.session publishData:data
                                     onTopic:topic
                                      retain:retainFlag
                                         qos:qos];
    return msgId;
}

- (void)disconnect
{
    self.state = DoorDuMQTTSessionManagerStateClosing;
    [self.session close];
    
    if (self.reconnectTimer) {
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
    }
}

#pragma mark - DoorDuMQTT Callback methods

- (void)handleEvent:(DoorDuMQTTSession *)session event:(DoorDuMQTTSessionEvent)eventCode error:(NSError *)error
{
#ifdef DEBUG
    __unused const NSDictionary *events = @{
                                            @(DoorDuMQTTSessionEventConnected): @"connected",
                                            @(DoorDuMQTTSessionEventConnectionRefused): @"connection refused",
                                            @(DoorDuMQTTSessionEventConnectionClosed): @"connection closed",
                                            @(DoorDuMQTTSessionEventConnectionError): @"connection error",
                                            @(DoorDuMQTTSessionEventProtocolError): @"protocoll error",
                                            @(DoorDuMQTTSessionEventConnectionClosedByBroker): @"connection closed by broker"
                                            };
#endif
    [self.reconnectTimer invalidate];
    switch (eventCode) {
        case DoorDuMQTTSessionEventConnected:
        {
            self.lastErrorCode = nil;
            self.state = DoorDuMQTTSessionManagerStateConnected;
            break;
        }
        case DoorDuMQTTSessionEventConnectionClosed:
        case DoorDuMQTTSessionEventConnectionClosedByBroker:
            self.state = DoorDuMQTTSessionManagerStateClosed;
#if TARGET_OS_IPHONE == 1
            if (self.backgroundTask) {
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                self.backgroundTask = UIBackgroundTaskInvalid;
            }
#endif
            self.state = DoorDuMQTTSessionManagerStateStarting;
            break;
        case DoorDuMQTTSessionEventProtocolError:
        case DoorDuMQTTSessionEventConnectionRefused:
        case DoorDuMQTTSessionEventConnectionError:
        {
            self.reconnectTimer = [NSTimer timerWithTimeInterval:self.reconnectTime
                                                          target:self
                                                        selector:@selector(reconnect)
                                                        userInfo:Nil repeats:FALSE];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            [runLoop addTimer:self.reconnectTimer
                      forMode:NSDefaultRunLoopMode];
            
            self.state = DoorDuMQTTSessionManagerStateError;
            self.lastErrorCode = error;
            break;
        }
        default:
            break;
    }
}

- (void)newMessage:(DoorDuMQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(DoorDuMQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    if (self.delegate) {
        [self.delegate handleMessage:data onTopic:topic retained:retained];
    }
}

- (void)connected:(DoorDuMQTTSession *)session sessionPresent:(BOOL)sessionPresent {
    if (self.clean || !self.reconnectFlag || !sessionPresent) {
        NSDictionary *subscriptions = [self.internalSubscriptions copy];
        @synchronized(self.effectiveSubscriptions) {
            self.effectiveSubscriptions = [[NSMutableDictionary alloc] init];
        }
        if (subscriptions.count) {
            [self.session subscribeToTopics:subscriptions subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                if (!error) {
                    NSArray<NSString *> *allTopics = subscriptions.allKeys;
                    for (int i = 0; i < allTopics.count; i++) {
                        NSString *topic = allTopics[i];
                        NSNumber *gQos = gQoss[i];
                        @synchronized(self.effectiveSubscriptions) {
                            NSMutableDictionary *newEffectiveSubscriptions = [self.subscriptions mutableCopy];
                            [newEffectiveSubscriptions setObject:gQos forKey:topic];
                            self.effectiveSubscriptions = newEffectiveSubscriptions;
                        }
                    }
                }
            }];
            
        }
        self.reconnectFlag = TRUE;
    }
}

- (void)messageDelivered:(DoorDuMQTTSession *)session msgID:(UInt16)msgID {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(messageDelivered:)]) {
            [self.delegate messageDelivered:msgID];
        }
    }
}


- (void)connectToInternal
{
    if (self.state == DoorDuMQTTSessionManagerStateStarting
        && self.session != nil) {
        self.state = DoorDuMQTTSessionManagerStateConnecting;
        [self.session connectToHost:self.host
                               port:self.port
                           usingSSL:self.tls];
    }
}

- (void)reconnect
{
    self.reconnectTimer = nil;
    self.state = DoorDuMQTTSessionManagerStateStarting;
    
    if (self.reconnectTime < RECONNECT_TIMER_MAX) {
        self.reconnectTime *= 2;
    }
    [self connectToInternal];
}

- (void)connectToLast
{
    self.reconnectTime = RECONNECT_TIMER;
    
    [self connectToInternal];
}

- (NSDictionary<NSString *, NSNumber *> *)subscriptions {
    return self.internalSubscriptions;
}

- (void)setSubscriptions:(NSDictionary<NSString *, NSNumber *> *)newSubscriptions
{
    if (self.state == DoorDuMQTTSessionManagerStateConnected) {
        NSDictionary *currentSubscriptions = [self.effectiveSubscriptions copy];
        
        for (NSString *topicFilter in currentSubscriptions) {
            if (![newSubscriptions objectForKey:topicFilter]) {
                [self.session unsubscribeTopic:topicFilter unsubscribeHandler:^(NSError *error) {
                    if (!error) {
                        @synchronized(self.effectiveSubscriptions) {
                            NSMutableDictionary *newEffectiveSubscriptions = [self.subscriptions mutableCopy];
                            [newEffectiveSubscriptions removeObjectForKey:topicFilter];
                            self.effectiveSubscriptions = newEffectiveSubscriptions;
                        }
                    }
                }];
            }
        }
        
        for (NSString *topicFilter in newSubscriptions) {
            if (![currentSubscriptions objectForKey:topicFilter]) {
                NSNumber *number = newSubscriptions[topicFilter];
                DoorDuMQTTQosLevel qos = [number unsignedIntValue];
                [self.session subscribeToTopic:topicFilter atLevel:qos subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                    if (!error) {
                        NSNumber *gQos = gQoss[0];
                        @synchronized(self.effectiveSubscriptions) {
                            NSMutableDictionary *newEffectiveSubscriptions = [self.subscriptions mutableCopy];
                            [newEffectiveSubscriptions setObject:gQos forKey:topicFilter];
                            self.effectiveSubscriptions = newEffectiveSubscriptions;
                        }
                    }
                }];
            }
        }
    }
    self.internalSubscriptions = newSubscriptions;
}

@end
