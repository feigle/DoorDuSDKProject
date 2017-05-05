//
//  DoorDuMQTTManager.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuMQTTManager.h"
#import "DoorDuMQTTClient.h"
#import <UIKit/UIKit.h>
#import "DoorDuGlobleConfig.h"
#import "DoorDuCommonHeader.h"
#import "DoorDuMqttMessageHandle.h"

#define MQTT_RECONNECT_INTERVAL 2.0

static DoorDuMQTTManager *mqttInstance = nil;

@interface DoorDuMQTTManager() {
    // 用于重连mqtt
    NSTimer *ddMQTTReconnectTimer;
}
// mqtt客户端id
@property (copy,nonatomic) NSString *clientID;
// 订阅主题
@property (strong,nonatomic) NSMutableArray *topics;
// 消息内容
@property (strong,nonatomic) NSData *payload;
// 回话
@property (strong,nonatomic) DoorDuMQTTSession *session;
// MQTT配置
@property (strong,nonatomic) DoorDuMqttOption *mqttOption;
@property (nonatomic,strong) NSString *domain;
@property (nonatomic,weak) id<DoorDuMQTTDelegate> delegate;

@end


@implementation DoorDuMQTTManager

#pragma mark (创建单例)
+ (instancetype)sharedInstance {
    
    if (mqttInstance == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            mqttInstance = [[DoorDuMQTTManager alloc] init];
        });
    }
    
    return mqttInstance;
}

#pragma mark (重载基类)
- (id)init {
    
    self = [super init];
    
    if (self) {
        _session = nil;
        _payload = nil;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    return self;
}

- (void)dealloc
{
    [ddMQTTReconnectTimer invalidate];
    ddMQTTReconnectTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (!mqttInstance.session) {
        return;
    }
    
    [DoorDuMQTTManager reconnect];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (!mqttInstance.session) {
        return;
    }
    
    [DoorDuMQTTManager disconnect];
}

- (NSString *)domain
{
    return [DoorDuGlobleConfig sharedInstance].mqttServer;
}

+ (void)setDelegate:(id<DoorDuMQTTDelegate>)delegate
{
    if (!mqttInstance) {
        [DoorDuMQTTManager sharedInstance];
    }
    
    mqttInstance.delegate = delegate;
}

+ (void)configMQTTWithOptions:(DoorDuMqttOption *)option
{
    if (!mqttInstance) {
        [DoorDuMQTTManager sharedInstance];
    }
    
    mqttInstance.mqttOption = option;
    mqttInstance.clientID = option.clientId;
    //清除回话
    [DoorDuMQTTManager clearCurrentSession];
    
    mqttInstance.session = [[DoorDuMQTTSession alloc] initWithClientId:option.clientId
                                                             userName:option.userName
                                                             password:option.password
                                                            keepAlive:option.keepAliveInterval                      //客户端确保控制发布的数据包之间的时间间隔不超过存活时间
                                                         cleanSession:option.cleanSessionFlag                       //指定服务器是否清除之前的会话,false是持久对话true则相反
                                                                 will:option.willFlag                               //遗嘱,如果是YES的话,消息会被发送到服务器
                                                            willTopic:option.willTopic                              //如果willFlag为YES,则为字符串,否则为nil
                                                              willMsg:option.willMsg                                //如果willFlag为YES,则为字符串,否则为nil
                                                              willQoS:option.willQos                                //指定消息质量级别,0暂时还没用到,从1和2中选择
                                                       willRetainFlag:option.willRetainFlag                         //表明如果服务器应该发布willmsg的状态。如果willflag为NO,该处也为NO,如果                                         willFlag为YES,该处为NO的话，服务器发布willMsg必须为非保留状态。
                                                        protocolLevel:option.protocolLevel                          //协议等级
                                                              runLoop:option.runloop                                //如果为nil，默认为[NSRunLoop currentRunLoop]
                                                              forMode:option.runloopMode];                          //默认为NSRunLoopCommonModes
    
    

}

// 创建MQTT连接
+ (void)conenctWithTopics:(NSArray *)topicArray clientID:(NSString *)clientID
{
    if (!mqttInstance) {
        [DoorDuMQTTManager sharedInstance];
    }
    
    // 获取app的sip账号作为MQTT的clientID
    mqttInstance.topics = [[NSMutableArray alloc] initWithArray:topicArray];
    mqttInstance.clientID = clientID;
    
    // 检查当前回话是否已经存在，如果存在先断开连接
    if (mqttInstance.session.status == DoorDuMQTTSessionStatusConnected) {
        [mqttInstance.session disconnect];
    }else {
        NSString *clientIdString = nil;
        if (!clientID) {
            clientIdString = mqttInstance.mqttOption.clientId;
        }
        mqttInstance.session = [[DoorDuMQTTSession alloc] initWithClientId:clientIdString
                                                           userName:nil
                                                           password:nil
                                                          keepAlive:60                              //客户端确保控制发布的数据包之间的时间间隔不超过存活时间
                                                       cleanSession:false                           //指定服务器是否清除之前的会话,false是持久对话true则相反
                                                               will:false                           //遗嘱,如果是YES的话,消息会被发送到服务器
                                                          willTopic:nil                             //如果willFlag为YES,则为字符串,否则为nil
                                                            willMsg:nil                             //如果willFlag为YES,则为字符串,否则为nil
                                                            willQoS:DoorDuMQTTQosLevelAtMostOnce          //指定消息质量级别,0暂时还没用到,从1和2中选择
                                                     willRetainFlag:false                           //表明如果服务器应该发布willmsg的状态。如果willflag为NO,该处也为NO,如果                                         willFlag为YES,该处为NO的话，服务器发布willMsg必须为非保留状态。
                                                      protocolLevel:4                               //协议等级
                                                            runLoop:nil                             //如果为nil，默认为[NSRunLoop currentRunLoop]
                                                            forMode:nil];                           //默认为NSRunLoopCommonModes
    }
    [DoorDuMQTTManager connectAction];
}

+ (void)connectAction
{
    mqttInstance.session.delegate = mqttInstance;
    [mqttInstance.session connectToHost:mqttInstance.domain port:[DoorDuGlobleConfig sharedInstance].mqttPort];
}

+ (void)disconnect
{
    if (mqttInstance.session) {
        [mqttInstance.session disconnect];
    }
}

+ (void)clearCurrentSession
{
    if (!mqttInstance) {
        return;
    }
    
    if (mqttInstance.session.status == DoorDuMQTTSessionStatusConnected) {
        [DoorDuMQTTManager disconnect];
    }
    
    mqttInstance.delegate = nil;
    mqttInstance.session = nil;
    mqttInstance.payload = nil;
    mqttInstance.clientID = nil;
    mqttInstance.topics = nil;
}

/*! @brief DoorDuMQTTManager类方法， 重新连接MQTT
 *
 */
+ (void)reconnect
{
    if (!mqttInstance) {
        return;
    }
    
    // 检查mqtt客户端id、订阅主题是否为空
    if (!mqttInstance.clientID
        || [mqttInstance.clientID isEqualToString:@""]
        || !mqttInstance.topics
        || mqttInstance.topics.count == 0) {
        return;
    }
    
    // 连接mqtt
    [DoorDuMQTTManager connectAction];
}

+ (void)publishMessage:(NSData *)payload onTopic:(NSString *)topic
{
    [mqttInstance publishMessage:payload onTopic:topic withQosLevel:DoorDuMQTTQosLevelAtMostOnce];
}

- (void)publishMessage:(NSData *)payload onTopic:(NSString *)topic withQosLevel:(DoorDuMQTTQosLevel)level
{
    switch (level) {
        case DoorDuMQTTQosLevelAtMostOnce:
            [self.session publishDataAtMostOnce:payload onTopic:topic];
            break;
        case DoorDuMQTTQosLevelAtLeastOnce:
            [self.session publishDataAtLeastOnce:payload onTopic:topic];
            break;
        case DoorDuMQTTQosLevelExactlyOnce:
            [self.session publishDataExactlyOnce:payload onTopic:topic];
            break;
        default:
            [self.session publishDataAtMostOnce:payload onTopic:topic];
            break;
    }
}

- (void)connectMQTT
{
    //处于后台或者非活跃状态不需要重联
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground
        || [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        return;
    }
    
    [DoorDuMQTTManager reconnect];
}

#pragma mark (发布通话结束)
+ (void)publishCallEnd:(NSString *)sipAccount
                roomID:(NSNumber *)roomID
      transactionID:(NSString *)transactionID {
    
    if (!sipAccount) {
        sipAccount = @"";
    }
    
    if (!roomID) {
        return;
    }
    
    if (mqttInstance.session && transactionID
        && ![transactionID isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //NSLog(@"----------------------发布通话结束(开始发送)----------------------");
            NSMutableDictionary *payloadDict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            [data setValue:sipAccount forKey:@"toSipNO"];
            [payloadDict setValue:transactionID forKey:@"transactionID"];
            [payloadDict setValue:@"hangUpCall" forKey:@"cmd"];
            [payloadDict setValue:data forKey:@"data"];
            NSData *payload = [NSJSONSerialization dataWithJSONObject:payloadDict
                                                              options:0
                                                                error:nil];
            NSString *topic = [NSString stringWithFormat:@"app/room_id/%@", roomID];
            [mqttInstance.session publishDataAtMostOnce:payload onTopic:topic];
        });
    }
}

// 用于当通话建立之后，主叫方调用此接口发布一个连接消息
+ (void)publishCallConnected:(NSString *)sipAccount
                      roomID:(NSNumber *)roomID
               transactionID:(NSString *)transactionID
{
    [DoorDuMQTTManager publishCallEnd:sipAccount roomID:roomID transactionID:transactionID];
}

#pragma mark -
#pragma mark (MQTTSessionDelegate)
- (void)connectionError:(DoorDuMQTTSession *)session error:(NSError *)error
{
    DoorDuLog(@"DoorDuMQTTManager----------MQTT连接失败");
    if ([mqttInstance.delegate respondsToSelector:@selector(mqttConnectError:)]) {
        [mqttInstance.delegate mqttConnectError:error];
    }
}

- (void)connectionRefused:(DoorDuMQTTSession *)session error:(NSError *)error
{
    DoorDuLog(@"DoorDuMQTTManager----------MQTT连接被拒");
    if ([mqttInstance.delegate respondsToSelector:@selector(mqttConnectRefused:)]) {
        [mqttInstance.delegate mqttConnectRefused:error];
    }
}

- (void)connected:(DoorDuMQTTSession *)session {
    
    if (ddMQTTReconnectTimer) {
        [ddMQTTReconnectTimer invalidate];
        ddMQTTReconnectTimer = nil;
    }
    
    //MQTT订阅主题
    DoorDuLog(@"DoorDuMQTTManager----------MQTT已连接");
    if (mqttInstance.topics && mqttInstance.topics.count > 0) {
//        for (NSString *topic in mqttInstance.topics) {
//            [mqttInstance.session subscribeToTopic:topic atLevel:DoorDuMQTTQosLevelExactlyOnce];
//        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *topics = [NSMutableDictionary dictionary];
            for (NSString *topic in mqttInstance.topics) {
                [topics setObject:@"2" forKey:topic];
            }
            [mqttInstance.session subscribeToTopics:topics subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                if (!error) {
                    DoorDuLog(@"mqtt 订阅主题成功!");
                }
            }];
        });
    }
    
    if ([mqttInstance.delegate respondsToSelector:@selector(mqttConnectedSuccess)]) {
        [mqttInstance.delegate mqttConnectedSuccess];
    }
}

- (void)connectionClosed:(DoorDuMQTTSession *)session {
    
    DoorDuLog(@"DoorDuMQTTManager----------MQTT连接断开");
    if (ddMQTTReconnectTimer) {
        [ddMQTTReconnectTimer invalidate];
        ddMQTTReconnectTimer = nil;
    }
    
    ddMQTTReconnectTimer = [NSTimer scheduledTimerWithTimeInterval:MQTT_RECONNECT_INTERVAL
                                                         target:mqttInstance
                                                       selector:@selector(connectMQTT)
                                                       userInfo:nil
                                                        repeats:NO];
    
    if ([mqttInstance.delegate respondsToSelector:@selector(mqttConnectedClosed)]) {
        [mqttInstance.delegate mqttConnectedClosed];
    }
}

- (void)newMessage:(DoorDuMQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(DoorDuMQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    // 保存负载数据
    mqttInstance.payload = data;
    
    //MQTT消息包消息处理
    [[DoorDuMqttMessageHandle sharedInstance] handleMessageWithMqttPayload:data completion:^(DoorDuMqttMessageType messageType, id messageObj) {
        
        if (messageType == DoorDuMqttMessageAppIncommingType) {
            
            DoorDuEachFamilyAccessCallModel *callModel = (DoorDuEachFamilyAccessCallModel *)messageObj;
            if ([self.delegate respondsToSelector:@selector(appIncomingMessage:)]) {
                [self.delegate appIncomingMessage:callModel];
            }
        }else if(messageType == DoorDuMqttMessageDoorIncommingType) {
            
            DoorDuDoorCallModel *callModel = (DoorDuDoorCallModel *)messageObj;
            if ([self.delegate respondsToSelector:@selector(doorIncomingMessage:)]) {
                [self.delegate doorIncomingMessage:callModel];
            }
        }else if (messageType == DoorDuMqttMessageHangupType) {
            
            if ([self.delegate respondsToSelector:@selector(hangupMessage)]) {
                [self.delegate hangupMessage];
            }
        }
    }];
}







@end
