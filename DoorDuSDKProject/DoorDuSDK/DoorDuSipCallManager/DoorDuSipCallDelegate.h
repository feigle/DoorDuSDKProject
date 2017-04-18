//
//  DoorDuSipCallDelegate.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/30.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuClientEnum.h"
#import "DoorDuEnumType.h"

@protocol DoorDuSipCallDelegate <NSObject>

@optional
/**
  Sip正在注册
  */
- (void)sipIsRegistering;
/**
 Sip注册成功
 */
- (void)sipRegistrationSuccess;
/**
 Sip注销成功
 */
- (void)sipCanceledSuccessfully;
/**
 Sip注册失败
 */
- (void)sipRegistrationFailed:(DoorDuSipRegistErrorCode)errorCode errorMessage:(NSString *)errorMessage;
/**
 Sip新的呼叫（呼入/呼出）
 * @param   callDirection   呼叫方向.
 * @param   incomingCallType   呼叫来电类型.
 * @param   callerSipID   呼叫ID.
 * @param   remoteCallName   远处房间名字（只有Android和iOS有此名字）.
 */
- (void)sipNewCallDirection:(DoorDuCallDirection)callDirection
                incomingCallType:(DoorDuCurrentIncomingCallType)incomingCallType
                callerSipID:(NSString *)callerSipID
                remoteCallName:(NSString *)remoteCallName;
/**
 Sip呼叫被取消(呼入/呼出)
 * @param   callDirection   呼叫方向.
 */
- (void)sipTheCallIsCanceledDirection:(DoorDuCallDirection)callDirection;
/**
 Sip呼叫失败或错误（呼入/呼出）
 */
- (void)sipCallFailedOrWrong;
/**
 Sip呼叫被拒接
 */
- (void)sipTheCallWasRejected;
/**
 Sip正在建立连接（呼叫）
 */
- (void)sipCallConnectionIsBeingEstablished;
/**
 Sip被叫方振铃
 */
- (void)sipTheCalledPartyRings;
/**
 Sip呼叫接通（呼入/呼出）
 * @param   callDirection   呼叫方向.
 * @param   supportVideo    呼叫是否支持视频.
 * @param   supportData     呼叫是否支持数据.
 */
- (void)sipTheCallIsConnectedDirection:(DoorDuCallDirection)callDirection
                          supportVideo:(BOOL)supportVideo
                           supportData:(BOOL)supportData;;
/**
 Sip呼叫结束（呼入/呼出）
 * @param   callDirection   呼叫方向.
 */
- (void)sipTheCallEndsDirection:(DoorDuCallDirection)callDirection;
/**
 Sip正在设置呼叫暂停(呼入/呼出)
 * @param   callDirection   呼叫方向.
 */
- (void)sipACallPauseIsBeingSetDirection:(DoorDuCallDirection)callDirection;
/**
 Sip呼叫已暂停(呼入/呼出)
 * @param   callDirection   呼叫方向.
 */
- (void)sipTheCallIsPausedDirection:(DoorDuCallDirection)callDirection;
/**
 Sip正在设置终止呼叫暂停（呼入/呼出）
 * @param   callDirection   呼叫方向.
 */
- (void)sipSettingUpTerminationCallPauseDirection:(DoorDuCallDirection)callDirection;
/**
 Sip已终止呼叫暂停，恢复通话（呼入/呼出）
 * @param   callDirection   呼叫方向.
 */
- (void)sipTerminatedCallPauseResumeCallDirection:(DoorDuCallDirection)callDirection;
/**
 Sip呼叫远程设置正在更新（远程）
 */
- (void)sipCallRemoteSettingsAreBeingUpdated;
/**
 Sip呼叫远程设置已更新（远程）
 */
- (void)sipCallRemoteSettingsHaveBeenUpdated;
/**
 Sip呼叫转移被接受（呼入/呼出）
 * @param   callDirection   呼叫方向.
 */
- (void)sipCallTransferIsAcceptedDirection:(DoorDuCallDirection)callDirection;
/**
 Sip呼叫转移被拒绝（呼入/呼出）
 * @param   callDirection   呼叫方向.
 */
- (void)sipCallForwardingIsRejectedDirection:(DoorDuCallDirection)callDirection;
/**
 Sip媒体就绪（语音媒体流就绪）
 */
- (void)sipVoiceMediaStreamReady;
/**
 Sip媒体就绪（视频媒体流就绪）
 */
- (void)sipVideoMediaStreamReady;
/**
 Sip媒体就绪（数据媒体流就绪）
 */
- (void)sipDataMediaStreamReady;
/**
 Sip远程视频画面尺寸改变
 */
- (void)sipRemoteVideoScreenSizeChangeWidth:(NSInteger)width height:(NSInteger)height;
/**
 Sip远程视频码率和帧率
 */
- (void)sipRemoteVideoFps:(NSInteger)fps bitrate:(NSInteger)bitrate;
/**
 Sip本地视频码率和帧率
 */
- (void)sipLocalVideoFps:(NSInteger)fps bitrate:(NSInteger)bitrate;
/**
 *  Sip收到远程终端由视频模式切换到语音模式
 */
- (void)sipReceiveRemoteSwitchVideoModeToAudioMode;
///**
// *  Sip收到DTMF信号
// * @param   tone    dtmf信号.
// */
//- (void)sipReceiveTheDTMFSignalTone:(NSString *)tone;


@end









