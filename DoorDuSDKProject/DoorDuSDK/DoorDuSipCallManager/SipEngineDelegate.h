//
//  SipEngineDelegate.h
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SipEngineSDK/Call.hxx>
#import <SipEngineSDK/CallManager.hxx>

#pragma mark - SipEngineUIRegistrationDelegate(SIP注册状态回调)
@protocol SipEngineUIRegistrationDelegate <NSObject>

/*!
 * @method  OnRegistrationProgress:
 * @brief   SIP账号正在注册.
 * @param   profile sip帐号信息.
 */
- (void)OnRegistrationProgress:(client::SipProfile *)profile;

/*!
 * @method  OnRegistrationSucess:
 * @brief   SIP账号注册成功.
 * @param   profile sip帐号信息.
 */
- (void)OnRegistrationSucess:(client::SipProfile *)profile;

/*!
 * @method  OnRegistrationCleared:
 * @brief   SIP账号注销成功.
 * @param   profile sip帐号信息.
 */
- (void)OnRegistrationCleared:(client::SipProfile *)profile;

/*!
 * @method  OnRegisterationFailed:errorCode:errorReason:
 * @brief   SIP账号注册失败.
 * @param   profile     sip帐号信息.
 * @param   errorCode   错误码.
 * @param   errorReason 错误信息.
 */
- (void)OnRegisterationFailed:(client::SipProfile *)profile
                    errorCode:(NSInteger)errorCode
                  errorReason:(NSString *)errorReason;

@end



#pragma mark - SipEngineUICallDelegate(呼叫状态回调)
@protocol SipEngineUICallDelegate <NSObject>

/*!
 * @method  OnNewCall:direction:callerID:supportVideo:
 * @brief   新的呼叫(呼入/呼出).
            收到本地或者远程呼叫开始的信息.
 * @param   call            呼叫对象.
 * @param   direction       呼叫类型(呼入/呼出).
 * @param   callerID        呼叫ID.
 * @param   supportVideo    呼叫是否开启视频模式.
 */
- (void)OnNewCall:(client::Call *)call
        direction:(client::Call::Direction)direction
         callerID:(NSString *)callerID
     supportVideo:(BOOL)supportVideo;

/*!
 * @method  OnCallCancel:
 * @brief   呼叫被取消(呼入/呼出).
 * @param   call    呼叫对象.
 */
- (void)OnCallCancel:(client::Call *)call;

/*!
 * @method  OnCallFailed:errorCode:errorReason:
 * @brief   呼叫失败或错误(呼入/呼出).
 * @param   call        呼叫对象.
 * @param   errorCode   错误码.
 * @param   errorReason 错误原因.
 */
- (void)OnCallFailed:(client::Call *)call
           errorCode:(NSInteger)errorCode
         errorReason:(NSString *)errorReason;

/*!
 * @method  OnCallRejected:errorCode:errorReason:
 * @brief   呼叫被拒绝(呼出).
 * @param   call        呼叫对象.
 * @param   errorCode   错误码.
 * @param   errorReason 错误原因.
 */
- (void)OnCallRejected:(client::Call *)call
             errorCode:(NSInteger)errorCode
           errorReason:(NSString *)errorReason;

/*!
 * @method  OnCallProcessing:
 * @brief   正在建立连接(呼出).
            早期媒体，在通话之前建立媒体流，被叫方收到彩铃.
 * @param   call    呼叫对象.
 */
- (void)OnCallProcessing:(client::Call *)call;

/*!
 * @method  OnCallRinging:
 * @brief   被叫方振铃(呼出).
 * @param   call    呼叫对象.
 */
- (void)OnCallRinging:(client::Call *)call;

/*!
 * @method  OnCallConnected:supportVideo:supportData:
 * @brief   呼叫接通(呼入/呼出).
 * @param   call            呼叫对象.
 * @param   supportVideo    呼叫是否支持视频.
 * @param   supportData     呼叫是否支持数据.
 */
- (void)OnCallConnected:(client::Call *)call
           supportVideo:(BOOL)supportVideo
            supportData:(BOOL)supportData;

/*!
 * @method  OnCallEnded:
 * @brief   呼叫结束(呼入/呼出).
 * @param   call    呼叫对象.
 */
- (void)OnCallEnded:(client::Call *)call;

/*!
 * @method  OnCallPausing:
 * @brief   正在设置呼叫暂停(呼入/呼出).
 * @param   call    呼叫对象.
 */
- (void)OnCallPausing:(client::Call *)call;

/*!
 * @method  OnCallPaused:
 * @brief   呼叫已暂停(呼入/呼出).
 * @param   call    呼叫对象.
 */
- (void)OnCallPaused:(client::Call *)call;

/*!
 * @method  OnCallResuming:
 * @brief   正在设置终止呼叫暂停(呼入/呼出).
 * @param   call    呼叫对象.
 */
- (void)OnCallResuming:(client::Call *)call;

/*!
 * @method  OnCallResumed:
 * @brief   已终止呼叫暂停，恢复通话(呼入/呼出).
 * @param   call    呼叫对象.
 */
- (void)OnCallResumed:(client::Call *)call;

/*!
 * @method  OnCallRemoteUpdating:
 * @brief   呼叫远程设置正在更新(远程).
 * @param   call    呼叫对象.
 */
- (void)OnCallRemoteUpdating:(client::Call *)call;

/*!
 * @method  OnCallRemoteUpdated:
 * @brief   呼叫远程设置已更新(远程).
 * @param   call    呼叫对象.
 */
- (void)OnCallRemoteUpdated:(client::Call *)call;

/*!
 * @method  OnCallReferAccepted:
 * @brief   呼叫转移被接受(呼入/呼出).
 * @param   call    呼叫对象.
 */
- (void)OnCallReferAccepted:(client::Call *)call;

/*!
 * @method  OnCallReferRejected:
 * @brief   呼叫转移被拒绝(呼入/呼出).
 * @param   call    呼叫对象.
 */
- (void)OnCallReferRejected:(client::Call *)call;

/*!
 * @method  OnMediaStreamReady:mediaType:
 * @brief   媒体就绪.
            包含"音频/视频/数据"三种媒体类型(呼入/呼出).
 * @param   call    呼叫对象.
 * @param   mediaType    媒体类型(视频/音频/数据).
 */
- (void)OnMediaStreamReady:(client::Call *)call mediaType:(client::CallMediaStreamType)mediaType;

/*!
 * @method  OnReceiveDtmf:tone:
 * @brief   收到远程DTMF信号.
 * @param   call    呼叫对象.
 * @param   tone    dtmf信号.
 */
- (void)OnReceiveDtmf:(client::Call *)call tone:(NSString *)tone;

@end



#pragma mark - VideoFrameInfoDelegate(视频通话回调)
@protocol VideoFrameInfoDelegate <NSObject>

/*!
 * @method  IncomingFrameWidth:height:
 * @brief   远程视频画面尺寸改变(视频通话中).
 * @param   width   对方视频画面尺寸宽度.
 * @param   height  对方视频画面尺寸高度.
 */
- (void)IncomingFrameWidth:(NSInteger)width height:(NSInteger)height;

/*!
 * @method  IncomingFps:bitrate:
 * @brief   远程视频帧率和码率改变(视频通话中).
 * @param   fps     对方视频帧率.
 * @param   bitrate 对方视频码率.
 */
- (void)IncomingFps:(NSInteger)fps bitrate:(NSInteger)bitrate;

/*!
 * @method  OutgoingFps:bitrate:
 * @brief   本地视频帧率和码率改变(视频通话中).
 * @param   fps     对方视频帧率.
 * @param   bitrate 对方视频码率.
 */
- (void)OutgoingFps:(NSInteger)fps bitrate:(NSInteger)bitrate;

@end
