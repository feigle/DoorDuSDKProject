//
//  DoorDuUserInfo.m
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuProxyInfo.h"

static DoorDuProxyInfo *_doorDuProxyInfo = nil; // 第三方用户信息

@implementation DoorDuProxyInfo

#pragma mark (创建线程安全单例)
+ (instancetype)sharedInstance {
    
    if (_doorDuProxyInfo == nil) {
        
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _doorDuProxyInfo = [[DoorDuProxyInfo alloc] init];
        });
    }
    return _doorDuProxyInfo;
}

+ (BOOL)isSDKRegister
{
    return [DoorDuProxyInfo sharedInstance].token.length > 0;
}

+ (void)clearAllData
{
    _doorDuProxyInfo.userInfo = nil;
}


@end
