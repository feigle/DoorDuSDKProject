//
//  SipEngineManager.m
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "SipEngineManager.h"
#import "DoorDuCommonHeader.h"
#import "DoorDuCommonTypes.h"
#import "DoorDuAudioPlayer.h"

#import <AVFoundation/AVAudioSession.h>

#import <SipEngineSDK/SipEngine.hxx>
#import <SipEngineSDK/SipProfileManager.hxx>

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <time.h>
#include <netdb.h>
#include <stdio.h>
#import "DoorDuLog.h"

//SipEngineManager静态单例
static SipEngineManager *theSipEngineManager = nil;

//网络状态
static bool kNetworkReachable = false;

//SipEngine全局配置对象
static client::Config s_config;

/*!
 * 默认视频尺寸、码率、帧率.
 * (1)QVGA(320x240)，15fps，256bitrate(默认)
 * (2)VGA(640x480)，17fps，512bitrate
 * (3)HD(1280x720)，20fps，1024bitrate
 * (5)CIF(352x288)，15fps，384bitrate
 */
static SipEngineManager_VideoSize s_video_size = {320, 240};
static float s_bitrate = 256.f;
static int s_fps = 15;

//当前网络状态监控回调
void networkReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    
    DoorDuLogDebug(@"Network connection flag [%x]", flags);
    
    SipEngineManager *lSipEngineMgr = (__bridge SipEngineManager *)info;
    SCNetworkReachabilityFlags networkDownFlags = kSCNetworkReachabilityFlagsConnectionRequired
                                                    | kSCNetworkReachabilityFlagsConnectionOnTraffic
                                                    | kSCNetworkReachabilityFlagsConnectionOnDemand;
    
    if ([[SipEngineManager sharedInstance] gainSipEngine]) {
        
        if ((flags == 0) | (flags & networkDownFlags)) {
            
            //异步开启网络连接
            [[SipEngineManager sharedInstance] kickOffNetworkConnection];
            
            //网络不可用
            ((__bridge SipEngineManager *) info)->_connectivity = kSipEngineManager_Connectivity_NONE;
            
            //通知底层网络不可用
            [[SipEngineManager sharedInstance] gainRegistrationManager]->SetNetworkReachable(false);
            
            //标记网络不可用
            kNetworkReachable = NO;
            DoorDuLogDebug(@"Network connectivity [DOWN] !");
        }else {
            
            //判断网络类型
            SipEngineManager_Connectivity newConnectivity = flags & kSCNetworkReachabilityFlagsIsWWAN ? kSipEngineManager_Connectivity_WWAN : kSipEngineManager_Connectivity_WIFI;
            if (lSipEngineMgr->_connectivity == kSipEngineManager_Connectivity_NONE) {
                
                //connectivity changed from none
                [[SipEngineManager sharedInstance] gainRegistrationManager]->SetNetworkReachable(false);
                [[SipEngineManager sharedInstance] gainRegistrationManager]->SetNetworkReachable(true);
                
                //第一次设置网络可用，通知注册器启动所有账号注册
                kNetworkReachable = YES;
                DoorDuLogDebug(@"Network connectivity [UP] !");
                
            }else if (lSipEngineMgr->_connectivity != newConnectivity) {
                
                //connectivity has changed, need to foce register
                [[SipEngineManager sharedInstance] gainRegistrationManager]->SetNetworkReachable(false);
                [[SipEngineManager sharedInstance] gainRegistrationManager]->SetNetworkReachable(true);
                
                //网络切换销毁所有旧注册，以及网络连接，重新注册所有账号
                kNetworkReachable = YES;
                DoorDuLogDebug(@"Network connectivity now [Changed] !");
            }
            
            lSipEngineMgr->_connectivity = newConnectivity;
            DoorDuLogDebug(@"New network connectivity  of type [%s]", (newConnectivity == kSipEngineManager_Connectivity_WIFI ? "wifi" : "wwan"));
        }
    }
}



/*!
 * SIP管理器初始化完成.
 * 收到该消息后，才可以设置注册，呼叫，视频代理.
 */
NSString *const kSipEngineManager_InitializeSuccess_Notification = @"kSipEngineManager_InitializeSuccess_Notification";



#pragma mark - SipEngineManager
@implementation SipEngineManager

@synthesize registrationDelegate = _registrationDelegate;
@synthesize callDelegate = _callDelegate;
@synthesize videoFrameInfoDelegate = _videoFrameInfoDelegate;

#pragma mark -
#pragma mark (构造)
- (id)init {
    self = [super init];
    if (self) {
        _sipEngine = nil;
        _eventObserver = nil;
        _currentCall = nil;
        _currentProfile = nil;
        _isInitialized = NO;
    }
    return self;
}

#pragma mark -
#pragma mark (判断当前网络是否可用)
- (BOOL)networkIsReachable {
    
    return kNetworkReachable;
}

#pragma mark -
#pragma mark (获取当前设定的视频尺寸)
- (SipEngineManager_VideoSize *)gainVideoSize {
    
    return &s_video_size;
}

#pragma mark -
#pragma mark (获取当前设定的码率)
- (float)gainBitrate {
    
    return s_bitrate;
}

#pragma mark -
#pragma mark (获取当前设定的帧率)
- (float)gainFrameRate {
    
    return s_fps;
}

#pragma mark -
#pragma mark (设置当前的呼叫对象)
-(void)configureCurrentCall:(client::Call *)call {
    
    _currentCall = call;
}

#pragma mark -
#pragma mark (判断是否正在通话中)
- (BOOL)inCalling {
    
    if (_sipEngine
        && _currentCall
        && (_currentCall->call_state() == client::Call::kAnswered
            || _currentCall->call_state() == client::Call::kUpdated)) {
        
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark (获取来电呼叫对象)
- (client::Call *)gainIncomingCall {
    
    if (_sipEngine
        && _currentCall
        && (_currentCall->direction() == client::Call::kIncoming)) {
        
        return _currentCall;
    }
    
    return NULL;
}

#pragma mark -
#pragma mark (判断是否有来电呼叫)
- (BOOL)haveIncomingCall {
    
    if(_sipEngine
       && _currentCall
       && (_currentCall->direction() == client::Call::kIncoming)
       && (_currentCall->call_state() == client::Call::kNewCall
           || _currentCall->call_state() == client::Call::kRinging)) {
        
           return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark (接听来电呼叫)
- (void)answerIncomingCall:(BOOL)enbaleAudio enableVideo:(BOOL)enbaleVideo {
    
    if(_sipEngine
       && _currentCall
       && (_currentCall->direction() == client::Call::kIncoming)
       && (_currentCall->call_state() != client::Call::kAnswered)) {
        
        _currentCall->Accept(enbaleAudio, enbaleVideo);
    }
}

#pragma mark -
#pragma mark (设置网络状态监听代理)
- (void)configureProxyReachability {
    
    //默认Google提供的免费DNS服务器的IP地址
    const char *nodeName = "www.apple.com";
    
    if (_proxyReachability) {
        
        DoorDuLogDebug(@"Cancelling old network reachability");
        SCNetworkReachabilityUnscheduleFromRunLoop(_proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(_proxyReachability);
        _proxyReachability = nil;
    }
    
    _proxyReachability = SCNetworkReachabilityCreateWithName(nil, nodeName);
    _proxyReachabilityContext.info = (__bridge void *)self;
    
    //initial state is network off should be done as soon as possible
    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(_proxyReachability, &flags)) {
        
        DoorDuLogDebug(@"Cannot get reachability flags");
    };
    
    CFRunLoopRef main_run_loop = [[NSRunLoop mainRunLoop] getCFRunLoop];
    
    networkReachabilityCallBack(_proxyReachability, flags, (__bridge void *)self);
    
    if (!SCNetworkReachabilitySetCallback(_proxyReachability, (SCNetworkReachabilityCallBack)networkReachabilityCallBack,&_proxyReachabilityContext)){
        
        DoorDuLogDebug(@"Cannot register reachability cb");
    };
    
    if(!SCNetworkReachabilityScheduleWithRunLoop(_proxyReachability, main_run_loop, kCFRunLoopDefaultMode)){
        
        DoorDuLogDebug(@"Cannot register schedule reachability cb");
    };
}

//+ (void)load
//{
//    //初始化SipEngineManager
//    [[SipEngineManager sharedInstance] initializeSipEngineManager];
//}

#pragma mark -
#pragma mark (初始化SIP管理器)
- (void)initializeSipEngineManager {
    
    if(_isInitialized) {
     
        return;
    }
    
    //默认网络不可用状态
    _connectivity = kSipEngineManager_Connectivity_NONE;
    
    /*!
     * 预防长连接导致的终端崩溃(socket忽略SIGPIPE).
     * 终端挂起时，socket连接不会断开，但是服务器会关闭这个连接，
     * 如果终端继续通过断开的socket发送消息，send函数会触发SIGPIPE异常导致终端崩溃.
     * 需要在send的时候检测到服务器已经关闭连接，进行重新连接.
     * 正常情况下send函数返回-1表示发送失败，但是在iOS上SIGPIPE在send返回之前就终止了进程，
     * 所以我们需要忽略SIGPIPE，让send正常返回-1，然后重新连接服务器.
     */
    //该方法在真机测试仍然触发崩溃
    {
        signal(SIGPIPE, SIG_IGN);
    }
    
    //TCP，TLS连接模式
    {
        //int serverSocket = socket(AF_INET, SOCK_STREAM, 0);
        //int set = 1;
        //setsockopt(serverSocket, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
    }
    
    //UDP连接模式
    {
        //int serverSocket = socket(AF_INET, SOCK_DGRAM, 0);
        //int set = 1;
        //setsockopt(serverSocket, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
    }
    
    if(!_sipEngine) {
        
        //设置本地监听端口
        s_config.transport.tcp_port = 0;
        s_config.transport.tls_port = 0;
        s_config.transport.udp_port = 0;
        s_config.transport.use_ipv4 = true;
        s_config.transport.use_ipv6 = false;
        
        //设置音频编码默认配置(此处要和服务器支持的语音编码同步，否则可能导致第一次通话失败)
        strcpy(s_config.media_options.audio_codecs, "g729,pcma,pcmu");
        
        //开启日志系统
        s_config.log_settings.log_on = true;
        s_config.log_settings.log_level = client::Config::Log::None;//调试使用Stack
        
        //创建SipEngine对象
        _sipEngine = client::SipEngineFactory::Create(s_config);
        
        //sip事件监听实现，将消息发送给SipEventObserver，再通过SipEngineDelegate分发给UI
        if(_eventObserver == nil) {
            
            _eventObserver = new SipEventObserver((__bridge void *)self, _sipEngine);
        }
        
        //设置流媒体超时时间
        s_config.media_options.rtp_packet_timeout_ms = 10000;
        
        //sipEngine初始化
        _sipEngine->Initialize();
               
        //设置账号注册事件监听
        _sipEngine->GetRegistrationManager()->RegisterRegistrationObserver(_eventObserver);
        
        //设置呼叫通话状态事件监听
        _sipEngine->GetCallManager()->RegisterCallStateObserver(_eventObserver);
        
        //设置网络状态监听
        [self configureProxyReachability];
        
        //使用Timer poll SIP Engine主事件循环(用于监控SIP管理器回调事件)
        _mIterateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f
                                                          target:self
                                                        selector:@selector(handleTimer)
                                                        userInfo:nil
                                                         repeats:YES];
        
        //设置帐号注册状态回调代理
        [self setRegistrationDelegate:nil];
        
        //设置呼叫通话状态回调代理
        [self setCallDelegate:nil];
        
        //设置用户代理名称
        NSString *user_agent = [NSString stringWithFormat:@"iOS Client 1.0 (%@ %s)", [DoorDuCommonTypes gainPlatformString], DOORDU_SDK_PLATFORM_TYPE];
        strcpy(s_config.user_agent, [user_agent UTF8String]);
        
        //设置最大并发呼叫
        client::CallManager *callManager = _sipEngine->GetCallManager();
        callManager->SetMaxConcurrentCall(1);
    }
    
    _isInitialized = YES;
    
    //发送SIP管理器初始化完成消息
    [[NSNotificationCenter defaultCenter] postNotificationName:kSipEngineManager_InitializeSuccess_Notification
                                                        object:nil
                                                      userInfo:nil];
}

#pragma mark -
#pragma mark (循环处理事件，用于监控SIP管理器回调事件)
- (void)handleTimer {
    
    if(_sipEngine) {
        
        _sipEngine->RunEventLoop();
    }
}

#pragma mark -
#pragma mark (设置扬声器的状态)
- (void)configureLoudSpeakerStatus:(bool)state {
    
    client::RTCVoiceEngine *voiceEngine = [self gainRTCVoiceEngine];
    voiceEngine->SetLoudspeakerStatus(state);
}

#pragma mark -
#pragma mark (运行网络连接)
- (void)runNetworkConnection {
    
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.0.200", 15000, nil, &writeStream);
    CFWriteStreamOpen (writeStream);
    const char *buff = "hello";
    CFWriteStreamWrite (writeStream, (const UInt8 *)buff, strlen(buff));
    CFWriteStreamClose (writeStream);
}

#pragma mark -
#pragma mark (异步开启网络连接)
- (void)kickOffNetworkConnection {
    
    //start a new thread to avoid blocking the main ui in case of peer host failure
    [NSThread detachNewThreadSelector:@selector(runNetworkConnection)
                             toTarget:theSipEngineManager
                           withObject:nil];
}

#pragma mark -
#pragma mark (加载Sip账号配置)
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
                       turnPassword:(NSString *)turnPassword {
    
    //注册sip帐号，sip帐号(sipAccount)，sip密码(sipPassword)，sip域名(sipDomain)必须存在
    if (sipAccount
        && [sipAccount length]
        && sipDomain
        && [sipDomain length]
        && sipPassword) {
        
        //注册前先注销SIP配置
        //[self deRegisterSipAccount];
        
        //注册SIP帐号
        [self registerSipAccount:sipAccount
                     sipAuthName:sipAuthName
                     sipPassword:sipPassword
                       sipDomain:sipDomain
                 supportSipProxy:supportSipProxy
                        sipProxy:sipProxy
                sipTransportType:sipTransportType
                   supportWebrtc:supportWebrtc
                   supportRtcpFb:supportRtcpFb
                       sipExpire:sipExpire
                  sipDisplayName:sipDisplayName
                       keepAlive:keepAlive];
    }
    
    //设置视频尺寸，码率，帧率
    switch (videoType) {
            
        case kSipEngineManager_VideoType_QVGA: {
            
            s_video_size.width = 320;
            s_video_size.height = 240;
            s_bitrate = 256.0f;
            s_fps = 15;
            
        }break;
            
        case kSipEngineManager_VideoType_CIF: {
            
            s_video_size.width = 352;
            s_video_size.height = 288;
            s_bitrate = 384.0f;
            s_fps = 15;
            
        }break;
            
        case kSipEngineManager_VideoType_VGA: {
            
            s_video_size.width = 640;
            s_video_size.height = 480;
            s_bitrate = 512.0f;
            s_fps = 17;
            
        }break;
            
        case kSipEngineManager_VideoType_HD: {
            
            s_video_size.width = 1280;
            s_video_size.height = 720;
            s_bitrate = 1024.0f;
            s_fps = 20;
            
        }break;
            
        default: {
            
            //默认QVGA
            s_video_size.width = 320;
            s_video_size.height = 240;
            s_bitrate = 256.0f;
            s_fps = 15;
            
        }break;
    }
    
    //配置STUN服务器，用于穿透
    if(stunServer && [stunServer length]) {
        
        strcpy(s_config.media_options.stun_server, [stunServer UTF8String]);
    }
    
    //配置STUN服务器端口
    if (stunServerPort && [stunServerPort length]) {
        
        s_config.media_options.stun_port = [stunServerPort integerValue];
    }
    
    //配置TURN服务器(turn服务器和名称必须存在才配置)
    if(turnServer
       && [turnServer length]
       && turnUserName
       && [turnUserName length]) {
        
        //配置TURN服务器
        strcpy(s_config.media_options.stun_server, [turnServer UTF8String]);
        
        //配置TURN服务器端口
        if (turnServerPort && [turnServerPort length]) {
            
            s_config.media_options.stun_port = [turnServerPort integerValue];
        }
        
        //配置TURN服务器用户名
        if (turnUserName && [turnUserName length]) {
            
            strcpy(s_config.media_options.turn_username, [turnUserName UTF8String]);
        }
        
        //配置TURN服务器密码
        if (turnPassword && [turnPassword length]) {
            
            strcpy(s_config.media_options.turn_password, [turnPassword UTF8String]);
        }
    }
    
    //配置音频编码
    BOOL audioCodecISAC = NO;
    BOOL audioCodecOPUS = NO;
    BOOL audioCodecG722 = NO;
    BOOL audioCodecG729 = YES;
    BOOL audioCodecGSM = NO;
    BOOL audioCodecILBC = NO;
    BOOL audioCodecPCMU = YES;
    BOOL audioCodecPCMA = YES;
    
    std::string audio_codecs;
    if (audioCodecG729) {
        
        if(audio_codecs.length() > 0) {
            
            audio_codecs += ",";
        }
        
        audio_codecs += "g729";
    }
    
    if (audioCodecGSM) {
        
        if(audio_codecs.length() > 0) {
            
            audio_codecs += ",";
        }
        
        audio_codecs += "GSM";
    }
    
    if (audioCodecILBC) {
        
        if(audio_codecs.length() > 0) {
            
            audio_codecs += ",";
        }
        
        audio_codecs += "ILBC";
    }
    
    if (audioCodecPCMU) {
        
        if(audio_codecs.length() > 0) {
            
            audio_codecs += ",";
        }
        
        audio_codecs += "PCMU";
    }
    
    if (audioCodecPCMA) {
        
        if(audio_codecs.length() > 0) {
            
            audio_codecs += ",";
        }
        
        audio_codecs += "PCMA";
    }
    
    if (audioCodecISAC) {
        
        if (audio_codecs.length() > 0) {
           
            audio_codecs += ",";
        }
        
        audio_codecs += "isac";
    }
    
    if (audioCodecOPUS) {
        
        if(audio_codecs.length() > 0) {
            
            audio_codecs += ",";
        }
        
        audio_codecs += "opus";
    }
    
    if (audioCodecG722) {
        
        if(audio_codecs.length() > 0) {
            
            audio_codecs += ",";
        }
        
        audio_codecs += "g722";
    }
    
    DoorDuLogDebug(@"Set Audio Codecs : %s", audio_codecs.c_str());
    strcpy(s_config.media_options.audio_codecs, audio_codecs.c_str());
    
    //配置视频编码
    BOOL videoCodecVP8 = NO;
    BOOL videoCodecVP9 = NO;
    BOOL videoCodecH264 = YES;
    BOOL videoCodecRED = NO;
    BOOL videoCodecULPFEC = NO;
    BOOL videoCodecRTX = NO;
    
    std::string video_codecs;
    if(videoCodecVP8) {
        
        video_codecs += "VP8";
    }
    
    if(videoCodecVP9) {
        
        if(video_codecs.length() > 0) {
            
            video_codecs += ",";
        }
        
        video_codecs += "VP9";
    }
    
    if(videoCodecH264) {
        
        if(video_codecs.length() > 0) {
            
            video_codecs += ",";
        }
        
        video_codecs += "H264";
    }
    
    if(videoCodecRED) {
        
        if(video_codecs.length() > 0) {
            
            video_codecs += ",";
        }
        
        video_codecs += "red";
    }
    
    if(videoCodecULPFEC) {
        
        if(video_codecs.length() > 0) {
            
            video_codecs += ",";
        }
        
        video_codecs += "ulpfec";
    }
    
    if(videoCodecRTX) {
        
        if(video_codecs.length() > 0) {
            
            video_codecs += ",";
        }
        
        video_codecs += "rtx";
    }
    
    DoorDuLogDebug(@"Set Video Codecs : %s", video_codecs.c_str());
    strcpy(s_config.media_options.video_codecs, video_codecs.c_str());
    
    //获取语音引擎
    client::RTCVoiceEngine *voe = _sipEngine->GetMediaEngine()->GetRTCVoiceEngine();
    
    //启用语音自动增益控制
    voe->SetAGCMode(1, client::RTCVoiceEngine::kAgcAdaptiveDigital);
    
    //启动语音降噪模块
    voe->SetNSMode(1, client::RTCVoiceEngine::kNsHighSuppression);
}

#pragma mark -
#pragma mark (销毁SipEngine)
- (void)terminateSipEngine {
    
    if (_mIterateTimer) {
        
        [_mIterateTimer invalidate];
        _mIterateTimer = nil;
    }
    
    if (_sipEngine) {
        
        _sipEngine->Terminate();
        
        if (_eventObserver) {
            
            delete _eventObserver;
            _eventObserver = nil;
        }
        
        client::SipEngineFactory::Delete(_sipEngine);
        
        _sipEngine = nil;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop(_proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    CFRelease(_proxyReachability);
    _proxyReachability = nil;
}

#pragma mark -
#pragma mark (创建线程安全单例)
+ (instancetype)sharedInstance {
    
    if (!theSipEngineManager) {
        
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            
            theSipEngineManager = [[SipEngineManager alloc] init];
        });
    }
    
    return theSipEngineManager;
}

#pragma mark -
#pragma mark (获取SipEngine对象)
- (client::SipEngine *)gainSipEngine {
    
    return _sipEngine;
}

#pragma mark -
#pragma mark (获取呼叫管理器对象)
- (client::CallManager *)gainCallManager {
    
    return _sipEngine->GetCallManager();
}

#pragma mark -
#pragma mark (获取注册管理器对象)
- (client::RegistrationManager *)gainRegistrationManager {
    
    return _sipEngine->GetRegistrationManager();
}

#pragma mark -
#pragma mark (获取sip账号管理器对象)
- (client::SipProfileManager *)gainSipProfileManager {
    
    return _sipEngine->GetSipProfileManager();
}

#pragma mark -
#pragma mark (获取当前的sip配)
- (client::SipProfile *)gainCurrentSipProfile {
    
    //获取sip账号管理器对象
    client::SipProfileManager *sip_profile_manager = [self gainSipProfileManager];
    
    //选取默认的SipProfile
    _currentProfile = sip_profile_manager->selectSipProfile(DOORDU_DEFAULT_SIP_PROFILE);
    if (!_currentProfile) {
        
        _currentProfile = sip_profile_manager->createSipProfile(DOORDU_DEFAULT_SIP_PROFILE);
    }
    
    return _currentProfile;
}

#pragma mark -
#pragma mark (获取语音引擎对象)
- (client::RTCVoiceEngine *)gainRTCVoiceEngine {
    
    client::MediaEngine *media_engine = _sipEngine->GetMediaEngine();
    
    return media_engine->GetRTCVoiceEngine();
}

#pragma mark -
#pragma mark (获取视频引擎对象)
- (client::RTCVideoEngine *)gainRTCVideoEngine {
    
    client::MediaEngine *media_engine = _sipEngine->GetMediaEngine();
    
    return media_engine->GetRTCVideoEngine();
}

#pragma mark -
#pragma mark (注册SIP账号完整方法)
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
                 keepAlive:(BOOL)keepAlive {
    
    //sip帐号(sipAccount)，sip密码(sipPassword)，sip域名(sipDomain)必须存在
    if (!sipAccount
        || ![sipAccount length]
        || !sipDomain
        || ![sipDomain length]
        || !sipPassword) {
        
        return;
    }
    
    //获取sip账号管理器对象
    client::SipProfileManager *sip_profile_manager = [self gainSipProfileManager];
    
    //获取注册管理器对象
    client::RegistrationManager *registration_manager = [self gainRegistrationManager];
    
    //选取默认的SipProfile
    _currentProfile = sip_profile_manager->selectSipProfile(DOORDU_DEFAULT_SIP_PROFILE);
    if (!_currentProfile) {
        
        _currentProfile = sip_profile_manager->createSipProfile(DOORDU_DEFAULT_SIP_PROFILE);
    }
    
    //设置sip用户名
    _currentProfile->set_username([sipAccount UTF8String]);
    
    //设置sip认证用户名
    if(sipAuthName && [sipAuthName length]) {
        
        _currentProfile->set_auth_name([sipAuthName UTF8String]);
        
    }else {
        
        _currentProfile->set_auth_name([sipAccount UTF8String]);
    }
    
    //设置sip显示名(DisplayName)
    if(sipDisplayName && [sipDisplayName length]) {
        
        _currentProfile->set_display_name([sipDisplayName UTF8String]);
    }
    
    //设置sip认证密码
    _currentProfile->set_password([sipPassword UTF8String]);
    
    //设置sip域名
    _currentProfile->set_domain([sipDomain UTF8String]);
    
    //设置sip代理服务器地址
    if(supportSipProxy && sipProxy && [sipProxy length]) {
        
        _currentProfile->set_proxy([sipProxy UTF8String]);
    }
    
    //设置sip注册过期时间(默认1800秒)
    if (sipExpire) {
        
        _currentProfile->register_expire = (int)sipExpire;
    }
    
    //WebRTC兼容模式，或P2P通话模式
    _currentProfile->webrtc_mode = supportWebrtc;
    
    //设置RTCP-FB模式, 同时打开 ccm,fir,pli,nack
    _currentProfile->rtcp_fb = supportRtcpFb;
    
    //设置sip信令传输协议类型(默认TLS)
    switch (sipTransportType) {
            
        case kSipEngineManager_SipTransportType_UDP: {
            
            _currentProfile->trans_type = client::kUDP;
            
        }break;
            
        case kSipEngineManager_SipTransportType_TCP: {
            
            _currentProfile->trans_type = client::kTCP;
            
        }break;
            
        case kSipEngineManager_SipTransportType_TLS: {
            
            _currentProfile->trans_type = client::kTLS;
            
        }break;
            
        default: {
            
            _currentProfile->trans_type = client::kTLS;
            
        }break;
    }
    
    //是否开启心跳保持
    _currentProfile->keepalive = keepAlive;
    
    //是否发送注册消息
    _currentProfile->send_register = true;
    
    //使用Profile文件发送注册消息
    registration_manager->MakeRegister(_currentProfile);
}

#pragma mark -
#pragma mark (检查sip是否在线)
- (BOOL)isSipRegistered {
    
    client::RegistrationManager *registration_manager = [self gainRegistrationManager];
    if (_currentProfile) {
        
        return registration_manager->ProfileIsRegistered(_currentProfile);
    }
    
    return NO;
}

#pragma mark -
#pragma mark (注销当前SIP账号)
- (void)deRegisterSipAccount {
    
    client::RegistrationManager *registration_manager = [self gainRegistrationManager];
    if (_currentProfile && registration_manager->ProfileIsRegistered(_currentProfile)) {
        
        registration_manager->MakeDeRegister(_currentProfile);
    }
}

#pragma mark -
#pragma mark (刷新指定账号)
- (void)refreshSipRegister {
    
    //ProfileIsRegistered该方法检查sip是否在线
    client::RegistrationManager *registration_manager = _sipEngine->GetRegistrationManager();
    if(_currentProfile && registration_manager->ProfileIsRegistered(_currentProfile)) {
        
        registration_manager->RefreshRegistration(_currentProfile);
    }
}

#pragma mark -
#pragma mark (发起一个外呼)
- (client::Call *)makeCall:(NSString *)number
             withVideoCall:(bool)video_enabled
               displayName:(NSString *)display_name {
    
    if(![self inCalling]) {
        
        client::ExtensionHeaderMap extension_hdr_map;
        extension_hdr_map["X-MyHeader1"] = "MyValue1";
        extension_hdr_map["X-MyHeader2"] = "MyValue2";
        
        if(_currentProfile) {
            
            client::CallManager *call_manager = [self gainCallManager];
            _currentCall = call_manager->MakeCall(_currentProfile
                                                  , [number UTF8String]
                                                  , "ios-app"
                                                  , _currentProfile->webrtc_mode
                                                  , true
                                                  , video_enabled
                                                  , false
                                                  , extension_hdr_map);
        }
    }
    
    return _currentCall;
}

#pragma mark -
#pragma mark (拒接来电(呼入/呼出，通话未建立))
- (void)rejectCurrentCall {
    
    client::CallManager *call_manager = [self gainCallManager];
    std::list<client::Call*> call_list = call_manager->GetCallList();
    if (call_list.size() > 0) {
        
        std::list<client::Call*>::iterator it = call_list.begin();
        while (it != call_list.end()) {
            
            client::Call *call = *it;
            call->Reject(603);
            it++;
        }
    }
    
    _currentCall = nil;
}

#pragma mark -
#pragma mark (挂断当前呼叫(呼入/呼出，通话已建立))
- (void)hangUpCurrentCall {
    
    client::CallManager *call_manager = [self gainCallManager];
    std::list<client::Call*> call_list = call_manager->GetCallList();
    if (call_list.size() > 0) {
        
        std::list<client::Call*>::iterator it = call_list.begin();
        while (it != call_list.end()) {
            
            client::Call *call = *it;
            call->Hangup();
            it++;
        }
    }
    
    _currentCall = nil;
}

#pragma mark -
#pragma mark (应用程序已进入后台状态，刷新SIP注册，准备长连接socket)
- (void)applicationDidEnterBackground {
    
    if (!_sipEngine) {
        return;
    }
    
    //进入后台模式，刷新SIP注册
    [self refreshSipRegister];
    
    //register keepalive
    if ([[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        
        DoorDuLogDebug(@"keepalive handler");
        
        //kick up network cnx, just in case
        [self kickOffNetworkConnection];
        [self refreshSipRegister];
        
    }]) {
        
        DoorDuLogDebug(@"keepalive handler succesfully registered");
        
    }else {
        
        DoorDuLogDebug(@"keepalive handler cannot be registered");
    }
    
    //进入后台后刷新SIP注册
    /*
    int i=0;
    while (i++ < 40) {
        
        _sipEngine->RunEventLoop();
        
        //异步事件，请在主线程中使用Timer执行，间隔(10ms).
        usleep(10000);
    }*/
    
    DoorDuLogDebug(@"Enter to background mode !");
}

#pragma mark -
#pragma mark (应用程序已经进入活跃状态，刷新SIP注册)
- (void)applicationDidBecomeActive {
    
    if (_proxyReachability){
        
        SCNetworkReachabilityFlags flags=0;
        if (!SCNetworkReachabilityGetFlags(_proxyReachability, &flags)) {
            
            DoorDuLogDebug(@"Cannot get reachability flags, re-creating reachability context.");
            [self configureProxyReachability];
            
        }else {
            
            networkReachabilityCallBack(_proxyReachability, flags, (__bridge void *)self);
            if (flags == 0) {
                
                //workaround iOS bug: reachability API cease to work after some time.
                //when flags==0, either we have no network, or the reachability object lies. To workaround, create a new one.
                [self configureProxyReachability];
            }
        }
        
    }else {
        
        DoorDuLogDebug(@"No proxy reachability context created !");
    }
    
    if (_sipEngine) {
       
        [self refreshSipRegister];
    }
}

#pragma mark -
#pragma mark (sip注册失败，错误原因为dns timeout(503)后需要执行该方法)
- (void)resetTransport {
    if (!_sipEngine) {
        return;
    }
    _sipEngine->ResetTransport();
}

#pragma mark - 配置DNS
- (void)configureDNS {
    
    if(_sipEngine) {
        
        const char *dns1 = "8.8.8.8";
        _sipEngine->AddDnsServer(dns1);
        
        const char *dns2 = "114.114.114.114";
        _sipEngine->AddDnsServer(dns2);
    }
}

@end
