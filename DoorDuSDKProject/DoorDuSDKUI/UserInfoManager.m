//
//  UserInfoManager.m
//  DoorDuSDKProject
//
//  Created by feigle on 2017/4/26.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "UserInfoManager.h"

static UserInfoManager * doorDuUserInfo = nil;

@implementation UserInfoManager

#pragma mark (创建线程安全单例)
+ (instancetype)shareInstance {
    if (doorDuUserInfo == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            doorDuUserInfo = [[UserInfoManager alloc] init];
        });
    }
    return doorDuUserInfo;
}

@end
