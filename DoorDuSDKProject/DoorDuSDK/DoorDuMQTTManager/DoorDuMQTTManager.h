//
//  DoorDuMQTTManager.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuMQTTSession.h"
#import "DoorDuMqttOption.h"
#import "DoorDuMqttMessageHandle.h"
#import "DoorDuEachFamilyAccessCallModel.h"
#import "DoorDuDoorCallModel.h"

@protocol DoorDuMQTTDelegate <NSObject>

@optional
/*mqtt连接成功*/
- (void)mqttConnectedSuccess;
/*mqtt断开连接*/
- (void)mqttConnectedClosed;
/*mqtt连接失败*/
- (void)mqttConnectError:(NSError *)error;
/*mqtt连接被拒*/
- (void)mqttConnectRefused:(NSError *)error;
/*app来电推送消息*/
- (void)appIncomingMessage:(DoorDuEachFamilyAccessCallModel *)model;
/*门禁来电推送消息*/
- (void)doorIncomingMessage:(DoorDuDoorCallModel *)model;
/*挂断推送消息*/
- (void)hangupMessage;

@end

@interface DoorDuMQTTManager : NSObject<DoorDuMQTTSessionDelegate>

/**
 设置代理

 @param delegate 代理对象
 */
+ (void)setDelegate:(id<DoorDuMQTTDelegate>)delegate;

+ (void)configMQTTWithOptions:(DoorDuMqttOption *)option;

/**
 连接mqtt
 */
+ (void)connectAction;

/*! @brief DoorDuMQTTManager类方法， 订阅主题（用于开辟新的mqtt会话）
 *
 * @param       topicArray  MQTT主题数组
 * @param       clientID    MQTT账号,如果该参数为nil，使用DoorDuMqttOption
 */
+ (void)conenctWithTopics:(NSArray *)topicArray clientID:(NSString *)clientID;

/*! @brief DoorDuMQTTManager类方法， 断开MQTT连接
 *
 */
+ (void)disconnect;

/*! @brief DoorDuMQTTManager类方法， 重新连接MQTT
 *
 */
+ (void)reconnect;

/**
 发布消息

 @param payload 消息负载内容，需要按规定格式拼装数据
 @param topic 主题
 */
+ (void)publishMessage:(NSData *)payload onTopic:(NSString *)topic;

/*! @brief DoorDuMQTTManager类方法，删除当前mqtt所有状态,用于用户注销时候清楚mqtt缓存
 *
 */
+ (void)clearCurrentSession;



#pragma mark -- 旧方法
/*! @brief DoorDuMQTTManager类方法， 通话结束，调用此接口
 *
 * @param       sipAccount          被叫方sip通话账号（如果通话未建立，主叫方结束通话，sipAccount值传nil）
 * @param       roomID              被叫方房间号
 * @param       transactionID    回话ID
 */
+ (void)publishCallEnd:(NSString *)sipAccount
                roomID:(NSString *)roomID
      transactionID:(NSString *)transactionID;

/*! @brief DoorDuMQTTManager类方法， 用于当通话建立之后，主叫方调用此接口发布一个连接消息
 *
 * @param       sipAccount          被叫方sip通话账号（当前用户的SIP）
 * @param       roomID              被叫方房间号
 * @param       transactionID    回话ID
 */
+ (void)publishCallConnected:(NSString *)sipAccount
                      roomID:(NSString *)roomID
            transactionID:(NSString *)transactionID;



@end
