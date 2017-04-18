//
//  DoorDuMQTTInMemoryPersistence.m
//  DoorDuMQTTClient
//
//  Created by Christoph Krey on 22.03.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import "DoorDuMQTTInMemoryPersistence.h"

@implementation DoorDuMQTTInMemoryFlow
@synthesize clientId;
@synthesize incomingFlag;
@synthesize retainedFlag;
@synthesize commandType;
@synthesize qosLevel;
@synthesize messageId;
@synthesize topic;
@synthesize data;
@synthesize deadline;

@end

@interface DoorDuMQTTInMemoryPersistence()
@end

static NSMutableDictionary *clientIds;

@implementation DoorDuMQTTInMemoryPersistence
@synthesize maxSize;
@synthesize persistent;
@synthesize maxMessages;
@synthesize maxWindowSize;

- (DoorDuMQTTInMemoryPersistence *)init {
    self = [super init];
    self.maxMessages = DoorDuMQTT_MAX_MESSAGES;
    self.maxWindowSize = DoorDuMQTT_MAX_WINDOW_SIZE;
    @synchronized(clientIds) {
        if (!clientIds) {
            clientIds = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (NSUInteger)windowSize:(NSString *)clientId {
    NSUInteger windowSize = 0;
    NSArray *flows = [self allFlowsforClientId:clientId
                                  incomingFlag:NO];
    for (DoorDuMQTTInMemoryFlow *flow in flows) {
        if ([flow.commandType intValue] != DoorDuMQTT_None) {
            windowSize++;
        }
    }
    return windowSize;
}

- (DoorDuMQTTInMemoryFlow *)storeMessageForClientId:(NSString *)clientId
                                        topic:(NSString *)topic
                                         data:(NSData *)data
                                   retainFlag:(BOOL)retainFlag
                                          qos:(DoorDuMQTTQosLevel)qos
                                        msgId:(UInt16)msgId
                                 incomingFlag:(BOOL)incomingFlag
                                  commandType:(UInt8)commandType
                                     deadline:(NSDate *)deadline {
    @synchronized(clientIds) {
        
        if (([self allFlowsforClientId:clientId incomingFlag:incomingFlag].count <= self.maxMessages)) {
            DoorDuMQTTInMemoryFlow *flow = (DoorDuMQTTInMemoryFlow *)[self createFlowforClientId:clientId
                                                                        incomingFlag:incomingFlag
                                                                           messageId:msgId];
            flow.topic = topic;
            flow.data = data;
            flow.retainedFlag = [NSNumber numberWithBool:retainFlag];
            flow.qosLevel = [NSNumber numberWithUnsignedInteger:qos];
            flow.commandType = [NSNumber numberWithUnsignedInteger:commandType];
            flow.deadline = deadline;
            return flow;
        } else {
            return nil;
        }
    }
}

- (void)deleteFlow:(DoorDuMQTTInMemoryFlow *)flow {
    @synchronized(clientIds) {
        
        NSMutableDictionary *clientIdFlows = [clientIds objectForKey:flow.clientId];
        if (clientIdFlows) {
            NSMutableDictionary *clientIdDirectedFlow = [clientIdFlows objectForKey:flow.incomingFlag];
            if (clientIdDirectedFlow) {
                [clientIdDirectedFlow removeObjectForKey:flow.messageId];
            }
        }
    }
}

- (void)deleteAllFlowsForClientId:(NSString *)clientId {
    @synchronized(clientIds) {
        
        [clientIds removeObjectForKey:clientId];
    }
}

- (void)sync {
    //
}

- (NSArray *)allFlowsforClientId:(NSString *)clientId
                    incomingFlag:(BOOL)incomingFlag {
    @synchronized(clientIds) {
        
        NSArray *flows = nil;
        NSMutableDictionary *clientIdFlows = [clientIds objectForKey:clientId];
        if (clientIdFlows) {
            NSMutableDictionary *clientIdDirectedFlow = [clientIdFlows objectForKey:[NSNumber numberWithBool:incomingFlag]];
            if (clientIdDirectedFlow) {
                flows = clientIdDirectedFlow.allValues;
            }
        }
        return flows;
    }
}

- (DoorDuMQTTInMemoryFlow *)flowforClientId:(NSString *)clientId
                         incomingFlag:(BOOL)incomingFlag
                            messageId:(UInt16)messageId {
    @synchronized(clientIds) {
        
        DoorDuMQTTInMemoryFlow *flow = nil;
        
        NSMutableDictionary *clientIdFlows = [clientIds objectForKey:clientId];
        if (clientIdFlows) {
            NSMutableDictionary *clientIdDirectedFlow = [clientIdFlows objectForKey:[NSNumber numberWithBool:incomingFlag]];
            if (clientIdDirectedFlow) {
                flow = [clientIdDirectedFlow objectForKey:[NSNumber numberWithUnsignedInteger:messageId]];
            }
        }
        
        return flow;
    }
}

- (DoorDuMQTTInMemoryFlow *)createFlowforClientId:(NSString *)clientId
                               incomingFlag:(BOOL)incomingFlag
                                  messageId:(UInt16)messageId {
    @synchronized(clientIds) {
        NSMutableDictionary *clientIdFlows = [clientIds objectForKey:clientId];
        if (!clientIdFlows) {
            clientIdFlows = [[NSMutableDictionary alloc] init];
            [clientIds setObject:clientIdFlows forKey:clientId];
        }
        
        NSMutableDictionary *clientIdDirectedFlow = [clientIdFlows objectForKey:[NSNumber numberWithBool:incomingFlag]];
        if (!clientIdDirectedFlow) {
            clientIdDirectedFlow = [[NSMutableDictionary alloc] init];
            [clientIdFlows setObject:clientIdDirectedFlow forKey:[NSNumber numberWithBool:incomingFlag]];
        }
        
        DoorDuMQTTInMemoryFlow *flow = [[DoorDuMQTTInMemoryFlow alloc] init];
        flow.clientId = clientId;
        flow.incomingFlag = [NSNumber numberWithBool:incomingFlag];
        flow.messageId = [NSNumber numberWithUnsignedInteger:messageId];
        
        [clientIdDirectedFlow setObject:flow forKey:[NSNumber numberWithUnsignedInteger:messageId]];
        
        return flow;
    }
}

@end
