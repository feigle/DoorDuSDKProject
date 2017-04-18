//
//  SipEngineEventObserver.h
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <SipEngineSDK/SipEngine.hxx>
#import <SipEngineSDK/SipProfile.hxx>
#import <SipEngineSDK/RegistrationManager.hxx>
#import <SipEngineSDK/CallManager.hxx>
#import <SipEngineSDK/VideoStream.hxx>

/*!
 * sip事件监听实现，将消息发送给SipEventObserver，
 * 再通过SipEngineDelegate分发给UI.
 */
class SipEventObserver
: public client::RegistrationObserver
, public client::CallStateObserver
, public client::VideoStreamObserver {
    
public:
    SipEventObserver(void *ui,client::SipEngine *sip);
    ~SipEventObserver();
    
/** 注册事件回调 */
public:
    //注册正在处理
    virtual void OnRegistrationProgress(client::SipProfile *profile);
    //注册成功
    virtual void OnRegistrationSuccess(client::SipProfile *profile);
    //注销成功
    virtual void OnRegistrationCleared(client::SipProfile *profile);
    //注册失败，并返回错误代码，错误原因
    virtual void OnRegistrationFailed(client::SipProfile *profile
                                      , int code
                                      , const char *reason);
    
/** 呼叫事件回调 */
public:
    //呼叫状态变化
    virtual void OnCallStateChange(client::Call *call, client::Call::CallState state);
    //收到DTMF信号
    virtual void OnDtmf(client::Call *call, const char *tone);
    //媒体流状态变化
    virtual void OnMediaStreamUpdate(client::Call *call
                                     , client::CallMediaStreamType type
                                     , client::Call::MediaDirection dir);
    
/** 视频通话事件事件回调 */
public:
    //远端视频尺寸变化
    virtual void IncomingFrameSizeChanged(const int video_channel
                                          ,	unsigned short width
                                          , unsigned short height);
    //远端视频码率变化
    virtual void IncomingRate(const int video_channel,
                              const unsigned int framerate,
                              const unsigned int bitrate);
    //本端发送码率变化
    virtual void OutgoingRate(const int video_channel,
                              const unsigned int framerate,
                              const unsigned int bitrate);
    
private:
    void *ui_ptr_;
    client::SipEngine *sip_engine_;
};
