//
//  DoorDuMqttMessageHandle.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuBaseResponse.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DoorDuMqttMessageType)
{
    DoorDuMqttMessageUnkown              = 0,    //未知消息
    DoorDuMqttMessageAppIncommingType    = 1,    //app来电消息
    DoorDuMqttMessageDoorIncommingType   = 2,    //门禁机来电消息
    DoorDuMqttMessageHangupType          = 3,    //挂断消息
    DoorDuMqttMessageDataType            = 4     //数据消息（暂未使用）
};

typedef void(^doordUMQTTMessageHandleBlock)(DoorDuMqttMessageType messageType, id messageObj);

@interface DoorDuMqttMessageHandle : NSObject

// 当前会话ID
@property (nonatomic,copy) NSString *transcationID;

+ (instancetype)sharedInstance;

/**
 mqtt消息处理

 @param payload 收到的mqtt消息负载
 @param block   消息处理回调
 */
- (void)handleMessageWithMqttPayload:(NSData *)payload completion:(doordUMQTTMessageHandleBlock)block;
/**
 清除当前会话transaction
 */
- (void)clearTransaction;

@end
