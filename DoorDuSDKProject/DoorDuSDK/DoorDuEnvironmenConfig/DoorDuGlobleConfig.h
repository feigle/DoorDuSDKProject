//
//  DoorDuGlobleConfig.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuClientEnum.h"

/**
 DoorDuSDK全局环境配置
 */
@interface DoorDuGlobleConfig : NSObject

/**
 mqtt服务器配置
 */
@property (readonly,nonatomic,strong) NSString *mqttServer;

/**
 mqtt服务器端口
 */
@property (readonly,nonatomic,assign) UInt32 mqttPort;

/**
 服务器地址配置
 */
@property (readonly,nonatomic,strong) NSString *httpUrlStr;

/**
 获取单列对象

 @return  实例化对象
 */
+ (instancetype)sharedInstance;

/**
 设置开发模式

 @param mode 开发模式
 */
- (void)setDoorDuSDKMode:(DoorDuSDKMode)mode;

@end
