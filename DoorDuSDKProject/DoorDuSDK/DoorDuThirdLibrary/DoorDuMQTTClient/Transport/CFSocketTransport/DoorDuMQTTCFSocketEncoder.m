//
// DoorDuMQTTCFSocketEncoder.m
// DoorDuMQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import "DoorDuMQTTCFSocketEncoder.h"

@interface DoorDuMQTTCFSocketEncoder()
@property (strong, nonatomic) NSMutableData *buffer;

@end

@implementation DoorDuMQTTCFSocketEncoder

- (instancetype)init {
    self = [super init];
    self.state = DoorDuMQTTCFSocketEncoderStateInitializing;
    self.buffer = [[NSMutableData alloc] init];
    
    self.stream = nil;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    
    return self;
}

- (void)dealloc {
    [self close];
}

- (void)open {
    [self.stream setDelegate:self];
    [self.stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
    [self.stream open];
}

- (void)close {
    [self.stream close];
    [self.stream removeFromRunLoop:self.runLoop forMode:self.runLoopMode];
    [self.stream setDelegate:nil];
}

- (void)setState:(DoorDuMQTTCFSocketEncoderState)state {
    _state = state;
}

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    
    if (eventCode & NSStreamEventOpenCompleted) {

    }
    if (eventCode & NSStreamEventHasBytesAvailable) {
    }
    
    if (eventCode & NSStreamEventHasSpaceAvailable) {
        if (self.state == DoorDuMQTTCFSocketEncoderStateInitializing) {
            self.state = DoorDuMQTTCFSocketEncoderStateReady;
            [self.delegate encoderDidOpen:self];
        }
        
        if (self.state == DoorDuMQTTCFSocketEncoderStateReady) {
            if (self.buffer.length) {
                [self send:nil];
            }
        }
    }
    
    if (eventCode &  NSStreamEventEndEncountered) {
        self.state = DoorDuMQTTCFSocketEncoderStateInitializing;
        self.error = nil;
        [self.delegate encoderdidClose:self];
    }
    
    if (eventCode &  NSStreamEventErrorOccurred) {
        self.state = DoorDuMQTTCFSocketEncoderStateError;
        self.error = self.stream.streamError;
        [self.delegate encoder:self didFailWithError:self.error];
    }
}

- (BOOL)send:(NSData *)data {
    @synchronized(self) {
        if (self.state != DoorDuMQTTCFSocketEncoderStateReady) {
            return FALSE;
        }
        
        if (data) {
            [self.buffer appendData:data];
        }
        
        if (self.buffer.length) {
            
            NSInteger n = [self.stream write:self.buffer.bytes maxLength:self.buffer.length];
            
            if (n == -1) {
                self.state = DoorDuMQTTCFSocketEncoderStateError;
                self.error = self.stream.streamError;
                return FALSE;
            } else {
                if (n < self.buffer.length) {
                }
                [self.buffer replaceBytesInRange:NSMakeRange(0, n) withBytes:NULL length:0];
            }
        }
        return TRUE;
    }
}

@end
