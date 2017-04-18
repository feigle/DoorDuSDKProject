//
//  SipEngineManager.h
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <SipEngineSDK/SipEngine.hxx>
#import <SipEngineSDK/SipEngineFactory.hxx>
#import <SipEngineSDK/MediaEngine.hxx>
#import <SipEngineSDK/MediaStream.hxx>
#import <SipEngineSDK/AudioStream.hxx>
#import <SipEngineSDK/VideoStream.hxx>
#import <SipEngineSDK/RTCVoiceEngine.hxx>
#import <SipEngineSDK/RTCVideoEngine.hxx>

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "DoorDuCommonTypes.h"
#import "SipEngineEventObserver.h"
#import "SipEngineDelegate.h"

#pragma mark - SipEngineManager_Connectivity(当前网络类型)
typedef NS_ENUM(NSInteger, SipEngineManager_Connectivity) {
    
    kSipEngineManager_Connectivity_WIFI  = 0,//无线局域网(WLAN)
    kSipEngineManager_Connectivity_WWAN  = 1,//无线广域网(蜂窝移动网络)
    kSipEngineManager_Connectivity_NONE  = 2,//未知网络类型(网络不可用)
};



#pragma mark - SipEngineManager_VideoType(视频类型)
typedef NS_ENUM(NSInteger, SipEngineManager_VideoType) {
    
    kSipEngineManager_VideoType_QVGA = 0,//QVGA(320x240)，15fps，256bitrate(默认)
    kSipEngineManager_VideoType_CIF  = 1,//CIF(352x288)，15fps，384bitrate
    kSipEngineManager_VideoType_VGA  = 2,//VGA(640x480)，17fps，512bitrate
    kSipEngineManager_VideoType_HD   = 3,//HD(1280x720)，20fps，1024bitrate
};



#pragma mark - SipEngineManager_VideoSize(视频尺寸)
typedef struct _SipEngineManager_VideoSize {
    
    int width;//宽度
    int height;//高度
    
}SipEngineManager_VideoSize;



#pragma mark - SipEngineManager_NotificationType(消息类型)
typedef NS_ENUM(NSInteger, SipEngineManager_NotificationType) {
    
    kSipEngineManager_NotificationType_AudioCall    = 0,//语音呼叫消息
    kSipEngineManager_NotificationType_VideoCall    = 1,//视频呼叫消息
    kSipEngineManager_NotificationType_TextMessage  = 2,//文字消息
    kSipEngineManager_NotificationType_FriendJoin   = 3,//加好友消息
};


#pragma mark - SipEngineManager_SipTransportType(SIP信令传输协议类型)
typedef NS_ENUM(NSInteger, SipEngineManager_SipTransportType) {
    
    kSipEngineManager_SipTransportType_UDP  = 0,//UDP
    kSipEngineManager_SipTransportType_TCP  = 1,//TCP
    kSipEngineManager_SipTransportType_TLS  = 2,//TLS
};



#pragma mark - 全局常量
//SIP管理器初始化完成，收到该消息后，才可以设置注册，呼叫，视频代理.
extern NSString *const kSipEngineManager_InitializeSuccess_Notification;



#pragma mark - SipEngineManager
@interface SipEngineManager : NSObject {
    
@private
    
    SCNetworkReachabilityContext _proxyReachabilityContext;//网络监控
    SCNetworkReachabilityRef _proxyReachability;//网络监控
    
    NSTimer *_mIterateTimer;//迭代定时器
    
    __unsafe_unretained id <SipEngineUIRegistrationDelegate> _registrationDelegate;//帐号注册状态回调代理
    __unsafe_unretained id <SipEngineUICallDelegate> _callDelegate;//通话状态回调代理
    __unsafe_unretained id <VideoFrameInfoDelegate> _videoFrameInfoDelegate;//视频状态回调
    
    SipEventObserver *_eventObserver;//sip事件观察者
    client::SipEngine *_sipEngine;//主接口对象
    client::Call *_currentCall;//呼叫对象
    client::SipProfile *_currentProfile;//SIP配置
    BOOL _isInitialized;//是否已初始化
    
@public
    
    SipEngineManager_Connectivity _connectivity;//当前网络类型
}

//注册，呼叫，视频代理对象
@property (assign, nonatomic, readwrite) id <SipEngineUIRegistrationDelegate> registrationDelegate;
@property (assign, nonatomic, readwrite) id <SipEngineUICallDelegate> callDelegate;
@property (assign, nonatomic, readwrite) id <VideoFrameInfoDelegate> videoFrameInfoDelegate;

/*!
 * @method  networkIsReachable
 * @brief   判断当前网络是否可用.
 * @reture  BOOL.
 */
- (BOOL)networkIsReachable;

/*!
 * @method  gainVideoSize
 * @brief   获取本地设定的视频尺寸.
 * @return  VideoSize_t.
 */
- (SipEngineManager_VideoSize *)gainVideoSize;

/*!
 * @method  gainBitrate
 * @brief   获取当前设定的码率.
 * @return  float.
 */
- (float)gainBitrate;

/*!
 * @method  gainFrameRate
 * @brief   获取当前设定的帧率.
 * @return  float.
 */
- (float)gainFrameRate;

/*!
 * @method  configureCurrentCall
 * @brief   设置当前的呼叫对象.
 */
-(void)configureCurrentCall:(client::Call *)call;

/*!
 * @method  inCalling
 * @brief   判断是否正在通话中.
 * @return  BOOL.
 */
- (BOOL)inCalling;

/*!
 * @method  gainIncomingCall
 * @brief   获取呼叫来电对象.
 * @return  client::Call.
 */
- (client::Call *)gainIncomingCall;

/*!
 * @method  haveIncomingCall
 * @brief   判断是否有来电呼叫.
 * @return  BOOL.
 */
- (BOOL)haveIncomingCall;

/*!
 * @method  answerIncomingCall:enableVideo:
 * @brief   接听来电呼叫.
 */
- (void)answerIncomingCall:(BOOL)enbaleAudio enableVideo:(BOOL)enbaleVideo;

/*!
 * @method  configureProxyReachability
 * @brief   设置网络状态监听代理.
 */
- (void)configureProxyReachability;

/*!
 * @method  initializeSipEngineManager
 * @brief   初始化SIP管理器.
 */
- (void)initializeSipEngineManager;

/*!
 * @method  configureLoudSpeakerStatus:
 * @brief   设置扬声器的状态.
 * @param   state   是否开启扬声器.
 */
- (void)configureLoudSpeakerStatus:(bool)state;

/*!
 * @method  runNetworkConnection
 * @brief   运行网络连接.
 */
- (void)runNetworkConnection;

/*!
 * @method  kickOffNetworkConnection
 * @brief   异步开启网络连接.
 */
- (void)kickOffNetworkConnection;

/*!
 * @method  loadConfigureWithSipAccount
 * @brief   加载用户账号配置.
 * @param   sipAccount          SIP用户名.
 * @param   sipAuthName         SIP认证用户名.
 * @param   sipPassword         SIP认证密码.
 * @param   sipDomain           SIP域名(domain).
 * @param   supportSipProxy     是否支持设置SIP代理服务器地址.
 * @param   sipProxy            SIP代理服务器地址.
 * @param   sipTransportType    SIP信令传输协议类型.
 * @param   supportWebrtc       开启WebRTC兼容模式，开启后可与Chrome，Firefox直接通信.
 * @param   supportRtcpFb       开启rtcp，兼容linphone, cisco vcse/mcu, fir,ccm,nack 等抗丢包特性.
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
- (void)loadConfigureWithSipAccount:(NSString *)sipAccount
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
 * @method  terminateSipEngine
 * @brief   销毁SipManager.
 */
- (void)terminateSipEngine;

/*!
 * @method  sharedInstance
 * @brief   创建线程安全单例.
 * @return  instancetype.
 */
+ (instancetype)sharedInstance;

/*!
 * @method  gainSipEngine
 * @brief   获取SipEngine对象.
 * @return  client::SipEngine.
 */
- (client::SipEngine *)gainSipEngine;

/*!
 * @method  gainCallManager
 * @brief   获取呼叫管理器对象.
 * @return  client::CallManager.
 */
- (client::CallManager *)gainCallManager;

/*!
 * @method  gainRegistrationManager
 * @brief   获取注册管理器对象.
 * @return  client::RegistrationManager.
 */
- (client::RegistrationManager *)gainRegistrationManager;

/*!
 * @method  gainSipProfileManager
 * @brief   获取sip账号管理器对象.
 * @return  client::SipProfileManager.
 */
- (client::SipProfileManager *)gainSipProfileManager;

/*!
 * @method  gainCurrentSipProfile
 * @brief   获取当前的sip配置.
 * @return  client::SipProfile.
 */
- (client::SipProfile *)gainCurrentSipProfile;

/*!
 * @method  gainRTCVoiceEngine
 * @brief   获取语音引擎对象.
 * @return  client::RTCVoiceEngine.
 */
- (client::RTCVoiceEngine *)gainRTCVoiceEngine;

/*!
 * @method  gainRTCVideoEngine
 * @brief   获取视频引擎对象.
 * @return  client::RTCVideoEngine.
 */
- (client::RTCVideoEngine *)gainRTCVideoEngine;

/*!
 * @method  registerSipAccount
 * @brief   注册sip账号.
 * @param   sipAccount          SIP用户名.
 * @param   sipAuthName         SIP认证用户名.
 * @param   sipPassword         SIP认证密码.
 * @param   sipDomain           SIP域名(domain).
 * @param   supportSipProxy     是否支持设置SIP代理服务器地址.
 * @param   sipProxy            SIP代理服务器地址.
 * @param   sipTransportType    SIP信令传输协议类型.
 * @param   supportWebrtc       开启WebRTC兼容模式，开启后可与Chrome，Firefox直接通信.
 * @param   supportRtcpFb       开启rtcp，兼容linphone, cisco vcse/mcu, fir,ccm,nack 等抗丢包特性.
 * @param   sipExpire           SIP注册过期时间(默认1800秒).
 * @param   sipDisplayName      SIP显示名.
 * @param   keepAlive           是否开启心跳保持.
 */
- (void)registerSipAccount:(NSString *)sipAccount
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
                 keepAlive:(BOOL)keepAlive;

/*!
 * @method  isSipRegisted
 * @brief   检查当前帐号SIP是否已注册成功
 * @return  BOOL
 **/
- (BOOL)isSipRegistered;

/*!
 * @method  deRegisterSipAccount
 * @brief   注销当前SIP账号.
 */
- (void)deRegisterSipAccount;

/*!
 * @method  refreshSipRegister
 * @brief   刷新已注册SIP账号，更新expire值.
 */
- (void)refreshSipRegister;

/*!
 * @method  makeCall:withVideoCall:displayName:
 * @brief   发起呼叫接口.
 * @param   number          被叫号码.
 * @param   video_enabled   是否开启视频.
 * @param   display_name    SIP URI 中的显示名称.
 * @return  client::Call.
 */
- (client::Call *)makeCall:(NSString *)number
             withVideoCall:(bool)video_enabled
               displayName:(NSString *)display_name;

/*!
 * @method  rejectCurrentCall
 * @brief   拒接来电(呼入/呼出，通话未建立).
 */
- (void)rejectCurrentCall;

/*!
 * @method  hangUpCurrentCall
 * @brief   挂断当前呼叫(呼入/呼出，通话已建立).
 */
- (void)hangUpCurrentCall;

/*!
 * @method  applicationDidEnterBackground
 * @brief   应用程序已进入后台状态，刷新SIP注册，准备长连接socket.
 */
- (void)applicationDidEnterBackground;

/*!
 * @method  applicationDidBecomeActive
 * @brief   应用程序已经进入活跃状态，刷新SIP注册.
 */
- (void)applicationDidBecomeActive;

/*!
 * @method  resetTransport
 * @brief   sip注册失败，错误原因为dns timeout(503)后需要执行该方法
 **/
- (void)resetTransport;

/*!
 * @method  configureDNS
 * @brief   配置DNS
 **/
- (void)configureDNS;

@end
