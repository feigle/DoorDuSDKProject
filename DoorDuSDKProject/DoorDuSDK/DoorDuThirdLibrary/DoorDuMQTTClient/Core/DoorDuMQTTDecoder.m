//
// DoorDuMQTTDecoder.m
// MQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import "DoorDuMQTTDecoder.h"

@interface DoorDuMQTTDecoder()
@property (nonatomic) NSMutableArray<NSInputStream *> *streams;
@end

@implementation DoorDuMQTTDecoder

- (instancetype)init {
    self = [super init];
    self.state = DoorDuMQTTDecoderStateInitializing;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    self.streams = [NSMutableArray arrayWithCapacity:5];
    return self;
}

- (void)dealloc {
    [self close];
}

- (void)decodeMessage:(NSData *)data {
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    [self openStream:stream];
}

- (void)openStream:(NSInputStream*)stream {
    [self.streams addObject:stream];
    [stream setDelegate:self];
    if (self.streams.count == 1) {
        [stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
        [stream open];
    }
}

- (void)open {
    self.state = DoorDuMQTTDecoderStateDecodingHeader;
}

- (void)close {
    if (self.streams) {
        for (NSInputStream *stream in self.streams) {
            [stream close];
            [stream removeFromRunLoop:self.runLoop forMode:self.runLoopMode];
            [stream setDelegate:nil];
        }
        [self.streams removeAllObjects];
    }
}

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    NSInputStream *stream = (NSInputStream *)sender;
    
    if (eventCode & NSStreamEventOpenCompleted) {
    }
    
    if (eventCode & NSStreamEventHasBytesAvailable) {
        
        if (self.state == DoorDuMQTTDecoderStateDecodingHeader) {
            UInt8 buffer;
            NSInteger n = [stream read:&buffer maxLength:1];
            if (n == -1) {
                self.state = DoorDuMQTTDecoderStateConnectionError;
                [self.delegate decoder:self handleEvent:DoorDuMQTTDecoderEventConnectionError error:stream.streamError];
            } else if (n == 1) {
                self.length = 0;
                self.lengthMultiplier = 1;
                self.state = DoorDuMQTTDecoderStateDecodingLength;
                self.dataBuffer = [[NSMutableData alloc] init];
                [self.dataBuffer appendBytes:&buffer length:1];
                self.offset = 1;
            }
        }
        while (self.state == DoorDuMQTTDecoderStateDecodingLength) {
            // TODO: check max packet length(prevent evil server response)
            UInt8 digit;
            NSInteger n = [stream read:&digit maxLength:1];
            if (n == -1) {
                self.state = DoorDuMQTTDecoderStateConnectionError;
                [self.delegate decoder:self handleEvent:DoorDuMQTTDecoderEventConnectionError error:stream.streamError];
                break;
            } else if (n == 0) {
                break;
            }
            [self.dataBuffer appendBytes:&digit length:1];
            self.offset++;
            self.length += ((digit & 0x7f) * self.lengthMultiplier);
            if ((digit & 0x80) == 0x00) {
                self.state = DoorDuMQTTDecoderStateDecodingData;
            } else {
                self.lengthMultiplier *= 128;
            }
        }

        if (self.state == DoorDuMQTTDecoderStateDecodingData) {
            if (self.length > 0) {
                NSInteger n, toRead;
                UInt8 buffer[768];
                toRead = self.length + self.offset - self.dataBuffer.length;
                if (toRead > sizeof buffer) {
                    toRead = sizeof buffer;
                }
                n = [stream read:buffer maxLength:toRead];
                if (n == -1) {
                    self.state = DoorDuMQTTDecoderStateConnectionError;
                    [self.delegate decoder:self handleEvent:DoorDuMQTTDecoderEventConnectionError error:stream.streamError];
                } else {
                    [self.dataBuffer appendBytes:buffer length:n];
                }
            }
            if (self.dataBuffer.length == self.length + self.offset) {
                [self.delegate decoder:self didReceiveMessage:self.dataBuffer];
                self.dataBuffer = nil;
                self.state = DoorDuMQTTDecoderStateDecodingHeader;
            }
        }
    }
    
    if (eventCode & NSStreamEventHasSpaceAvailable) {
    }
    
    if (eventCode & NSStreamEventEndEncountered) {
        
        if (self.streams) {
            [stream setDelegate:nil];
            [stream close];
            [self.streams removeObject:stream];
            if (self.streams.count) {
                NSInputStream *stream = [self.streams objectAtIndex:0];
                [stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
                [stream open];
            }
        }
    }
    
    if (eventCode & NSStreamEventErrorOccurred) {
        
        self.state = DoorDuMQTTDecoderStateConnectionError;
        NSError *error = [stream streamError];
        if (self.streams) {
            [self.streams removeObject:stream];
            if (self.streams.count) {
                NSInputStream *stream = [self.streams objectAtIndex:0];
                [stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
                [stream open];
            }
        }
        [self.delegate decoder:self handleEvent:DoorDuMQTTDecoderEventConnectionError error:error];
    }
}

@end
