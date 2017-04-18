//
//  DoorDuMqttMessageHandle.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuMqttMessageHandle.h"
#import "DoorDuProxyInfo.h"
#import "DoorDuAudioPlayer.h"
#import "DoorDuCommonHeader.h"
#import "DoorDuEachFamilyAccessCallModel.h"
#import "DoorDuDoorCallModel.h"
#import <UIKit/UIKit.h>

static DoorDuMqttMessageHandle *doorDuMesHandle = nil;//DoorDuApi2单例静态常量

@interface DoorDuMqttMessageHandle ()

@end

@implementation DoorDuMqttMessageHandle

#pragma mark (创建线程安全单例)
+ (instancetype)sharedInstance {
    
    if (doorDuMesHandle == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            doorDuMesHandle = [[DoorDuMqttMessageHandle alloc] init];
        });
    }
    return doorDuMesHandle;
}

- (void)clearTransaction
{
    self.transcationID = nil;
}

- (void)handleMessageWithMqttPayload:(NSData *)payloadData completion:(doordUMQTTMessageHandleBlock)block
{
    //转换数据
    id tmpData = [NSJSONSerialization JSONObjectWithData:payloadData options:NSJSONReadingAllowFragments error:nil];
    DoorDuLog(@"收到推送消息----%@",tmpData);
    if (!tmpData || ![tmpData isKindOfClass:[NSDictionary class]]) {
        block(DoorDuMqttMessageUnkown, nil);
        return;
    }
    
    //解析数据
    NSDictionary *payload = tmpData;
    //基础数据检查
    if (![[payload allKeys] containsObject:@"cmd"] || ![[payload allKeys] containsObject:@"data"]) {
        block(DoorDuMqttMessageUnkown, nil);
        return;
    }
    
    NSString *cmd = [payload objectForKey:@"cmd"];
    NSDictionary *baseData = [payload objectForKey:@"data"];
    
    //呼叫数据检查
    if (![[payload allKeys] containsObject:@"transactionID"]) {
        block(DoorDuMqttMessageUnkown, nil);
        return;
    }
    
    //当前正在通话，或当前有回话的时候不处理……, (需要上层做控制)
//    if ([DoorDuMqttMessageHandle sharedInstance].transcationID.length > 0) {
//        return;
//    }
    
    //来电
    if ([cmd isEqualToString:@"makeCall"]) {
        
        NSNumber *incomingType = [baseData objectForKey:@"incomingType"];
        // 来电处理 “过滤收到自己的MQTT呼叫包，及房号为空的错误数据”
        if (!incomingType || incomingType.integerValue == 0) {
            //主叫房间的唯一标识
            NSString *fromRoomID = [NSString stringWithFormat:@"%@", [baseData objectForKey:@"roomID"]];
            if (!fromRoomID || [fromRoomID isEqualToString:@""]) {
                block(DoorDuMqttMessageUnkown, nil);
                return;
            }
            
            //被叫的房间唯一标识
            NSString *remoteRoomID = [NSString stringWithFormat:@"%@", [baseData objectForKey:@"remoteRoomID"]];
            if (!remoteRoomID || [remoteRoomID isEqualToString:@""] || [remoteRoomID isEqualToString:fromRoomID]) {
                block(DoorDuMqttMessageUnkown, nil);
                return;
            }
        }
        
        // 回传数据给第三方使用，在第三方实现业务逻辑处理
        // ADD CODE HERE
        [self handleMakeCallMessage:payload completion:block];
    }else if ([cmd isEqualToString:@"hangUpCall"]) {
        //挂断通话消息包
        // ADD CODE HERE
        [self handleHangUpCallMessage:payload completion:block];
    }else {
        block(DoorDuMqttMessageUnkown, nil);
    }
}

- (void)handleMakeCallMessage:(NSDictionary *)mqttMessage completion:(doordUMQTTMessageHandleBlock)block
{
    self.transcationID = [mqttMessage objectForKey:@"transactionID"];
    NSNumber *incomeingType = [[mqttMessage objectForKey:@"data"] objectForKey:@"incomingType"];
    //没有来电类型标记
    if (!incomeingType) {
        block(DoorDuMqttMessageUnkown, nil);
        return;
    }
    
    // app来电
    if ([incomeingType integerValue] == 0) {
        
        DoorDuEachFamilyAccessCallModel *model = [[DoorDuEachFamilyAccessCallModel alloc] initWithDictionary:[mqttMessage objectForKey:@"data"]];
        // 检查数据完整性
        if (![model checkDataInvalid]) {
            block(DoorDuMqttMessageUnkown, nil);
            return;
        }
        
        //ADD CODE HERE
        block(DoorDuMqttMessageAppIncommingType, model);
        
    }else if ([incomeingType integerValue] == 1) {
        //门禁来电
        DoorDuDoorCallModel *model = [[DoorDuDoorCallModel alloc] initWithDictionary:[mqttMessage objectForKey:@"data"]];
        // 检查数据完整性
        if (![model checkDataInvalid]) {
            block(DoorDuMqttMessageUnkown, nil);
            return;
        }
        
        block(DoorDuMqttMessageDoorIncommingType, model);
    }
}
/**
    处理挂断消息，这里可能收到我自己发的挂断消息，如果数据里面没有toSipNO（或者空字符的话，说明是主叫方发送了挂断消息）。如果toSipNO有值，说明一个用户接听了，告诉其他用户挂断就可以了（toSipNO是当前接听人的sip号）；
 */
- (void)handleHangUpCallMessage:(NSDictionary *)mqttMessage completion:(doordUMQTTMessageHandleBlock)block
{
    /**判断有没有在通话中，这里不判断了，业务就不混乱了
    if (![DoorDuSipCallManager isExistCall]) {
    } else {//在通话中。。。
    }*/
    //停止播放音效
    if (self.transcationID) {/**判断当前是否收到MQTT通话通知，为空就没有通话过来，主动呼叫方挂断的时候self.transcationID 制空了，不会到这里*/
        [[DoorDuAudioPlayer sharedInstance] stopPlayAudioAndVibrate];
        NSString *transcationID = [mqttMessage objectForKey:@"transactionID"];
        if ([transcationID isEqualToString:self.transcationID]) {/**两个呼叫ID相同，说明要挂断*/
            self.transcationID = nil;//制空下，反正是要挂断
            NSDictionary *baseData = [mqttMessage objectForKey:@"data"];
            /**toSipNO 判断有没有这个字段，没有的话，说明主叫方挂断了电话*/
            if (![[baseData allKeys] containsObject:@"toSipNO"]) {
                block(DoorDuMqttMessageHangupType, nil);
                return;
            }
            NSString *toSipNO = [NSString stringWithFormat:@"%@", [baseData objectForKey:@"toSipNO"]];/**挂断人的SIP账号*/
            if (toSipNO.length == 0) {/**字段为空，说明主叫方挂断了电话*/
                block(DoorDuMqttMessageHangupType, nil);
                return;
            }
            /**以下处理，说明是别人接通了主叫方的电话了（咱们是反打机制），接听者发送MQTT通知其他用户挂断电话，（接听者也会收到）*/
            NSString *userSip = [DoorDuProxyInfo sharedInstance].userInfo.callerNo;
            if (![toSipNO isEqualToString:userSip]) {/**过滤，发送挂断电话的人不是当前用户*/
                block(DoorDuMqttMessageHangupType, nil);
            }
        }
    }
}

@end


