//
//  DoorDuSipCallManager.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/30.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuSipCallDelegate.h"
#import "SipEngineManager.h"

@class DoorDuVideoView;

/**
 用于SIP管理，内部是个单例
 */
@interface DoorDuSipCallManager : NSObject

/**添加代理*/
+ (void)registrationDelegate:(id<DoorDuSipCallDelegate>)delegate;
/**移除代理*/
+ (void)removeDelegate;
/*!
 * @method  registerSipAccount
 * @brief   注册SIP账号.
 * @param   sipAccount          SIP用户名.
 * @param   sipAuthName         SIP认证用户名.
 * @param   sipPassword         SIP认证密码.
 * @param   sipDomain           SIP域名(domain).
 * @param   supportSipProxy     是否支持设置SIP代理服务器地址.
 * @param   sipProxy            SIP代理服务器地址.
 * @param   sipTransportType    SIP信令传输协议类型.
 * @param   supportWebrtc       开启WebRTC兼容模式，开启后可与Chrome，Firefox直接通信(ICE模式，用于支持p2p模式).
 * @param   supportRtcpFb       开启rtcp，兼容linphone, cisco vcse/mcu, fir,ccm,nack 等抗丢包特性(p2p模式不需要开启).
 * @param   sipExpire           SIP注册过期时间(默认1800秒).
 * @param   sipDisplayName      SIP显示名.
 * @param   keepAlive           是否开启心跳保持.
 * @param   videoType           视频画面尺寸类型.
 * @param   stunServer          stun服务器(用于穿透功能).
 * @param   stunServerPort      stun服务器端口.
 * @param   turnServer          turn服务器.
 * @param   turnServerPort      turn服务器端口.
 * @param   turnUserName        turn服务器用户名.
 * @param   turnPassword        turn服务器密码.
 */
+ (void)registerSipAccount:(NSString *)sipAccount
               sipAuthName:(NSString *)sipAuthName
               sipPassword:(NSString *)sipPassword
                 sipDomain:(NSString *)sipDomain
           supportSipProxy:(BOOL)supportSipProxy
                  sipProxy:(NSString *)sipProxy
          sipTransportType:(SipEngineManager_SipTransportType)sipTransportType
             supportWebrtc:(BOOL)supportWebrtc
             supportRtcpFb:(BOOL)supportRtcpFb
                 sipExpire:(NSInteger)sipExpire
            sipDisplayName:(NSString *)sipDisplayName
                 keepAlive:(BOOL)keepAlive
                 videoType:(SipEngineManager_VideoType)videoType
                stunServer:(NSString *)stunServer
            stunServerPort:(NSString *)stunServerPort
                turnServer:(NSString *)turnServer
            turnServerPort:(NSString *)turnServerPort
              turnUserName:(NSString *)turnUserName
              turnPassword:(NSString *)turnPassword;
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
 */
+ (void)makeCallWithCallType:(DoorDuCallType)callType
               mediaCallType:(DoorDuMediaCallType)mediaCallType
       localMicrophoneEnable:(BOOL)localMicrophoneEnable
          localSpeakerEnable:(BOOL)localSpeakerEnable
              localVideoView:(DoorDuVideoView *)localVideoView
      localCameraOrientation:(DoorDuCallCameraOrientation)localCameraOrientation
              remoteCallerID:(NSString *)remoteCallerID
             remoteVideoView:(DoorDuVideoView *)remoteVideoView;
/**
 * @method  answerSipCallWithMediaCallType
 * @brief   接听SIP电话.
 * @param   mediaCallType           呼叫类型(语音/视频).
 * @param   localVideoView          本地(被叫)视频显示控件.
 * @param   remoteVideoView         远程(主叫)视频显示控件.
 */
+ (void)answerSipCallWithMediaCallType:(DoorDuMediaCallType)mediaCallType
                 localMicrophoneEnable:(BOOL)localMicrophoneEnable
                    localSpeakerEnable:(BOOL)localSpeakerEnable
                localCameraOrientation:(DoorDuCallCameraOrientation)localCameraOrientation
                        localVideoView:(DoorDuVideoView *)localVideoView
                       remoteVideoView:(DoorDuVideoView *)remoteVideoView;


/**退出、注销当前账号*/
+ (void)logoutSipAccount;
/**刷新当前账号.*/
+ (void)refreshSipRegister;
/**获取当前对话对方的SIP账号*/
+ (NSString *)getCurrentSipAccount;
/**获取登录者的SIP账号*/
+ (NSString *)getUserSipAccount;
/**是否正在通话中*/
+ (BOOL)isCalling;
/**是否存在通话*/
+ (BOOL)isExistCall;
/**检测当前SIP是否注册成功*/
+ (BOOL)checkSipRegisteredSussess;
/**暂停当前通话*/
+ (void)pauseCurrentCall;
/**恢复当前通话*/
+ (void)resumeCurrentCall;
/**拒接来电*/
+ (void)rejectCurrentCall;
/**挂断当前呼叫*/
+ (void)hangupCurrentCall;
/**切换话筒状态,enable为YES打开话筒、为NO关闭话筒*/
+ (BOOL)switchMicrophone:(BOOL)enable;
/**切换扬声器状态,enable为YES打开扬声器、为NO关闭扬声器*/
+ (BOOL)switchSpeaker:(BOOL)enable;
/**开关视频，这个接口暂时去掉，用不到，用到的时候再加上*/
/**摄像头是否可用*/
+ (BOOL)enableCamera:(BOOL)enable;
/**切换摄像头方向*/
+ (BOOL)switchCameraDirection;
/**切换媒体流（视频流）模式*/
+ (BOOL)switchVideoStreamDirection:(DoorDuCallVideoStreamDirection)videoStreamDirection;
/**视频模式切换到语言模式（内部发送DTMF操作）*/
+ (BOOL)switchVideoModeToAudioMode;
/**销毁,不对外提供*/

@end
