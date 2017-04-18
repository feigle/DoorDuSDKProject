//
// DoorDuMQTTCFSocketDecoder.h
// DoorDuMQTTClient.framework
// 
// Copyright © 2013-2016, Christoph Krey
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DoorDuMQTTCFSocketDecoderState) {
    DoorDuMQTTCFSocketDecoderStateInitializing,
    DoorDuMQTTCFSocketDecoderStateReady,
    DoorDuMQTTCFSocketDecoderStateError
};

@class DoorDuMQTTCFSocketDecoder;

@protocol DoorDuMQTTCFSocketDecoderDelegate <NSObject>
- (void)decoder:(DoorDuMQTTCFSocketDecoder *)sender didReceiveMessage:(NSData *)data;
- (void)decoderDidOpen:(DoorDuMQTTCFSocketDecoder *)sender;
- (void)decoder:(DoorDuMQTTCFSocketDecoder *)sender didFailWithError:(NSError *)error;
- (void)decoderdidClose:(DoorDuMQTTCFSocketDecoder *)sender;

@end

@interface DoorDuMQTTCFSocketDecoder : NSObject <NSStreamDelegate>
@property (nonatomic) DoorDuMQTTCFSocketDecoderState state;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSInputStream *stream;
@property (strong, nonatomic) NSRunLoop *runLoop;
@property (strong, nonatomic) NSString *runLoopMode;
@property (weak, nonatomic ) id<DoorDuMQTTCFSocketDecoderDelegate> delegate;

- (void)open;
- (void)close;

@end


