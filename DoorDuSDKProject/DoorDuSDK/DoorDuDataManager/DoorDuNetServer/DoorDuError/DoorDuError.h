//
//  DoorDuErrorStatus.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DoorDuErrorCode)
{
    DoorDuErrorCodeReqSuccess                           = 200,      /*请求成功*/
    DoorDuErrorCodeReqFailed                            = 400,      /*请求失败*/
    DoorDuErrorCodeReqFrequently                        = 403,      /*请求频率过快，同一接口3s只能请求一次*/
    DoorDuErrorCodeReqNoInterface                       = 404,      /*接口不存在*/
    DoorDuErrorCodeReqTokenExpired                      = 426,      /*Token失效*/
    DoorDuErrorCodeReqServerException                   = 500,      /*服务器异常*/
    DoorDuErrorCodeReqUnkown                            = -1,       /*未知错误*/
    DoorDuErrorCodeReqCancel                            = -999,     /*请求被取消*/
    DoorDuErrorCodeReqServerNoArrive                    = -1004,    /*服务器不可到达*/
    DoorDuErrorCodeReqNetError                          = -1009,    /*网络不可用*/
    DoorDuErrorCodeReqTimeout                           = -1001,    /*请求超时*/
    DoorDuErrorCodeReqAgentIdNotExisit                  = 40001,    /*agent id不存在*/
    DoorDuErrorCodeReqAppIdNotExisit                    = 40002,    /*app id不存在*/
    DoorDuErrorCodeReqSDKIdNotExisit                    = 40003,    /*sdk id不存在*/
    DoorDuErrorCodeReqUserNotExisit                     = 40004,    /*用户不存在*/
    DoorDuErrorCodeReqDeviceNotExisit                   = 40005,    /*设备不存在*/
    DoorDuErrorCodeReqCallFailed                        = 40006,    /*呼叫失败*/
    DoorDuErrorCodeReqDoorDeviceNotExisitOrUnbind       = 40007,    /*门禁机不存在或被解绑*/
    DoorDuErrorCodeReqOpenDoorDeviceNotExisit           = 40008,    /*开门设备不存在*/
    DoorDuErrorCodeReqOpenDoorFailed                    = 40009,    /*开门失败*/
    DoorDuErrorCodeReqNoPrivilege                       = 400010,   /*无权限*/
    DoorDuErrorCodeReqDoorDeviceNotExisit               = 400011,   /*门禁机不存在*/
    DoorDuErrorCodeReqOpenDoorPwdExpired                = 400012,   /*开门密码生产失败*/
    DoorDuErrorCodeReqCalledRoomNotExisit               = 400015,   /*被叫房间不存在*/
};

@interface DoorDuError : NSObject

/**
 *  错误码
 */
@property (nonatomic,assign) DoorDuErrorCode errorCode;

/**
 *  错误描述信息
 */
@property (nonatomic,copy) NSString *message;

/**
 构造错误参数

 @param errorCode 错误码
 @param message 错误信息描述符
 @return 返回一个错误信息对象
 */
+ (DoorDuError *)errorWithCode:(DoorDuErrorCode)errorCode desMessage:(NSString *)message;

@end
