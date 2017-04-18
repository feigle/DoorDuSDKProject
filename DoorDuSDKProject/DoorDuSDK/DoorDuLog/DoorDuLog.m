//
//  DoorDuLog.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuLog.h"

static DoorDuLog *instance = nil;

@implementation DoorDuLog
{
    BOOL isDoorDuLogEnable;
}

+ (instancetype)shareInstance
{
    if (instance == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            instance = [[DoorDuLog alloc] init];
            instance->isDoorDuLogEnable = YES;
        });
    }
    
    return instance;
}

+ (void)enableLog
{
    [DoorDuLog shareInstance]->isDoorDuLogEnable = YES;
}

+ (void)disableLog
{
    [DoorDuLog shareInstance]->isDoorDuLogEnable = NO;
}

+ (BOOL)isLogEnable;
{
    return [DoorDuLog shareInstance]->isDoorDuLogEnable;
}

@end
