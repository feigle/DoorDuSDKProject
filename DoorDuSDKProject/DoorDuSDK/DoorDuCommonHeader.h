//
//  DoorDuCommonHeader.h
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#ifndef DoorDuCommonHeader_h
#define DoorDuCommonHeader_h

/**当前SDK是否对外部，内部调试时，选择 0 */
#define DoorDuSDKReleaseStatus 0  //0 :测试, 1:发布，

//-------------------打印日志-------------------------
//模式下打印日志,当前行
#if DoorDuSDKReleaseStatus
#   define DoorDuLog(...)
#else
#   define DoorDuLog(fmt, ...) NSLog((@"[DoorDuSDK DEBUG]: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif


//AES加密密钥和IV
#define DOORDU_AES_SECRET_KEY               @"9a55af5de6062f8d"
#define DOORDU_AES_IV                       @"1234567890123456"

/*!
 * DoorDuSDK.bundle中默认响铃文件名称.
 */
#define DOORDU_INCOMING_AUDIO   @"incoming.wav"//来电
#define DOORDU_OUTGOING_AUDIO   @"outgoing.wav"//呼出
#define DOORDU_MESSAGE_AUDIO    @"message.wav"//消息
#define DOORDU_BUTTON_AUDIO     @"button.wav"//按键
#define DOORDU_BUSY_AUDIO       @"busy.wav"//按键
#define DOORDU_DOORBUSY_AUDIO   @"doorisbusy.wav"//按键
/* 应用程序资源目录中默认响铃文件名称 */
#define DOORDU_RING_AUDIO   @"ring.wav"//来电

/*!
 * sip默认配置参数.
 */
#define DOORDU_DEFAULT_SIP_PROFILE  "main_profile"
#define DOORDU_DEFAULT_USERDB_NAME  "user.db"

#define DOORDU_DEFAULT_STUN_SERVER  @"stun.hj.doordu.com"
#define DOORDU_DEFAULT_STUN_PORT    (5061)

/*!
 * 系统类型.
 */
#if defined(__arm64__)
#define DOORDU_SDK_PLATFORM_TYPE    "64bit"
#else
#define DOORDU_SDK_PLATFORM_TYPE    "32bit"
#endif

#endif
