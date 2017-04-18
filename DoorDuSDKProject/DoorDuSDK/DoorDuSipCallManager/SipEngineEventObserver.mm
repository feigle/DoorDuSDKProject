//
//  SipEngineEventObserver.m
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "SipEngineEventObserver.h"
#import "SipEngineManager.h"
#import "DoorDuCommonHeader.h"

SipEventObserver::SipEventObserver(void *ui_ptr, client::SipEngine *sip_engine):ui_ptr_(ui_ptr), sip_engine_(sip_engine) {
    
}

SipEventObserver::~SipEventObserver() {
    
}



//########################## SIP注册状态回调模块 ##########################
#pragma mark -
#pragma mark (SIP注册正在处理)
void SipEventObserver::OnRegistrationProgress(client::SipProfile *profile) {
    
    DoorDuLog(@"***SIP注册正在处理:(profile = %s)***", profile->profile_name);
    
    if (ui_ptr_ && ((__bridge SipEngineManager *)ui_ptr_).registrationDelegate != nil) {
        
        [((__bridge SipEngineManager *)ui_ptr_).registrationDelegate OnRegistrationProgress:profile];
    }
}

#pragma mark -
#pragma mark (SIP注册成功)
void SipEventObserver::OnRegistrationSuccess(client::SipProfile *profile) {
    
    DoorDuLog(@"***SIP注册成功:(profile = %s)***", profile->profile_name);
    
    if (ui_ptr_ && ((__bridge SipEngineManager *)ui_ptr_).registrationDelegate != nil) {
        
        [((__bridge SipEngineManager *)ui_ptr_).registrationDelegate OnRegistrationSucess:profile];
    }
}

#pragma mark -
#pragma mark (SIP注销成功)
void SipEventObserver::OnRegistrationCleared(client::SipProfile *profile) {
    
    DoorDuLog(@"***SIP注销成功:(profile = %s)***", profile->profile_name);
    
    if (ui_ptr_ && ((__bridge SipEngineManager *)ui_ptr_).registrationDelegate != nil) {
        
        [((__bridge SipEngineManager *)ui_ptr_).registrationDelegate OnRegistrationCleared:profile];
    }
}

#pragma mark -
#pragma mark (SIP注册失败，并返回错误代码，错误原因)
void SipEventObserver::OnRegistrationFailed(client::SipProfile *profile, int code, const char *reason) {
    
    DoorDuLog(@"***SIP注册失败:(profile = %s, code = %d, reason = %s)***", profile->profile_name, code, reason);
    
    NSString *errorReason = [NSString stringWithUTF8String:reason];
    if (ui_ptr_ && ((__bridge SipEngineManager *)ui_ptr_).registrationDelegate != nil) {
        
        [((__bridge SipEngineManager *)ui_ptr_).registrationDelegate OnRegisterationFailed:profile
                                                                                 errorCode:code
                                                                               errorReason:errorReason];
    }
}



//########################## 呼叫状态回调模块 ##########################
#pragma mark -
#pragma mark (呼叫通话状态更新)
void SipEventObserver::OnCallStateChange(client::Call *call, client::Call::CallState state) {
    
    DoorDuLog(@"***呼叫通话状态更新:(call = %s, state = %s, code = %d)***", call->toString(), call->CallStateName(state),call->GetErrorCode());
    
    switch (state) {
            
        /*!
         * 新的呼叫(呼入/呼出).
         * 收到本地或者远程呼叫开始的信息.
         */
        case client::Call::kNewCall: {
            
            //获取当前呼叫ID
            NSString *callerID = [NSString stringWithUTF8String:call->caller_id()];
            
            //来电呼叫
            if(call->direction() == client::Call::kIncoming) {
                
                //NSLog(@"***收到呼叫(呼入)***");
                char buf[128];
                DoorDuLog(@"---------%d",call->GetDeviceType(buf));
                if(call->GetDeviceType(buf)) {
                    
                    DoorDuLog(@"device = %s", buf);
                    const client::ExtensionHeaderMap & ext_hdr_map = call->get_extension_header_map();
                    DoorDuLog(@"ext_hdr_map size = %lu", ext_hdr_map.size());
                    
                    client::ExtensionHeaderMap::const_iterator it = ext_hdr_map.begin();
                    
                    while (it != ext_hdr_map.end()) {
                        
                        DoorDuLog(@"key %s, value %s", it->first.c_str(), it->second.c_str());
                        it++;
                    }
                }
                
            }else {
                
                //NSLog(@"***收到呼叫(呼出)***");
            }
            
            //呼叫支持视频，则注册视频流监控回调
            if(call->support_video()) {
                
                client::VideoStream *video_stream = call->media_stream()->video_stream();
                video_stream->RegisterVideoStreamObserver(this);
            }
            
            //设置呼叫对象
            [[SipEngineManager sharedInstance] configureCurrentCall:call];
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager*)ui_ptr_).callDelegate OnNewCall:call
                                                                    direction:call->direction()
                                                                     callerID:callerID
                                                                 supportVideo:call->support_video()];
            }
            
        }break;
            
        /** 呼叫被取消(呼入/呼出) */
        case client::Call::kCancel: {
            
            //NSLog(@"***呼叫被取消***");
            
            //设置呼叫对象
            [[SipEngineManager sharedInstance] configureCurrentCall:nil];
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallCancel:call];
            }
            
            //取消本地推送消息
            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
            }
            
        }break;
            
        /** 呼叫失败或错误(呼入/呼出) */
        case client::Call::kFailed: {
            
            //NSLog(@"***呼叫失败或错误***");
            
            //设置呼叫对象
            [[SipEngineManager sharedInstance] configureCurrentCall:nil];
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                //获取错误码
                NSInteger errorCode = call->GetErrorCode();
                
                //获取错误原因
                NSString *errorReason = [NSString stringWithUTF8String:call->GetErrorReason()];
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallFailed:call
                                                                        errorCode:errorCode
                                                                      errorReason:errorReason];
            }
            
            //取消本地推送消息
            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
            }
            
        }break;
            
        /** 呼叫被拒绝(呼出) */
        case client::Call::kRejected: {
            
            //NSLog(@"***呼叫被拒绝***");
            
            //设置呼叫对象
            [[SipEngineManager sharedInstance] configureCurrentCall:nil];
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                //获取错误码
                NSInteger errorCode = call->GetErrorCode();
                
                //获取错误原因
                NSString *errorReason = [NSString stringWithUTF8String:call->GetErrorReason()];
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallRejected:call
                                                                          errorCode:errorCode
                                                                        errorReason:errorReason];
            }
            
            //取消本地推送消息
            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
            }
            
        }break;
            
        /*!
         * 正在建立连接(呼出).
         * 早期媒体，在通话之前建立媒体流，被叫方收到彩铃.
         */
        case client::Call::kEarlyMedia: {
            
            //NSLog(@"***正在建立连接，早期媒体，在通话之前建立媒体流，被叫方收到彩铃***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
            
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallProcessing:call];
            }
            
        }break;
            
        /** 被叫方振铃(呼出) */
        case client::Call::kRinging: {
            
            //NSLog(@"***被叫方振铃***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallRinging:call];
            }
            
        }break;
        
        /** 呼叫接通(呼入/呼出) */
        case client::Call::kAnswered: {
            
            //NSLog(@"***呼叫接通***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallConnected:call
                                                                    supportVideo:call->support_video()
                                                                     supportData:call->support_data()];
            }
            
        }break;
            
        /** 呼叫结束(呼入/呼出) */
        case client::Call::kHangup: {
            
            //NSLog(@"***呼叫结束***");
            
            //设置呼叫对象
            [[SipEngineManager sharedInstance] configureCurrentCall:nil];
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallEnded:call];
            }
            
        }break;
            
        /** 正在设置呼叫暂停(呼入/呼出) */
        case client::Call::kPausing: {
            
            //NSLog(@"***正在设置呼叫暂停***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallPausing:call];
            }
            
        }break;
         
        /** 呼叫已暂停(呼入/呼出) */
        case client::Call::kPaused: {
            
            //NSLog(@"***呼叫已暂停***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallPaused:call];
            }
            
        }break;
         
        /** 正在设置终止呼叫暂停(呼入/呼出) */
        case client::Call::kResuming: {
            
            //NSLog(@"***正在恢复呼叫通话***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallResuming:call];
            }
            
        }break;
         
        /** 已终止呼叫暂停，恢复通话(呼入/呼出) */
        case client::Call::kResumed: {
            
            //NSLog(@"***呼叫通话已恢复***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallResumed:call];
            }
            
        }break;
        
        /** 呼叫远程设置正在更新(远程) */
        case client::Call::kUpdating: {
            
            //NSLog(@"***呼叫远程设置正在更新(远程)***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallRemoteUpdating:call];
            }
            
        }break;
         
        /** 呼叫远程设置已更新(远程) */
        case client::Call::kUpdated: {
            
            //NSLog(@"***呼叫远程设置已更新(远程)***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallRemoteUpdated:call];
            }
            
        }break;
            
        /** 呼叫转移被接受(呼入/呼出) */
        case client::Call::kReferAccepted: {
            
            //NSLog(@"***呼叫转移被接受(呼入/呼出)***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallReferAccepted:call];
            }
            
        }break;
            
        /** 呼叫转移被拒绝(呼入/呼出) */
        case client::Call::kReferRejected: {
            
            //NSLog(@"***呼叫转移被拒绝(呼入/呼出)***");
            
            //调用代理
            if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
                
                [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnCallReferRejected:call];
            }
            
        }break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark (媒体就绪，包含"音频/视频/数据"三种媒体类型)
void SipEventObserver::OnMediaStreamUpdate(client::Call *call, client::CallMediaStreamType type, client::Call::MediaDirection dir) {
    
    switch (type) {
            
        case client::CallMediaStreamType::kCallAudioStream:{
            
            //NSLog(@"***媒体就绪类型:(音频)***");
            
        }break;
            
        case client::CallMediaStreamType::kCallVideoStream:{
            
            //NSLog(@"***媒体就绪类型:(视频)***");
            
        }break;
            
        case client::CallMediaStreamType::kCallDataStream:{
            
            //NSLog(@"***媒体就绪类型:(数据)***");
            
        }break;
            
        default:{
            
            //NSLog(@"***媒体就绪类型:(未知)***");
            
        }break;
    }
    
    switch (dir) {
            
        case client::Call::MediaDirection::kNone:{
            
            //NSLog(@"***媒体就绪接收方向:(未知)***");
            
        }break;
            
        case client::Call::MediaDirection::kSendRecv:{
            
            //NSLog(@"***媒体就绪接收方向:(双向收发)***");
            
        }break;
            
        case client::Call::MediaDirection::kSendOnly:{
            
            //NSLog(@"***媒体就绪接收方向:(仅发送)***");
            
        }break;
            
        case client::Call::MediaDirection::kRecvOnly:{
            
            //NSLog(@"***媒体就绪接收方向:(仅接收)***");
            
        }break;
            
        case client::Call::MediaDirection::kInActive:{
            
            //NSLog(@"***媒体就绪接收方向:(暂时不可用)***");
            
        }break;
            
        default:{
            
            //NSLog(@"***媒体就绪接收方向:(未知)***");
            
        }break;
    }
    
    if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
        
        [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnMediaStreamReady:call mediaType:type];
    }
}

#pragma mark -
#pragma mark (收到远程DTMF信号)
void SipEventObserver::OnDtmf(client::Call *call, const char *tone) {
    
    DoorDuLog(@"***收到DTMF信号:(call = %p, tone = %s)***", call, tone);
    
    if (ui_ptr_ && (((__bridge SipEngineManager *)ui_ptr_).callDelegate != nil)) {
        
        [((__bridge SipEngineManager *)ui_ptr_).callDelegate OnReceiveDtmf:call tone:[NSString stringWithUTF8String:tone]];
    }
}



//########################## 视频通话回调模块 ##########################
#pragma mark -
#pragma mark (远程视频尺寸变化)
void SipEventObserver::IncomingFrameSizeChanged(const int video_channel, unsigned short width, unsigned short height) {
    
    DoorDuLog(@"***远程视频尺寸变化:(width = %hu, height = %hu)***", width, height);
    
    if ( ui_ptr_ && ((__bridge SipEngineManager*)ui_ptr_).videoFrameInfoDelegate != nil) {
        
        [((__bridge SipEngineManager*)ui_ptr_).videoFrameInfoDelegate IncomingFrameWidth:width height:height];
    }
}

#pragma mark -
#pragma mark (远程视频帧率码率变化)
void SipEventObserver::IncomingRate(const int video_channel, const unsigned int framerate, const unsigned int bitrate) {
    
    DoorDuLog(@"***远程视频帧率码率变化:(fps = %u, bitrate = %u)***", framerate, bitrate);
    
    if (ui_ptr_ && ((__bridge SipEngineManager *)ui_ptr_).videoFrameInfoDelegate != nil) {
        
        [((__bridge SipEngineManager *)ui_ptr_).videoFrameInfoDelegate IncomingFps:framerate bitrate:bitrate];
    }
}

#pragma mark -
#pragma mark (本地发送帧率码率变化)
void SipEventObserver::OutgoingRate(const int video_channel, const unsigned int framerate, const unsigned int bitrate) {
    
    DoorDuLog(@"***本地视频帧率码率变化:(fps = %u, bitrate = %u)***", framerate, bitrate);
    
    if (ui_ptr_ && ((__bridge SipEngineManager *)ui_ptr_).videoFrameInfoDelegate != nil) {
        
        [((__bridge SipEngineManager*)ui_ptr_).videoFrameInfoDelegate OutgoingFps:framerate bitrate:bitrate];
    }
}


