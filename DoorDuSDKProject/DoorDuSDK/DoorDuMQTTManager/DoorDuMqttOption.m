//
//  DoorDuMqttOption.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuMqttOption.h"

@implementation DoorDuMqttOption

+ (id)defaultOption
{
    DoorDuMqttOption *option = [DoorDuMqttOption new];
    option.clientId = nil;
    option.userName = nil;
    option.password = nil;
    option.keepAliveInterval = 60;
    option.cleanSessionFlag = NO;
    option.willFlag = NO;
    option.willTopic = nil;
    option.willMsg = nil;
    option.willQos = DoorDuMQTTQosLevelAtMostOnce;
    option.willRetainFlag = NO;
    option.protocolLevel = 4;
    option.runloop = nil;
    option.runloopMode = nil;
    return option;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
