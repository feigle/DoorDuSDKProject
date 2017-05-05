//
//  DoorDuClientEnum.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/1.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#ifndef DoorDuClientEnum_h
#define DoorDuClientEnum_h
/**
    开发环境
 */
typedef NS_ENUM(NSUInteger, DoorDuSDKMode)
{
    DoorDuTestMode          = 0,    /*测试模式*/
    DoorDuPreDistributeMode = 1,    /*预发布环境*/
    DoorDuDistributeMode    = 2     /*发布环境*/
};
/**
    API接口异常返回的状态码
 */
typedef NS_ENUM(NSInteger, DoorDuApiRespCode) {
    kDoorDuApiRespCodeUnknown             = -1,     /*未知*/
    kDoorDuApiRespCodeConnectivityNone    = -1009,  /*网络不可用*/
    kDoorDuApiRespCodeRequestTimeOut      = -1001,  /*请求超时*/
    kDoorDuApiRespCode401 = 401,    /*SDK授权认证失败*/
    kDoorDuApiRespCode402 = 402,    /*SDK未注册*/
    kDoorDuApiRespCode403 = 403,    /*无权访问(例如操作其他sdk下的用户)*/
    kDoorDuApiRespCode404 = 404,    /*未找到资源*/
    kDoorDuApiRespCode426 = 426,    /*用户登录状态过期(App端需要退出登录)*/
    kDoorDuApiRespCode500 = 500,    /*服务器错误*/
    kDoorDuApiRespCode10400   = 10400,  /*参数错误*/
    kDoorDuApiRespCode10401   = 10401,  /*基本认证失败*/
    kDoorDuApiRespCode10403   = 10403,  /*无权访问（例如操作其他sdk下的用户）*/
    kDoorDuApiRespCode10404   = 10404,  /*未找到资源*/
    kDoorDuApiRespCode10426   = 10426,  /*用户登录状态过期(App端需要退出登录)*/
    kDoorDuApiRespCode10500   = 10500,  /*服务器内部错误*/
    kDoorDuApiRespCode11000   = 11000,  /*某房间对该用户的授权已经到期*/
    kDoorDuApiRespCode11001   = 11001,  /*手机号码不合法*/
    kDoorDuApiRespCode11002   = 11002,  /*账号或密码错误*/
    kDoorDuApiRespCode11003   = 11003,  /*第三方账号已经绑定*/
    kDoorDuApiRespCode11004   = 11004,  /*用户不存在或未注册*/
    kDoorDuApiRespCode11005   = 11005,  /*广告数据为空*/
    kDoorDuApiRespCode11006   = 11006,  /*门禁主机不存在或已被解绑*/
    kDoorDuApiRespCode11007   = 11007,  /*门禁主机已经被替换*/
    kDoorDuApiRespCode11008   = 11008,  /*门禁主机不在线*/
    kDoorDuApiRespCode11009   = 11009,  /*门禁主机没有响应*/
    kDoorDuApiRespCode11010   = 11010,  /*房间不存在*/
    kDoorDuApiRespCode11011   = 11011,  /*验证码不正确*/
    kDoorDuApiRespCode11012   = 11012,  /*密码长度需要大于5位小于31位*/
    kDoorDuApiRespCode11013   = 11013,  /*设备唯一标识(deviceID)超出100字符长度*/
    kDoorDuApiRespCode11014   = 11014,  /*设备与用户绑定的数量达到上限*/
    kDoorDuApiRespCode11015   = 11015,  /*未找到来电图片*/
    kDoorDuApiRespCode11016   = 11016,  /*该小区不允许授权用户*/
    kDoorDuApiRespCode11017   = 11017,  /*授权人数已经达到上限*/
    kDoorDuApiRespCode11018   = 11018,  /*不能授权给自己*/
    kDoorDuApiRespCode11019   = 11019,  /*业主不能被删除*/
    kDoorDuApiRespCode11020   = 11020,  /*用户已注册*/
    kDoorDuApiRespCode11021   = 11021,  /*短信发送失败*/
    kDoorDuApiRespCode11022   = 11022,  /*未找到开门密码*/
    kDoorDuApiRespCode11023   = 11023,  /*新密码不能与旧密码相同*/
    kDoorDuApiRespCode11024   = 11024,  /*新密码与确认密码需保持一致*/
    kDoorDuApiRespCode11025   = 11025,  /*未找到信息公告*/
    kDoorDuApiRespCode11026   = 11026,  /*未找到广告信息*/
    kDoorDuApiRespCode11027   = 11027,  /*第三方登录标识未与我方用户绑定*/
    kDoorDuApiRespCode11028   = 11028,  /*字符串中包含敏感字符*/
    kDoorDuApiRespCode11029   = 11029,  /*第三方账号已经绑定过用户*/
    kDoorDuApiRespCode11030   = 11030,  /*门禁主机名称已经存在*/
    kDoorDuApiRespCode11031   = 11031,  /*开始日期不能小于当天*/
    kDoorDuApiRespCode11032   = 11032,  /*结束日期不能小于当天*/
    kDoorDuApiRespCode11033   = 11033,  /*该用户已绑定第三方账号*/
    kDoorDuApiRespCode11034   = 11034,  /*被叫设备不在线*/
    kDoorDuApiRespCode11035   = 11035,  /*手机号码已被授权*/
};

/**
    通话方向
 */
typedef NS_ENUM(NSInteger, DoorDuCallDirection) {
    kDoorDuCallDirectionNone      = -1,     /*呼叫不存在*/
    kDoorDuCallDirectionUnknown   = 0,      /*未知类型*/
    kDoorDuCallDirectionIncoming  = 1,      /*呼入*/
    kDoorDuCallDirectionOutgoing  = 2,      /*呼出*/
};
/**
    呼叫多媒体类型
 */
typedef NS_ENUM(NSInteger, DoorDuMediaCallType) {
    kDoorDuMediaCallTypeNone    = -1,    /*呼叫不存在*/
    kDoorDuMediaCallTypeUnknown = 0,     /*未知类型*/
    kDoorDuMediaCallTypeAudio   = 1,     /*语音呼叫*/
    kDoorDuMediaCallTypeVideo   = 2,     /*视频呼叫*/
};

/**
    呼叫终端类型
 */
typedef NS_ENUM(NSInteger, DoorDuCallType) {
    kDoorDuCallNone  = -1,  /*不存在*/
    kDoorDuCallEachFamilyAccess  = 0,  /*户户通*/
    kDoorDuCallDoor = 1,  /*呼叫门禁*/
};

typedef NS_ENUM(NSInteger, DoorDuCallStatus) {
    kDoorDuUnkown  = -1,
    kDoorDuNewCall = 0,  /**< 新呼叫*/
    kDoorDuCancel,       /**< 呼叫被取消*/
    kDoorDuFailed,       /**< 失败或错误*/
    kDoorDuRejected,     /**< 呼叫被拒绝*/
    kDoorDuEarlyMedia,   /**< 收到彩铃*/
    kDoorDuRinging,      /**< 对方振铃*/
    kDoorDuAnswered,     /**< 呼叫接通*/
    kDoorDuHangup,       /**< 呼叫结束*/
    kDoorDuPausing,      /**< 设置保持*/
    kDoorDuPaused,       /**< 呼叫被保持*/
    kDoorDuResuming,     /**< 设置恢复*/
    kDoorDuResumed,      /**< 呼叫保持解除*/
    kDoorDuUpdating,     /**< 设置更新*/
    kDoorDuUpdated,      /**< 呼叫更新*/
    kDoorDuReferAccepted,/**< 呼叫转移被接受*/
    kDoorDuReferRejected,/**< 呼叫转移被拒绝*/
};

/**
    当前来电类型
 */
typedef NS_ENUM(NSInteger, DoorDuCurrentIncomingCallType) {
    kDoorDuCurrentIncomingCallTypeNone                          = -1,   /*呼叫(呼入)不存在*/
    kDoorDuCurrentIncomingCallTypeUnknown                       = 0,    /*未知*/
    kDoorDuCurrentIncomingCallTypeDoor                          = 1,    /*门禁主机来电*/
    kDoorDuCurrentIncomingCallTypeAndroid                       = 2,    /*Android应用终端(安卓手机App)来电*/
    kDoorDuCurrentIncomingCallTypeIOS                           = 3,    /*iOS应用终端(iOS手机App)来电*/
    kDoorDuCurrentIncomingCallTypeIndoor                        = 4,    /*室内机终端*/
    kDoorDuCurrentIncomingCallTypeCard                          = 5,    /*门禁卡*/
    kDoorDuCurrentIncomingCallTypeVilla                         = 6,    /*别墅机*/
    kDoorDuCurrentIncomingCallTypePropertyManagement            = 7,    /*物业管理机*/
    kDoorDuCurrentIncomingCallTypePropertyManagementPlatform    = 8,    /*物业管理平台*/
    kDoorDuCurrentIncomingCallTypeBox86                         = 9,    /*86盒*/
};
/**
    视频通话时，本地摄像头方法
 */
typedef NS_ENUM(NSInteger, DoorDuCallCameraOrientation) {
    kDoorDuCallCameraOrientationBack   = 0,     /*后摄像头*/
    kDoorDuCallCameraOrientationFront  = 1,     /*前摄像头*/
};
/**
    视频通话时，视频流类型
 */
typedef NS_ENUM(NSInteger, DoorDuCallVideoStreamDirection) {
    kDoorDuCallVideoStreamDirectionSendRecv  = 1,//发送&接收
    kDoorDuCallVideoStreamDirectionSendOnly  = 2,//只发送
    kDoorDuCallVideoStreamDirectionRecvOnly  = 3,//只接收
};


#endif /* DoorDuClientEnum_h */
