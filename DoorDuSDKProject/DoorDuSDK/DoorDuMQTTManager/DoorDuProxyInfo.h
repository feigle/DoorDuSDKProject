//
//  DoorDuProxyInfo.h
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//
// 第三方用户数据

#import <Foundation/Foundation.h>
#import "DoorDuAllResponse.h"

@interface DoorDuProxyInfo : NSObject

// 第三方token
@property (nonatomic,copy) NSString *token;
// 当前设备deviceToken字符串
@property (nonatomic,copy) NSString *deviceTokenString;

// 第三方用户信息
@property (nonatomic,copy) DoorDuUserInfo *userInfo;

+ (instancetype)sharedInstance;

/**
 *  判断DoorDuSDK是否注册
 */
+ (BOOL)isSDKRegister;

/**
 *  清除用户数据所有数据
 */
+ (void)clearAllData;

@end
