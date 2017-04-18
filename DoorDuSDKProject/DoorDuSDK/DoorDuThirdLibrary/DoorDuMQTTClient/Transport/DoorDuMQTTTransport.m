//
//  DoorDuMQTTTransport.m
//  DoorDuMQTTClient
//
//  Created by Christoph Krey on 05.01.16.
//  Copyright © 2016 Christoph Krey. All rights reserved.
//

#import "DoorDuMQTTTransport.h"

@implementation DoorDuMQTTTransport
@synthesize state;
@synthesize runLoop;
@synthesize runLoopMode;
@synthesize delegate;

- (instancetype)init {
    self = [super init];
    self.state = DoorDuMQTTTransportCreated;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    return self;
}

- (void)open {
}

- (void)close {
}

- (BOOL)send:(NSData *)data {
    return FALSE;
}

@end
