//
// DoorDuMQTTCFSocketEncoder.h
// DoorDuMQTTClient.framework
//
// Copyright © 2013-2016, Christoph Krey
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DoorDuMQTTCFSocketEncoderState) {
    DoorDuMQTTCFSocketEncoderStateInitializing,
    DoorDuMQTTCFSocketEncoderStateReady,
    DoorDuMQTTCFSocketEncoderStateError
};

@class DoorDuMQTTCFSocketEncoder;

@protocol DoorDuMQTTCFSocketEncoderDelegate <NSObject>
- (void)encoderDidOpen:(DoorDuMQTTCFSocketEncoder *)sender;
- (void)encoder:(DoorDuMQTTCFSocketEncoder *)sender didFailWithError:(NSError *)error;
- (void)encoderdidClose:(DoorDuMQTTCFSocketEncoder *)sender;

@end

@interface DoorDuMQTTCFSocketEncoder : NSObject <NSStreamDelegate>
@property (nonatomic) DoorDuMQTTCFSocketEncoderState state;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSOutputStream *stream;
@property (strong, nonatomic) NSRunLoop *runLoop;
@property (strong, nonatomic) NSString *runLoopMode;
@property (weak, nonatomic ) id<DoorDuMQTTCFSocketEncoderDelegate> delegate;

- (void)open;
- (void)close;
- (BOOL)send:(NSData *)data;

@end

