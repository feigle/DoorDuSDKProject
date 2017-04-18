//
//  DoorDuCallStateManagerDelegate.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/11.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**通话状态管理*/
@protocol DoorDuCallManagerDelegate <NSObject>

#pragma mark - 必须实现的代理方法
@required
/**
 *  呼叫被取消(呼入/呼出)
 */
- (void)callDidTheCallIsCanceled;
/**
 * 呼叫失败或错误（呼入/呼出）
 */
- (void)callDidCallFailedOrWrong;
/**
 * 呼叫被拒接
 */
- (void)callDidTheCallWasRejected;
/**
 * 呼叫结束（呼入/呼出）
 */
- (void)callDidTheCallEnds;
/**
 * 呼叫接通（呼入/呼出）
 * @param   supportVideo    呼叫是否支持视频.
 * @param   supportData     呼叫是否支持数据.
 */
- (void)callDidTheCallIsConnectedSupportVideo:(BOOL)supportVideo
                                  supportData:(BOOL)supportData;
/**
 * 远程视频画面尺寸改变
 * @param   width    宽度.
 * @param   height   高度.
 */
- (void)callDidRemoteVideoScreenSizeChangeWidth:(NSInteger)width
                                         height:(NSInteger)height;
/**
 *  收到远程终端由视频模式切换到语音模式
 */
- (void)callDidReceiveRemoteSwitchVideoModeToAudioMode;
#pragma mark - 可选的代理方法
@optional
/**
 * 正在建立连接（呼叫）
 */
- (void)callDidCallConnectionIsBeingEstablished;
/**
 * 被叫方振铃
 */
- (void)callDidTheCalledPartyRings;
/**
 * 正在设置呼叫暂停(呼入/呼出)
 */
- (void)callDidACallPauseIsBeingSet;
/**
 * 呼叫已暂停(呼入/呼出)
 */
- (void)callDidTheCallIsPaused;
/**
 * 正在设置终止呼叫暂停（呼入/呼出）
 */
- (void)callDidSettingUpTerminationCallPause;
/**
 * 已终止呼叫暂停，恢复通话（呼入/呼出）
 */
- (void)callDidTerminatedCallPauseResume;
/**
 * 呼叫远程设置正在更新（远程）
 */
- (void)callDidCallRemoteSettingsAreBeingUpdated;
/**
 * 呼叫远程设置已更新（远程）
 */
- (void)callDidCallRemoteSettingsHaveBeenUpdated;
/**
 * 呼叫转移被接受（呼入/呼出）
 */
- (void)callDidCallTransferIsAccepted;
/**
 * 呼叫转移被拒绝（呼入/呼出）
 */
- (void)callDidCallForwardingIsRejected;
/**
 * 媒体就绪（语音媒体流就绪）
 */
- (void)callDidVoiceMediaStreamReady;
/**
 * 媒体就绪（视频媒体流就绪）
 */
- (void)callDidVideoMediaStreamReady;
/**
 * 媒体就绪（数据媒体流就绪）
 */
- (void)callDidDataMediaStreamReady;
/**
 * 远程视频帧率和码率
 * @param   fps       帧率.
 * @param   bitrate   码率.
 */
- (void)callDidRemoteVideoFps:(NSInteger)fps
                      bitrate:(NSInteger)bitrate;
/**
 * 本地视频帧率和码率
 * @param   fps       帧率.
 * @param   bitrate   码率.
 */
- (void)callDidLocalVideoFps:(NSInteger)fps
                     bitrate:(NSInteger)bitrate;


@end
