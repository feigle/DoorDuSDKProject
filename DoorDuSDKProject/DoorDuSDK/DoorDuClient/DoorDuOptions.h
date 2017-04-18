//
//  DoorDuOptions.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/30.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuClientEnum.h"

/**
    DoorDuClient 的配置类
 */
@interface DoorDuOptions : NSObject

/**
 token 厂商唯一标识符
 */
@property (nonatomic,copy,readonly) NSString *token;

/*是否输出日志*/
@property (nonatomic,assign) BOOL isShowLog;

/*设置开发环境*/
@property (nonatomic,assign) DoorDuSDKMode mode;

/**
 用token初始化 DoorDuOptions
 
 @param token 厂商Token
 */
+ (instancetype)optionsWithToken:(NSString *)token;

@end
