//
//  DoorDuClient.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/30.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuOptions.h"
#import "DoorDuClientDelegate.h"
#import "DoorDuCallManagerDelegate.h"

@class DoorDuVideoView;
@class DoorDuUserInfo;
@interface DoorDuClient : NSObject

/**
 配置SDK初始化参数
 
 @param options sdk配置参数
 */
+ (void)configSDKOptions:(DoorDuOptions *)options;

/**注册clientDelegate*/
+ (void)registClientDelegate:(id<DoorDuClientDelegate>)delegate;
/**移除clientDelegate代理*/
+ (void)removeClientDelegate;
/**注册通话状态回调*/
+ (void)registCallManagerDelegate:(id<DoorDuCallManagerDelegate>)delegate;
/**移除通话状态管理*/
+ (void)removeCallManagerDelegate;


/**
 初始化DoorDuSDK

 @param userInfo 用户信息参数
 */
+ (void)initDoorDuSDKWithUserInfo:(DoorDuUserInfo *)userInfo;

/*!
 * @method  makeCallWithCallType
 * @brief   呼叫接口.
 * @param   callType                访问类型(kDoorDuCallHouseholdCalls:户户通,kDoorDuCallDoor:门禁机).
 * @param   mediaCallType           呼叫多媒体类型(语音/视频).
 * @param   localMicrophoneEnable   本地(主叫)是否开启话筒.
 * @param   localSpeakerEnable      本地(主叫)是否开启扬声器.
 * @param   localVideoView          本地(主叫)视频显示控件.
 * @param   localCameraOrientation  本地(主叫)摄像头方向(前后).
 * @param   remoteCallerID          远程(被叫)通话账号.
 * @param   remoteVideoView         远程(被叫)视频显示控件.
 * @param   fromRoomID              本地(主叫)房间ID<kDoorDuCallHouseholdCalls时不可以为空>.
 * @param   toRoomNO                远程(被叫)房间号<kDoorDuCallHouseholdCalls时不可以为空>.
 */
+ (void)makeCallWithCallType:(DoorDuCallType)callType
               mediaCallType:(DoorDuMediaCallType)mediaCallType
       localMicrophoneEnable:(BOOL)localMicrophoneEnable
          localSpeakerEnable:(BOOL)localSpeakerEnable
      localCameraOrientation:(DoorDuCallCameraOrientation)localCameraOrientation
              remoteCallerID:(NSString *)remoteCallerID
              localVideoView:(DoorDuVideoView *)localVideoView
             remoteVideoView:(DoorDuVideoView *)remoteVideoView
                  fromRoomID:(NSString *)fromRoomID
                    toRoomNo:(NSString *)toRoomNO;

/**
 * @method  answerCallWithCallType
 * @brief   接听电话.
 * @param   callType                访问类型(kDoorDuCallHouseholdCalls:户户通,kDoorDuCallDoor:门禁机).
 * @param   mediaCallType           呼叫多媒体类型(语音/视频).
 * @param   localVideoView          本地(被叫)视频显示控件.
 * @param   remoteVideoView         远程(主叫)视频显示控件.
 */
+ (void)answerCallWithCallType:(DoorDuCallType)callType
                 mediaCallType:(DoorDuMediaCallType)mediaCallType
              localMicrophoneEnable:(BOOL)localMicrophoneEnable
                 localSpeakerEnable:(BOOL)localSpeakerEnable
             localCameraOrientation:(DoorDuCallCameraOrientation)localCameraOrientation
                remoteCallerID:(NSString *)remoteCallerID
                     localVideoView:(DoorDuVideoView *)localVideoView
                    remoteVideoView:(DoorDuVideoView *)remoteVideoView;

/**是否正在通话中*/
+ (BOOL)isCalling;
/**是否存在通话*/
+ (BOOL)isExistCall;
/**拒接来电*/
+ (void)rejectCurrentCall;
/**挂断当前呼叫*/
+ (void)hangupCurrentCall;

/**切换话筒状态,enable为YES打开话筒、为NO关闭话筒*/
+ (BOOL)switchMicrophone:(BOOL)enable;
/**切换扬声器状态,enable为YES打开扬声器、为NO关闭扬声器*/
+ (BOOL)switchSpeaker:(BOOL)enable;

/**切换摄像头方向*/
+ (BOOL)switchCameraDirection;
/**视频模式切换到语言模式*/
+ (BOOL)switchVideoModeToAudioMode;
/**退出注销当前账号*/
+ (void)logoutCurrentAccount;

@end
