//
// DoorDuMQTTSessionSynchron.m
// DoorDuMQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

/**
 Synchronous API
 
 @author Christoph Krey krey.christoph@gmail.com
 @see http://DoorDuMQTT.org
 */

#import "DoorDuMQTTSession.h"
#import "DoorDuMQTTSessionLegacy.h"
#import "DoorDuMQTTSessionSynchron.h"

@interface DoorDuMQTTSession()
@property (nonatomic) BOOL synchronPub;
@property (nonatomic) UInt16 synchronPubMid;
@property (nonatomic) BOOL synchronUnsub;
@property (nonatomic) UInt16 synchronUnsubMid;
@property (nonatomic) BOOL synchronSub;
@property (nonatomic) UInt16 synchronSubMid;
@property (nonatomic) BOOL synchronConnect;
@property (nonatomic) BOOL synchronDisconnect;

@end

@implementation DoorDuMQTTSession(Synchron)

/** Synchron connect
 *
 */
- (BOOL)connectAndWaitTimeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronConnect = TRUE;
    
    [self connect];
    
    while (self.synchronConnect && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    return (self.status == DoorDuMQTTSessionStatusConnected);
}

/**
 * @deprecated
 */
 - (BOOL)connectAndWaitToHost:(NSString*)host port:(UInt32)port usingSSL:(BOOL)usingSSL {
    return [self connectAndWaitToHost:host port:port usingSSL:usingSSL timeout:0];
}

/**
 * @deprecated
 */
- (BOOL)connectAndWaitToHost:(NSString*)host port:(UInt32)port usingSSL:(BOOL)usingSSL timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronConnect = TRUE;
    
    [self connectToHost:host port:port usingSSL:usingSSL];
    
    while (self.synchronConnect && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    return (self.status == DoorDuMQTTSessionStatusConnected);
}

- (BOOL)subscribeAndWaitToTopic:(NSString *)topic atLevel:(DoorDuMQTTQosLevel)qosLevel {
    return [self subscribeAndWaitToTopic:topic atLevel:qosLevel timeout:0];
}

- (BOOL)subscribeAndWaitToTopic:(NSString *)topic atLevel:(DoorDuMQTTQosLevel)qosLevel timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronSub = TRUE;
    UInt16 mid = [self subscribeToTopic:topic atLevel:qosLevel];
    self.synchronSubMid = mid;
    
    while (self.synchronSub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    if (self.synchronSub || self.synchronSubMid != mid) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (BOOL)subscribeAndWaitToTopics:(NSDictionary<NSString *, NSNumber *> *)topics {
    return [self subscribeAndWaitToTopics:topics timeout:0];
}

- (BOOL)subscribeAndWaitToTopics:(NSDictionary<NSString *, NSNumber *> *)topics timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronSub = TRUE;
    UInt16 mid = [self subscribeToTopics:topics];
    self.synchronSubMid = mid;
    
    while (self.synchronSub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    if (self.synchronSub || self.synchronSubMid != mid) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (BOOL)unsubscribeAndWaitTopic:(NSString *)theTopic {
    return [self unsubscribeAndWaitTopic:theTopic timeout:0];
}

- (BOOL)unsubscribeAndWaitTopic:(NSString *)theTopic timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];

    self.synchronUnsub = TRUE;
    UInt16 mid = [self unsubscribeTopic:theTopic];
    self.synchronUnsubMid = mid;
    
    while (self.synchronUnsub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    if (self.synchronUnsub || self.synchronUnsubMid != mid) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (BOOL)unsubscribeAndWaitTopics:(NSArray<NSString *> *)topics {
    return [self unsubscribeAndWaitTopics:topics timeout:0];
}

- (BOOL)unsubscribeAndWaitTopics:(NSArray<NSString *> *)topics timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronUnsub = TRUE;
    UInt16 mid = [self unsubscribeTopics:topics];
    self.synchronUnsubMid = mid;
    
    while (self.synchronUnsub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    if (self.synchronUnsub || self.synchronUnsubMid != mid) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (BOOL)publishAndWaitData:(NSData*)data
                   onTopic:(NSString*)topic
                    retain:(BOOL)retainFlag
                       qos:(DoorDuMQTTQosLevel)qos {
    return [self publishAndWaitData:data onTopic:topic retain:retainFlag qos:qos timeout:0];
}

- (BOOL)publishAndWaitData:(NSData*)data
                   onTopic:(NSString*)topic
                    retain:(BOOL)retainFlag
                       qos:(DoorDuMQTTQosLevel)qos
                   timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];

    if (qos != DoorDuMQTTQosLevelAtMostOnce) {
        self.synchronPub = TRUE;
    }
    
    UInt16 mid = self.synchronPubMid = [self publishData:data onTopic:topic retain:retainFlag qos:qos];
    if (qos == DoorDuMQTTQosLevelAtMostOnce) {
        return TRUE;
    } else {        
        while (self.synchronPub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        
        if (self.synchronPub || self.synchronPubMid != mid) {
            return FALSE;
        } else {
            return TRUE;
        }
    }
}

- (void)closeAndWait {
    [self closeAndWait:0];
}

- (void)closeAndWait:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronDisconnect = TRUE;
    [self close];
    
    while (self.synchronDisconnect && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
}

@end
