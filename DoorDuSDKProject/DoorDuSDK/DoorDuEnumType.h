//
//  DoorDuEnumType.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#ifndef DoorDuEnumType_h
#define DoorDuEnumType_h


/*! @brief 接口返回状态码
 *
 */
typedef enum DoorDuStatusCode {
    
    DoorDuStatusCodeSuccess                       = 200,      /** 成功 */
    DoorDuStatusCodeRegisterFailure              = 400,      /** SDK注册失败 */
    DoorDuStatusCodeAuthenticationFailure        = 401,      /** 开发者信息验证失败 */
    DoorDuStatusCodeNormalFailure                = 404,      /** 普通错误 */
    DoorDuStatusCodeNoLoginFailure               = 405,      /** 用户未登录(未获取到终端sip信息) */
    DoorDuStatusCodeLoginTimeout                  = 426,      /** 用户登录超时，需要重新登录 */
    DoorDuStatusCodeServerError                  = 500,      /** 服务器异常 */
    DoorDuStatusCodeCancelRequest                = -999,     /** 终端中断网络请求 */
    DoorDuStatusCodeRequestTimeout               = -1001,    /** 网络请求超时 */
    DoorDuStatusCodeNotReachable                 = -1009,    /** 终端无网络连接 */
    DoorDuStatusCodeUnknownError                 = -1        /** 发生未知错误 */
    
}DoorDuStatusCode;

#pragma mark - DoorDuStateValue("SIP注册状态"，"呼叫状态"，"视频通话"的回调广播消息)
//广播消息name
extern NSString *const kDoorDuStateUpdateNotification;

//广播消息中UserInfo属性对应的key
extern NSString *const kDoorDuStateKey;

//广播消息中UserInfo属性对应的value
typedef NS_ENUM(NSInteger, DoorDuStateValue) {
    
    kDoorDuStateValueSipRegistrationProgress      = 0,//SIP账号正在注册
    kDoorDuStateValueSipRegistrationSucess        = 1,//SIP账号注册成功
    kDoorDuStateValueSipRegistrationCleared       = 2,//SIP账号注销成功
    kDoorDuStateValueSipRegisterationFailed       = 3,//SIP账号注册失败
    
    kDoorDuStateValueOnNewCall                    = 4,//新的呼叫(呼入/呼出)，收到本地或者远程呼叫开始的信息
    kDoorDuStateValueOnCallCancel                 = 5,//呼叫被取消(呼入/呼出)
    kDoorDuStateValueOnCallFailed                 = 6,//呼叫失败或错误(呼入/呼出)
    kDoorDuStateValueOnCallRejected               = 7,//呼叫被拒绝(呼出)
    kDoorDuStateValueOnCallProcessing             = 8,//正在建立连接(呼出)
    kDoorDuStateValueOnCallRinging                = 9,//被叫方振铃(呼出)
    kDoorDuStateValueOnCallConnected              = 10,//呼叫接通(呼入/呼出)
    kDoorDuStateValueOnCallEnded                  = 11,//呼叫结束(呼入/呼出)
    kDoorDuStateValueOnCallPausing                = 12,//正在设置呼叫暂停(呼入/呼出)
    kDoorDuStateValueOnCallPaused                 = 13,//呼叫已暂停(呼入/呼出)
    kDoorDuStateValueOnCallResuming               = 14,//正在设置终止呼叫暂停(呼入/呼出)
    kDoorDuStateValueOnCallResumed                = 15,//已终止呼叫暂停，恢复通话(呼入/呼出)
    kDoorDuStateValueOnCallRemoteUpdating         = 16,//呼叫远程设置正在更新(远程)
    kDoorDuStateValueOnCallRemoteUpdated          = 17,//呼叫远程设置已更新(远程)
    kDoorDuStateValueOnCallReferAccepted          = 18,//呼叫转移被接受(呼入/呼出)
    kDoorDuStateValueOnCallReferRejected          = 19,//呼叫转移被拒绝(呼入/呼出)
    
    kDoorDuStateValueOnAudioStreamReady           = 20,//媒体就绪(语音流就绪)
    kDoorDuStateValueOnVideoStreamReady           = 21,//媒体就绪(视频流就绪)
    kDoorDuStateValueOnDataStreamReady            = 22,//媒体就绪(数据流就绪)
    
    kDoorDuStateValueIncomingFrameChanged         = 23,//远程视频画面尺寸改变(视频通话中)
    kDoorDuStateValueIncomingFpsAndBitrateChanged = 24,//远程视频帧率和码率改变(视频通话中)
    kDoorDuStateValueOutgoingFpsAndBitrateChanged = 25,//本地视频帧率和码率改变(视频通话中)
    
    kDoorDuStateValueRemoteSwitchVideoToAudio     = 26,//远程通话由视频切换到语音模式的消息
};



#pragma mark - DoorDuSipRegistErrorCode(SIP帐号注册失败错误码)
typedef NS_ENUM(NSInteger, DoorDuSipRegistErrorCode) {
    
    kDoorDuSipRegistErrorCodeUnknown     = 0,//未知原因
    kDoorDuSipRegistErrorCodeForbidden   = 403,//被禁止
    kDoorDuSipRegistErrorCodeNotFound    = 404,//未发现
    kDoorDuSipRegistErrorCodeTimeout     = 408,//超时
    kDoorDuSipRegistErrorCodeUnreachable = 477,//无网络
    kDoorDuSipRegistErrorCodeDnsTimeout  = 503,//DNS超时(需要ResetTransport)
};


#pragma mark - DoorDuCallErrorCode(当前呼叫(呼入/呼出)错误返回码)
typedef NS_ENUM(NSInteger, DoorDuCallErrorCode) {
    
    kDoorDuCallErrorCodeUnknown                      = -1,//未知原因
    kDoorDuCallErrorCodeNone                         = 0,//呼叫不存在
    kDoorDuCallErrorCodeCouldNotCall                 = 1,//无法拨打
    kDoorDuCallErrorCodeUnauthorized                 = 401,//不合法(未授权)
    kDoorDuCallErrorCodeBadRequest                   = 400,//错误的请求
    kDoorDuCallErrorCodePaymentRequired              = 402,//需要付款
    kDoorDuCallErrorCodeForbidden                    = 403,//被禁止
    kDoorDuCallErrorCodeMethodNotAllowed             = 405,//不允许的方法
    kDoorDuCallErrorCodeProxyAuthenticationRequired  = 407,//需要代理身份验证
    kDoorDuCallErrorCodeRequestTimeout               = 408,//请求超时
    kDoorDuCallErrorCodeNotFound                     = 404,//未发现
    kDoorDuCallErrorCodeUnsupportedMediaType         = 415,//不支持的媒体类型
    kDoorDuCallErrorCodeRequestSendFailed            = 477,//发送请求失败
    kDoorDuCallErrorCodeBusyHere                     = 486,//正忙
    kDoorDuCallErrorCodeTemporarilyUnavailable       = 480,//暂时不可用
    kDoorDuCallErrorCodeRequestTerminated            = 487,//请求终止
    kDoorDuCallErrorCodeServerInternalError          = 500,//服务器内部错误
    kDoorDuCallErrorCodeDoNotDisturb                 = 600,//请勿打扰
    kDoorDuCallErrorCodeDeclined                     = 603,//呼叫挂断
    kDoorDuCallErrorCodeMediaStreamTimeout           = 1001,//媒体流超时(Media Error code)
};

#pragma mark - DoorDuCallIncomingType(当前来电(呼入)远程终端类型)
typedef NS_ENUM(NSInteger, DoorDuCallIncomingType) {
    kDoorDuCallIncomingTypeNone                          = -1,//呼叫(呼入)不存在
    kDoorDuCallIncomingTypeUnknown                       = 0,//未知
    kDoorDuCallIncomingTypeDoor                          = 1,//门禁主机来电
    kDoorDuCallIncomingTypeAndroid                       = 2,//Android应用终端(安卓手机App)来电
    kDoorDuCallIncomingTypeIOS                           = 3,//iOS应用终端(iOS手机App)来电
    kDoorDuCallIncomingTypeIndoor                        = 4,//室内机终端
    kDoorDuCallIncomingTypeCard                          = 5,//门禁卡
    kDoorDuCallIncomingTypeVilla                         = 6,//别墅机
    kDoorDuCallIncomingTypePropertyManagement            = 7,//物业管理机
    kDoorDuCallIncomingTypePropertyManagementPlatform    = 8,//物业管理平台
    kDoorDuCallIncomingTypeBox86                         = 9,//86盒
};

#pragma mark - DoorDuCallVideoSize(视频尺寸)
typedef struct DoorDuCallVideoSize {
    
    int width;//视频宽度
    int height;//视频高度
    
}DoorDuCallVideoSize;

#pragma mark - DoorDuCallFpsAndBitrate(视频帧率和码率)
typedef struct DoorDuCallFpsAndBitrate {
    int fps;//视频帧率
    int bitrate;//视频码率
}DoorDuCallFpsAndBitrate;

#pragma mark - DoorDuCallNetworkQuality(当前通话的网络质量)
typedef NS_ENUM(NSInteger, DoorDuCallNetworkQuality) {
    
    DoorDuCallNetworkQualityNone     = -1,//通话不存在
    DoorDuCallNetworkQualityGood     = 0,//好
    DoorDuCallNetworkQualityNormal   = 1,//普通
    DoorDuCallNetworkQualityBad      = 2,//差
};

#pragma mark - DoorDuCallLostDelayInfo(当前通话的语音视频延迟和丢包数据)
typedef struct DoorDuCallLostDelayInfo {
    
    int audioDelay;//语音延迟(ms)
    float audioLost;//语音丢包率(百分比％)
    int videoDelay;//视频延迟(ms)
    float videoLost;//视频丢包率(百分比％)
    
}DoorDuCallLostDelayInfo;

#endif

