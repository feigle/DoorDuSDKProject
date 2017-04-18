//
//  DoorDuErrorStatus.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuError.h"

@implementation DoorDuError

- (void)setErrorCode:(DoorDuErrorCode)errorCode
{
    _errorCode = errorCode;
    switch (errorCode) {
        case 200:
            _message = @"请求成功";
            break;
        case 400:
            _message = @"请求失败";
            break;
        case 403:
            _message = @"请求频率过快，同一接口3s只能请求一次";
            break;
        case 404:
            _message = @"接口不存在";
            break;
        case 426:
            _message = @"Token失效";
            break;
        case 500:
            _message = @"服务器异常";
            break;
        case -1:
            _message = @"未知错误";
            break;
        case -999:
            _message = @"请求被取消";
            break;
        case -1004:
            _message = @"服务器不可到达";
            break;
        case -1009:
            _message = @"网络不可用";
            break;
        case -1001:
            _message = @"请求超时";
        case 40001:
            _message = @"agent id不存在";
            break;
        case 40002:
            _message = @"app id不存在";
            break;
        case 40003:
            _message = @"sdk id不存在";
            break;
        case 40004:
            _message = @"用户不存在";
            break;
        case 40005:
            _message = @"设备不存在";
            break;
        case 40006:
            _message = @"呼叫失败";
            break;
        case 40007:
            _message = @"门禁机不存在或被解绑";
            break;
        case 40008:
            _message = @"开门设备不存在";
            break;
        case 40009:
            _message = @"开门失败";
            break;
        case 400010:
            _message = @"无权限";
            break;
        case 400011:
            _message = @"门禁机不存在";
            break;
        case 400012:
            _message = @"开门密码生产失败";
            break;
        case 400015:
            _message = @"被叫房间不存在";
            break;
        default:
            _message = @"";
            break;
    }
}

+ (DoorDuError *)errorWithCode:(DoorDuErrorCode)errorCode desMessage:(NSString *)message
{
    DoorDuError *error = [DoorDuError new];
    error.errorCode = errorCode;
    error.message = message;
    return error;
}


@end
