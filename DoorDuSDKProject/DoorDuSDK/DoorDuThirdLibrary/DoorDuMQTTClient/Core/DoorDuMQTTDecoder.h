//
// DoorDuMQTTDecoder.h
// MQTTClient.framework
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
#import "DoorDuMQTTMessage.h"

typedef enum {
    DoorDuMQTTDecoderEventProtocolError,
    DoorDuMQTTDecoderEventConnectionClosed,
    DoorDuMQTTDecoderEventConnectionError
} DoorDuMQTTDecoderEvent;

typedef enum {
    DoorDuMQTTDecoderStateInitializing,
    DoorDuMQTTDecoderStateDecodingHeader,
    DoorDuMQTTDecoderStateDecodingLength,
    DoorDuMQTTDecoderStateDecodingData,
    DoorDuMQTTDecoderStateConnectionClosed,
    DoorDuMQTTDecoderStateConnectionError,
    DoorDuMQTTDecoderStateProtocolError
} DoorDuMQTTDecoderState;

@class DoorDuMQTTDecoder;

@protocol DoorDuMQTTDecoderDelegate <NSObject>

- (void)decoder:(DoorDuMQTTDecoder *)sender didReceiveMessage:(NSData *)data;
- (void)decoder:(DoorDuMQTTDecoder *)sender handleEvent:(DoorDuMQTTDecoderEvent)eventCode error:(NSError *)error;

@end


@interface DoorDuMQTTDecoder : NSObject <NSStreamDelegate>
@property (nonatomic)    DoorDuMQTTDecoderState       state;
@property (strong, nonatomic)    NSRunLoop*      runLoop;
@property (strong, nonatomic)    NSString*       runLoopMode;
@property (nonatomic)    UInt32          length;
@property (nonatomic)    UInt32          lengthMultiplier;
@property (nonatomic)    int          offset;
@property (strong, nonatomic)    NSMutableData*  dataBuffer;

@property (weak, nonatomic ) id<DoorDuMQTTDecoderDelegate> delegate;

- (void)open;
- (void)close;
- (void)decodeMessage:(NSData *)data;
@end


