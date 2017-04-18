//
//  DoorDuGlobleConfig.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuGlobleConfig.h"

static DoorDuGlobleConfig *theInstance = nil;

@implementation DoorDuGlobleConfig

#pragma mark (创建单例)
+ (instancetype)sharedInstance {
    
    if (theInstance == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            theInstance = [[DoorDuGlobleConfig alloc] init];
        });
    }
    return theInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        //默认设置发布模式
        [self setDoorDuSDKMode:DoorDuDistributeMode];
    }
    return self;
}

- (void)setDoorDuSDKMode:(DoorDuSDKMode)mode
{
    switch (mode) {
        case DoorDuTestMode:
            [self textMode];
            break;
        case DoorDuPreDistributeMode:
            [self preDistributeMode];
            break;
        case DoorDuDistributeMode:
            [self distributeMode];
            break;
        default:
            [self distributeMode];
            break;
    }
}

- (void)textMode
{
    _mqttServer = @"ssl.test.doordu.com";
    _mqttPort = 1883;
    _httpUrlStr = @"https://interface.beta.doordu.com/";
}

- (void)preDistributeMode
{
    _mqttServer = @"ssl.beta.doordu.com";
    _mqttPort = 1883;
    _httpUrlStr = @"https://interface.beta.doordu.com/";
}

- (void)distributeMode
{
    _mqttServer = @"mqtt.doordu.com";
    _mqttPort = 1883;
    _httpUrlStr = @"https://interface.beta.doordu.com/";
}

@end
