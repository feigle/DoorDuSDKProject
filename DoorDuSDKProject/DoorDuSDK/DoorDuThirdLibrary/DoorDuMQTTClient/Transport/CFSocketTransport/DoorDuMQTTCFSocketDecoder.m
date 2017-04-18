//
// DoorDuMQTTCFSocketDecoder.m
// DoorDuMQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import "DoorDuMQTTCFSocketDecoder.h"

@interface DoorDuMQTTCFSocketDecoder()

@end

@implementation DoorDuMQTTCFSocketDecoder

- (instancetype)init {
    self = [super init];
    self.state = DoorDuMQTTCFSocketDecoderStateInitializing;
    
    self.stream = nil;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    return self;
}

- (void)open {
    if (self.state == DoorDuMQTTCFSocketDecoderStateInitializing) {
        [self.stream setDelegate:self];
        [self.stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
        [self.stream open];
    }
}

- (void)dealloc {
    [self close];
}

- (void)close {
    [self.stream close];
    [self.stream removeFromRunLoop:self.runLoop forMode:self.runLoopMode];
    [self.stream setDelegate:nil];
}

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    
    if (eventCode & NSStreamEventOpenCompleted) {
        self.state = DoorDuMQTTCFSocketDecoderStateReady;
        [self.delegate decoderDidOpen:self];
    }
    
    if (eventCode &  NSStreamEventHasBytesAvailable) {
        if (self.state == DoorDuMQTTCFSocketDecoderStateInitializing) {
            self.state = DoorDuMQTTCFSocketDecoderStateReady;
        }
        
        if (self.state == DoorDuMQTTCFSocketDecoderStateReady) {
            NSInteger n;
            UInt8 buffer[768];
            
            n = [self.stream read:buffer maxLength:sizeof(buffer)];
            if (n == -1) {
                self.state = DoorDuMQTTCFSocketDecoderStateError;
                [self.delegate decoder:self didFailWithError:nil];
            } else {
                NSData *data = [NSData dataWithBytes:buffer length:n];
                [self.delegate decoder:self didReceiveMessage:data];
            }
        }
    }
    if (eventCode &  NSStreamEventHasSpaceAvailable) {
    }
    
    if (eventCode &  NSStreamEventEndEncountered) {
        self.state = DoorDuMQTTCFSocketDecoderStateInitializing;
        self.error = nil;
        [self.delegate decoderdidClose:self];
    }
    
    if (eventCode &  NSStreamEventErrorOccurred) {
        self.state = DoorDuMQTTCFSocketDecoderStateError;
        self.error = self.stream.streamError;
        [self.delegate decoder:self didFailWithError:self.error];
    }
}

@end
