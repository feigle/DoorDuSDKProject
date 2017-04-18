//
//  DoorDuMqttOption.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuMQTTMessage.h"

@interface DoorDuMqttOption : NSObject


/**
 The Client Identifier identifies the Client to the Server. If nil, a random clientId is generated.
 */
@property (nonatomic,strong) NSString *clientId;

/**
 an NSString object containing the user's name (or ID) for authentication. May be nil.
 */
@property (nonatomic,strong) NSString *userName;

/**
 an NSString object containing the user's password. If userName is nil, password must be nil as well.
 */
@property (nonatomic,strong) NSString *password;

/**
 The Keep Alive is a time interval measured in seconds. The DoorDuMQTTClient ensures that the interval between Control Packets being sent does not exceed the Keep Alive value. In the  absence of sending any other Control Packets, the Client sends a PINGREQ Packet.
 */
@property (nonatomic,assign) UInt16 keepAliveInterval;

/**
 specifies if the server should discard previous session information.
 */
@property (nonatomic,assign) BOOL cleanSessionFlag;

/**
 If the Will Flag is set to YES this indicates that a Will Message MUST be published by the Server when the Server detects that the Client is disconnected for any reason other than the Client flowing a DISCONNECT Packet.
 */
@property (nonatomic,assign) BOOL willFlag;

/**
 If the Will Flag is set to YES, the Will Topic is a string, nil otherwise.
 */
@property (nonatomic,strong) NSString *willTopic;

/**
 If the Will Flag is set to YES the Will Message must be specified, nil otherwise.
 */
@property (nonatomic,strong) NSData *willMsg;

/**
 specifies the QoS level to be used when publishing the Will Message. If the Will Flag is set to NO, then the Will QoS MUST be set to 0. If the Will Flag is set to YES, the value of Will QoS can be 0 (0x00), 1 (0x01), or 2 (0x02).
 */
@property (nonatomic,assign) DoorDuMQTTQosLevel willQos;

/**
 indicates if the server should publish the Will Messages with retainFlag. If the Will Flag is set to NO, then the Will Retain Flag MUST be set to NO . If the Will Flag is set to YES: If Will Retain is set to NO, the Server MUST publish the Will Message as a non-retained publication [DoorDuMQTT-3.1.2-14]. If Will Retain is set to YES, the Server MUST publish the Will Message as a retained publication [DoorDuMQTT-3.1.2-15].
 */
@property (nonatomic,assign) BOOL willRetainFlag;

/**
 specifies the protocol to be used. The value of the Protocol Level field for the version 3.1.1 of the protocol is 4. The value for the version 3.1 is 3.
 */
@property (nonatomic,assign) UInt8 protocolLevel;

/**
 The runLoop where the streams are scheduled. If nil, defaults to [NSRunLoop currentRunLoop].
 */
@property (nonatomic,strong) NSRunLoop *runloop;

/**
 The runLoopMode where the streams are scheduled. If nil, defaults to NSRunLoopCommonModes.
 */
@property (nonatomic,strong) NSString *runloopMode;


/**
 构造默认配置对象

 @return DoorDuMqttOption实例化对象
 */
+ (id)defaultOption;

@end
