//
//  DoorDuOptions.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/30.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuOptions.h"
#import "DoorDuGlobleConfig.h"
#import "DoorDuLog.h"

@interface DoorDuOptions ()

@property (nonatomic,copy,readwrite) NSString * token;

@end

@implementation DoorDuOptions

/**
 用token初始化 DoorDuOptions
 @param token 厂商Token
 */
+ (instancetype)optionsWithToken:(NSString *)token
{
    DoorDuOptions * options = [[DoorDuOptions alloc] init];
    options.token = token;
    return options;
}

- (void)setIsShowLog:(BOOL)isShowLog
{
    _isShowLog = isShowLog;
    [self enableLog:isShowLog];
}

- (void)setMode:(DoorDuSDKMode)mode
{
    _mode = mode;
    [self setDevelopmentEnvironment:mode];
}

/*是否输出日志*/
- (void)enableLog:(BOOL)isLog
{
    isLog ? [DoorDuLog enableLog] : [DoorDuLog disableLog];
}

/*设置开发环境*/
- (void)setDevelopmentEnvironment:(DoorDuSDKMode)mode
{
    DoorDuGlobleConfig *globleConfig = [DoorDuGlobleConfig sharedInstance];
    
    [globleConfig setDoorDuSDKMode:mode];
}

@end
