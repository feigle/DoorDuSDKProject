//
//  DoorDuSipCallManager.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/30.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuSipCallManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <SipEngineSDK/SipEngine.hxx>
#import <SipEngineSDK/SipProfileManager.hxx>
#import <SipEngineSDK/CallManager.hxx>
#import <SipEngineSDK/RTCEAGLVideoView.h>
#import "DoorDuVideoView.h"
#import <AVFoundation/AVFoundation.h>
#import "DoorDuCommonHeader.h"
#import "DoorDuLog.h"

//dtmf信令常量.
#define DTMF_SWITCH_VIDEO_TO_AUDIO  @"7"//dtmf:终端之间通话，本地收到远程由视频模式切换到语音模式信令
//终端呼叫终端:主叫的房间名称的key
static NSString *const kDoorDuUserAccessUserLocalRoomNameKey = @"X-room-no";
@interface DoorDuSipCallManager ()<SipEngineUIRegistrationDelegate, SipEngineUICallDelegate, VideoFrameInfoDelegate, RTCEAGLVideoViewDelegate>
{
    client::Call * _currentCall;/**当前呼叫的对象*/
}
/**sip通话的时候，用于监听外部电话来电情况，必须在这里声明，要不不会回调block*/
@property(nonatomic,strong) CTCallCenter *callCenter;
/**设置代理对象*/
@property (nonatomic,weak) id <DoorDuSipCallDelegate> deleagte;
/**记录下呼叫方向*/
@property (nonatomic,assign) DoorDuCallDirection callDirection;
/**当前本地摄像头方向(前/后)*/
@property (nonatomic,assign) DoorDuCallCameraOrientation localCameraOrientation;
/**本地视频显示控件背景View*/
@property (nonatomic,strong) DoorDuVideoView * localVideoBgView;
/**远程视频显示控件背景View*/
@property (nonatomic,strong) DoorDuVideoView * remoteVideoBgView;
/**本地视频显示控件*/
@property (nonatomic,strong) RTCEAGLVideoView * localRTCEAGLVideoView;
/**远程视频显示控件*/
@property (nonatomic,strong) RTCEAGLVideoView * remoteRTCEAGLVideoView;
/**当前呼叫类型DoorDuCallType,语音、视频等等*/
@property (nonatomic,assign) DoorDuMediaCallType localMediaCallType;
/**呼叫初始话筒状态*/
@property (nonatomic,assign) BOOL microphoneEnable;
/**呼叫初始扬声器状态*/
@property (nonatomic,assign) BOOL speakerEnable;
/**当前来电类型*/
@property (nonatomic,assign) DoorDuCurrentIncomingCallType currentIncomingCallType;
/**保留当前SIP账号*/
@property (nonatomic,copy) NSString * currentSipAccount;
/**本地用户的SIP账号*/
@property (nonatomic,copy) NSString * userSipAccount;
/**呼叫是否接通*/
@property (nonatomic,assign) BOOL isCallConnected;

@end

@implementation DoorDuSipCallManager

//静态单例变量
static DoorDuSipCallManager * doorDuSipCallManager = nil;
#pragma mark (创建线程安全单例)
+ (instancetype)sharedInstance {
    if (doorDuSipCallManager == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            doorDuSipCallManager = [[DoorDuSipCallManager alloc] init];
        });
    }
    return doorDuSipCallManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSipCallManagerData];
    }
    return self;
}
#pragma mark - 初始化数据
- (void)setupSipCallManagerData
{
    [self addObserveApplicationDelegateStatusNotifications];
    
    // 初始化sip引擎
    [[SipEngineManager sharedInstance] initializeSipEngineManager];
    
}
#pragma mark - 增加 观察 ApplicationDelegate 的几个状态的 Notifications
- (void)addObserveApplicationDelegateStatusNotifications
{
    //监听接收SIP初始化完成
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSipEngineNotification:)
                                                 name:kSipEngineManager_InitializeSuccess_Notification
                                               object:nil];
    
    /**在应用程序加载完成时*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunchingWithOptions)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    /**应用程序将要入非活动状态时.*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    /**应用程序已进入后台状态时.*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    /**应用程序从后台将要重新回到前台时.*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    /**应用程序已经进入活跃状态时*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    /**应用程序将要退出时*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}
/*!
 * @method  applicationDidFinishLaunchingWithOptions
 * @brief   注册SDK之后，在应用程序加载完成时.
 */
- (void)applicationDidFinishLaunchingWithOptions
{
    //ADD CODE HERE
}
/*!应用程序将要入非活动状态时.*/
- (void)applicationWillResignActive
{
    //如果正在通话中
    if ([[SipEngineManager sharedInstance] inCalling]) {
        //暂停视频捕获
        [DoorDuSipCallManager pauseCurrentCall];
    }
}
/*!应用程序已进入后台状态时.*/
- (void)applicationDidEnterBackground
{
    //刷新SIP注册，准备长连接socket
    [[SipEngineManager sharedInstance] applicationDidEnterBackground];
}
/*!应用程序进入前台*/
- (void)applicationWillEnterForeground
{
    //判断当前是否有通话
    if ([[SipEngineManager sharedInstance] inCalling]) {
        //有通话，恢复当前通话，在 applicationDidBecomeActive处理
        //        [DoorDuSipCallManager resumeCurrentCall];
    }
}
/*!应用程序已经进入活跃状态时.*/
- (void)applicationDidBecomeActive
{
    //刷新SIP注册
    [[SipEngineManager sharedInstance] applicationDidBecomeActive];
    //如果正在通话中
    if ([[SipEngineManager sharedInstance] inCalling]) {
        //恢复视频捕获
        [DoorDuSipCallManager resumeCurrentCall];
    }
    //如果存在来电呼叫
    if ([[SipEngineManager sharedInstance] haveIncomingCall]) {
        //获取当前呼叫来电
    }
}
/*!应用程序将要退出时.*/
- (void)applicationWillTerminate
{
    if (self.callDirection == kDoorDuCallDirectionIncoming) {
        //被叫
        if ([[SipEngineManager sharedInstance] inCalling]) {
            [DoorDuSipCallManager hangupCurrentCall];
        }else {
            [DoorDuSipCallManager rejectCurrentCall];
        }
    } else if (self.callDirection == kDoorDuCallDirectionOutgoing){
        [DoorDuSipCallManager hangupCurrentCall];
    }
}
/***************************** 以上是  application状态监听回调 ***********************************/
#pragma mark - 添加 电话监听处理
- (void)startCTCallCenterMonitoring
{
    [self removeCTCallCenterMonitoring];
    //    __block __weak DoorDuSipCallManager *weakSelf = self;
    DoorDuLogDebug(@"音视频-开启外部电话监听");
    __block __weak CTCallCenter *weakCallCenter = self.callCenter;
    self.callCenter.callEventHandler = ^(CTCall *call) {
        dispatch_async(dispatch_get_main_queue(), ^{/**在主线程中处理逻辑*/
            if ([weakCallCenter currentCalls]) {
                DoorDuLogDebug(@"音视频-来电话了，挂断当前通话");
                /**这里执行挂断电话等操作*/
                [DoorDuSipCallManager hangupCurrentCall];
            }
        });
    };
}
#pragma mark - 移除电话监听
- (void)removeCTCallCenterMonitoring
{
    if (_callCenter) {
        _callCenter.callEventHandler = NULL;
        _callCenter = nil;
    }
}
/**CTCallCenter懒加载*/
- (CTCallCenter *)callCenter
{
    if (!_callCenter) {
        _callCenter = [[CTCallCenter alloc] init];
    }
    return _callCenter;
}
/***************************** 以上是  电话监听操作 ***********************************/
#pragma mark -    监听接收SIP初始化完成
- (void)receiveSipEngineNotification:(NSNotification *)notif {
    NSString *name = notif.name;
    DoorDuLogDebug(@"音视频-初始化完毕");
    /*!SIP管理器初始化完成. 收到该消息后，才可以设置注册，呼叫，视频代理.*/
    if ([name isEqualToString:kSipEngineManager_InitializeSuccess_Notification]) {
        //增加DNS配置
        [[SipEngineManager sharedInstance] configureDNS];
        //设置帐号注册状态回调代理
        [[SipEngineManager sharedInstance] setRegistrationDelegate:self];
        //设置呼叫通话状态回调代理
        [[SipEngineManager sharedInstance] setCallDelegate:self];
    }
}
#pragma mark - SipEngineUIRegistrationDelegate(SIP注册状态回调)
/*!SIP账号正在注册. */
- (void)OnRegistrationProgress:(client::SipProfile *)profile
{
    if ([self.deleagte respondsToSelector:@selector(sipIsRegistering)]) {
        [self.deleagte sipIsRegistering];
    }
}
/*!SIP账号注册成功. */
- (void)OnRegistrationSucess:(client::SipProfile *)profile
{
    DoorDuLogDebug(@"音视频--注册成功");
    if ([self.deleagte respondsToSelector:@selector(sipRegistrationSuccess)]) {
        [self.deleagte sipRegistrationSuccess];
    }
}
/*!SIP账号注销成功. */
- (void)OnRegistrationCleared:(client::SipProfile *)profile
{
    DoorDuLogDebug(@"音视频--注销成功");
    if ([self.deleagte respondsToSelector:@selector(sipCanceledSuccessfully)]) {
        [self.deleagte sipCanceledSuccessfully];
    }
}
/*!SIP账号注册失败.*/
- (void)OnRegisterationFailed:(client::SipProfile *)profile
                    errorCode:(NSInteger)errorCode
                  errorReason:(NSString *)errorReason
{
    DoorDuLogDebug(@"音视频--注册失败");
    if (kDoorDuSipRegistErrorCodeDnsTimeout == errorCode) {
        [[SipEngineManager sharedInstance] resetTransport];
    }
    if ([self.deleagte respondsToSelector:@selector(sipRegistrationFailed:errorMessage:)]) {
        [self.deleagte sipRegistrationFailed:(DoorDuSipRegistErrorCode)errorCode errorMessage:errorReason];
    }
}
/********** 以上是  SIP注册状态回调(SipEngineUIRegistrationDelegate) *********/
#pragma mark - SipEngineUICallDelegate(呼叫状态回调)
/*!新的呼叫(呼入/呼出).收到本地或者远程呼叫开始的信息. */
#pragma mark - 新的呼叫
- (void)OnNewCall:(client::Call *)call
        direction:(client::Call::Direction)direction
         callerID:(NSString *)callerID
     supportVideo:(BOOL)supportVideo
{
    self.localMediaCallType = supportVideo?kDoorDuMediaCallTypeVideo:kDoorDuMediaCallTypeAudio;
    NSString * remoteRoomNameStr = nil;
    self.isCallConnected = NO;
    /**保留当前呼叫对象*/
    self->_currentCall = call;
    self.currentSipAccount = callerID;
    /**保留当前呼叫方向*/
    if (direction == client::Call::Direction::kIncoming) {//呼叫进来
        self.callDirection = kDoorDuCallDirectionIncoming;
        /*!
         * sip账号规则:设备类型+7位或者8位随机数: * 设备类型(通过SIP账号的首字母判断):* 1(门禁机)* 2(Android终端)* 3(IOS终端)* 4(室内机终端)* 5(门禁卡)* 6(别墅机)* 7(物业管理机)* 8(物业管理平台)* 9(86盒)
         */
        if (callerID.length) {
            NSInteger incomingType = [[callerID substringWithRange:NSMakeRange(0, 1)] integerValue];
            self.currentIncomingCallType = (DoorDuCurrentIncomingCallType)incomingType;
            switch (incomingType) {
                case kDoorDuCurrentIncomingCallTypeDoor:{//1(门禁机)
                }break;
                case kDoorDuCurrentIncomingCallTypeAndroid:{//2(Android终端)
                case kDoorDuCurrentIncomingCallTypeIOS:{//3(IOS终端)
                    const client::ExtensionHeaderMap &ext_hdr_map = call->get_extension_header_map();
                    if(ext_hdr_map.size() > 0) {
                        client::ExtensionHeaderMap::const_iterator it = ext_hdr_map.find([kDoorDuUserAccessUserLocalRoomNameKey UTF8String]);
                        if(it != ext_hdr_map.end()) {
                            //获取主叫房间名称对应的信息
                            std::string key = it->first;
                            std::string value = it->second;
                            //保存主叫房间名称
                            remoteRoomNameStr = [NSString stringWithCString:value.c_str() encoding:NSUTF8StringEncoding];
                        }
                    }
                    //呼叫类型
                    NSString *remoteRoomName = remoteRoomNameStr;
                    if (remoteRoomName && [remoteRoomName length]) {
                        //语音呼叫远程房间名称前面带"a"
                        BOOL isAudioMode = [remoteRoomName hasPrefix:@"a"];
                        if (isAudioMode) {
                            self.localMediaCallType = kDoorDuMediaCallTypeAudio;
                            //重置远程房间名称
                            if ([remoteRoomName length] > 1) {
                                remoteRoomNameStr = [remoteRoomName substringFromIndex:1];
                            }
                        }else {
                            self.localMediaCallType = kDoorDuMediaCallTypeVideo;
                        }
                    }else {
                        self.localMediaCallType = kDoorDuMediaCallTypeAudio;
                    }
                }break;
                    //                case kDoorDuCurrentIncomingCallTypeIOS:{//3(IOS终端)
                    //                }break;
                case kDoorDuCurrentIncomingCallTypeIndoor:{//4(室内机终端)
                }break;
                case kDoorDuCurrentIncomingCallTypeCard:{//5(门禁卡)
                }break;
                case kDoorDuCurrentIncomingCallTypeVilla:{//6(别墅机)
                }break;
                case kDoorDuCurrentIncomingCallTypePropertyManagement:{//7(物业管理机)
                }break;
                case kDoorDuCurrentIncomingCallTypePropertyManagementPlatform:{//8(物业管理平台)
                }break;
                case kDoorDuCurrentIncomingCallTypeBox86:{//9(86盒)
                }break;
                default:
                    self.currentIncomingCallType = kDoorDuCurrentIncomingCallTypeUnknown;
                    break;
                }
            }
        } else {
            self.currentIncomingCallType = kDoorDuCurrentIncomingCallTypeUnknown;
        }
    } else if (direction == client::Call::Direction::kOutgoing) {//呼叫出去
        self.callDirection = kDoorDuCallDirectionOutgoing;
    } else {
        self.callDirection = kDoorDuCallDirectionUnknown;
    }
    /**新来电回调*/
    if ([self.deleagte respondsToSelector:@selector(sipNewCallDirection:incomingCallType:callerSipID:remoteCallName:)]) {
        [self.deleagte sipNewCallDirection:self.callDirection incomingCallType:self.currentIncomingCallType callerSipID:self.currentSipAccount remoteCallName:remoteRoomNameStr];
    }
}
/*!呼叫被取消(呼入/呼出). */
- (void)OnCallCancel:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--呼叫被取消");
    self->_currentCall = nil;
    self.currentSipAccount = nil;
    self.callDirection = kDoorDuCallDirectionNone;
    [self removeCTCallCenterMonitoring];
    //停止视频状态监听
    if (call->support_video()) {
        [[SipEngineManager sharedInstance] setVideoFrameInfoDelegate:nil];
    }
    if ([self.deleagte respondsToSelector:@selector(sipTheCallIsCanceledDirection:)]) {
        [self.deleagte sipTheCallIsCanceledDirection:self.callDirection];
    }
}
/*!呼叫失败或错误(呼入/呼出). */
- (void)OnCallFailed:(client::Call *)call
           errorCode:(NSInteger)errorCode
         errorReason:(NSString *)errorReason
{
    DoorDuLogDebug(@"音视频--呼叫失败或错误");
    self->_currentCall = nil;
    self.currentSipAccount = nil;
    self.callDirection = kDoorDuCallDirectionNone;
    [self removeCTCallCenterMonitoring];
    //停止视频状态监听
    if (call->support_video()) {
        [[SipEngineManager sharedInstance] setVideoFrameInfoDelegate:nil];
    }
    if ([self.deleagte respondsToSelector:@selector(sipCallFailedOrWrong)]) {
        [self.deleagte sipCallFailedOrWrong];
    }
}
/*!呼叫被拒绝(呼出). */
- (void)OnCallRejected:(client::Call *)call
             errorCode:(NSInteger)errorCode
           errorReason:(NSString *)errorReason
{
    DoorDuLogDebug(@"音视频--呼叫被拒绝");
    //设置当前来电
    self->_currentCall = nil;
    self.currentSipAccount = nil;
    self.callDirection = kDoorDuCallDirectionNone;
    [self removeCTCallCenterMonitoring];
    //停止视频状态监听
    if (call->support_video()) {
        [[SipEngineManager sharedInstance] setVideoFrameInfoDelegate:nil];
    }
    if ([self.deleagte respondsToSelector:@selector(sipTheCallWasRejected)]) {
        [self.deleagte sipTheCallWasRejected];
    }
}
/*!正在建立连接(呼出). 早期媒体，在通话之前建立媒体流，被叫方收到彩铃. */
- (void)OnCallProcessing:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--正在建立连接(呼出)");
    if ([self.deleagte respondsToSelector:@selector(sipCallConnectionIsBeingEstablished)]) {
        [self.deleagte sipCallConnectionIsBeingEstablished];
    }
}
/*!被叫方振铃(呼出). */
- (void)OnCallRinging:(client::Call *)call
{
    if ([self.deleagte respondsToSelector:@selector(sipTheCalledPartyRings)]) {
        [self.deleagte sipTheCalledPartyRings];
    }
}
/*!呼叫接通(呼入/呼出). */
- (void)OnCallConnected:(client::Call *)call
           supportVideo:(BOOL)supportVideo
            supportData:(BOOL)supportData
{
    DoorDuLogDebug(@"音视频--呼叫接通");
    self.isCallConnected = YES;
    /**开启监听外部电话*/
    [self startCTCallCenterMonitoring];
    if ([self.deleagte respondsToSelector:@selector(sipTheCallIsConnectedDirection:supportVideo:supportData:)]) {
        [self.deleagte sipTheCallIsConnectedDirection:self.callDirection supportVideo:supportVideo supportData:supportData];
    }
}
/*!呼叫结束(呼入/呼出). */
- (void)OnCallEnded:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--呼叫结束");
    //设置当前来电
    self->_currentCall = nil;
    self.currentSipAccount = nil;
    self.callDirection = kDoorDuCallDirectionNone;
    [self removeCTCallCenterMonitoring];
    //停止视频状态监听
    if (call->support_video()) {
        [[SipEngineManager sharedInstance] setVideoFrameInfoDelegate:nil];
    }
    [self clearVideoUI];
    if ([self.deleagte respondsToSelector:@selector(sipTheCallEndsDirection:)]) {
        [self.deleagte sipTheCallEndsDirection:self.callDirection];
    }
}
/*!正在设置呼叫暂停(呼入/呼出). */
- (void)OnCallPausing:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--正在设置呼叫暂停");
    if ([self.deleagte respondsToSelector:@selector(sipACallPauseIsBeingSetDirection:)]) {
        [self.deleagte sipACallPauseIsBeingSetDirection:self.callDirection];
    }
}
/*!呼叫已暂停(呼入/呼出). */
- (void)OnCallPaused:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--呼叫已暂停");
    if ([self.deleagte respondsToSelector:@selector(sipTheCallIsPausedDirection:)]) {
        [self.deleagte sipTheCallIsPausedDirection:self.callDirection];
    }
}
/*!正在设置终止呼叫暂停(呼入/呼出). */
- (void)OnCallResuming:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--正在设置终止呼叫暂停");
    if ([self.deleagte respondsToSelector:@selector(sipSettingUpTerminationCallPauseDirection:)]) {
        [self.deleagte sipSettingUpTerminationCallPauseDirection:self.callDirection];
    }
}
/*!已终止呼叫暂停，恢复通话(呼入/呼出). */
- (void)OnCallResumed:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--已终止呼叫暂停，恢复通话(");
    if ([self.deleagte respondsToSelector:@selector(sipTerminatedCallPauseResumeCallDirection:)]) {
        [self.deleagte sipTerminatedCallPauseResumeCallDirection:self.callDirection];
    }
}
/*!呼叫远程设置正在更新(远程). */
- (void)OnCallRemoteUpdating:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--呼叫远程设置正在更新(远程)");
    if ([self.deleagte respondsToSelector:@selector(sipCallRemoteSettingsAreBeingUpdated)]) {
        [self.deleagte sipCallRemoteSettingsAreBeingUpdated];
    }
}
/*!呼叫远程设置已更新(远程). */
- (void)OnCallRemoteUpdated:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--呼叫远程设置已更新(远程)");
    if ([self.deleagte respondsToSelector:@selector(sipCallRemoteSettingsHaveBeenUpdated)]) {
        [self.deleagte sipCallRemoteSettingsHaveBeenUpdated];
    }
}
/*!呼叫转移被接受(呼入/呼出). */
- (void)OnCallReferAccepted:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--呼叫转移被接受");
    if ([self.deleagte respondsToSelector:@selector(sipCallTransferIsAcceptedDirection:)]) {
        [self.deleagte sipCallTransferIsAcceptedDirection:self.callDirection];
    }
}
/*!呼叫转移被拒绝(呼入/呼出). */
- (void)OnCallReferRejected:(client::Call *)call
{
    DoorDuLogDebug(@"音视频--呼叫转移被拒绝");
    if ([self.deleagte respondsToSelector:@selector(sipCallForwardingIsRejectedDirection:)]) {
        [self.deleagte sipCallForwardingIsRejectedDirection:self.callDirection];
    }
}
/*!媒体就绪.包含"音频/视频/数据"三种媒体类型(呼入/呼出). */
- (void)OnMediaStreamReady:(client::Call *)call mediaType:(client::CallMediaStreamType)mediaType
{
    if (!self->_currentCall) {//检测当前是否有呼叫对象
        return;
    }
    //开启视频状态监听(VideoFrameInfoDelegate)
    [[SipEngineManager sharedInstance] setVideoFrameInfoDelegate:self];
    /*!
     * 媒体就绪后，在视频显示控件上渲染视频流.
     * kCallVideoStream:判断是否视频流.
     * kInactive:通话过程中，对方暂停了所有媒体流，本地就会标记为kInactive.
     * kNone:音视频关闭不可用.
     */
    //获取当前呼叫媒体流类型
    client::VideoStream *videoStream = self->_currentCall->media_stream()->video_stream();
    if(mediaType == client::CallMediaStreamType::kCallVideoStream
       && (videoStream->GetMediaDirection() != client::StreamParams::kInactive
           || videoStream->GetMediaDirection() != client::StreamParams::kNone)) {
           [DoorDuSipCallManager drawVideoStream];
       }
    switch (mediaType) {
        case client::CallMediaStreamType::kCallAudioStream:
        {//媒体流是否就绪(语音)
            if (self.isCallConnected) {
                [DoorDuSipCallManager switchMicrophone:self.microphoneEnable];
                [DoorDuSipCallManager switchSpeaker:self.speakerEnable];
            }
            if ([self.deleagte respondsToSelector:@selector(sipVoiceMediaStreamReady)]) {
                [self.deleagte sipVoiceMediaStreamReady];
            }
        }
            break;
        case client::CallMediaStreamType::kCallVideoStream:
        {//媒体流是否就绪(视频)
            if ([self.deleagte respondsToSelector:@selector(sipVideoMediaStreamReady)]) {
                [self.deleagte sipVideoMediaStreamReady];
            }
        }
            break;
        case client::CallMediaStreamType::kCallDataStream:
        {//媒体流是否就绪(数据)
            if ([self.deleagte respondsToSelector:@selector(sipDataMediaStreamReady)]) {
                [self.deleagte sipDataMediaStreamReady];
            }
        }
            break;
        default:
            break;
    }
}
/*!收到远程DTMF信号. */
- (void)OnReceiveDtmf:(client::Call *)call tone:(NSString *)tone
{
    //收到终端之间通话由视频模式切换到语音模式
    if ([tone isEqualToString:DTMF_SWITCH_VIDEO_TO_AUDIO]) {
        //检查单例变量 & 当前呼叫对象
        if (self->_currentCall) {
            //关闭视频流
            self->_currentCall->UpdateCall(false);
            //回调给外面代理
            if ([self.deleagte respondsToSelector:@selector(sipReceiveRemoteSwitchVideoModeToAudioMode)]) {
                [self.deleagte sipReceiveRemoteSwitchVideoModeToAudioMode];
            }
        }
    }
}
/********** 以上是  SIP呼叫状态回调(SipEngineUICallDelegate) *********/
#pragma mark - VideoFrameInfoDelegate(视频通话回调，视频帧和大小回调)
/*!远程视频画面尺寸改变(视频通话中). */
- (void)IncomingFrameWidth:(NSInteger)width height:(NSInteger)height
{
    DoorDuLogDebug(@"音视频--远程视频画面尺寸改变：宽度：%ld、高度：%ld",width,height);
    if ([self.deleagte respondsToSelector:@selector(sipRemoteVideoScreenSizeChangeWidth:height:)]) {
        [self.deleagte sipRemoteVideoScreenSizeChangeWidth:width height:height];
    }
}
/*!远程视频帧率和码率改变(视频通话中). */
- (void)IncomingFps:(NSInteger)fps bitrate:(NSInteger)bitrate
{
    DoorDuLogDebug(@"音视频--远程视频帧率和码率：帧率：%ld、码率：%ld",fps,bitrate);
    if ([self.deleagte respondsToSelector:@selector(sipRemoteVideoFps:bitrate:)]) {
        [self.deleagte sipRemoteVideoFps:fps bitrate:bitrate];
    }
}
/*!本地视频帧率和码率改变(视频通话中). */
- (void)OutgoingFps:(NSInteger)fps bitrate:(NSInteger)bitrate
{
    DoorDuLogDebug(@"音视频--本地视频帧率和码率：帧率：%ld、码率：%ld",fps,bitrate);
    if ([self.deleagte respondsToSelector:@selector(sipLocalVideoFps:bitrate:)]) {
        [self.deleagte sipLocalVideoFps:fps bitrate:bitrate];
    }
}
/********** 以上是  视频通话回调，视频帧和大小回调(VideoFrameInfoDelegate) *********/
#pragma mark - RTCEAGLVideoViewDelegate(视频界面尺寸变化回调)
- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size
{//刷新控件布局
    DoorDuLogDebug(@"音视频--视频界面尺寸变化：宽度：%lf、高度：%lf",size.width,size.height);
    if (videoView == [DoorDuSipCallManager sharedInstance].localRTCEAGLVideoView) {
        [[DoorDuSipCallManager sharedInstance].localVideoBgView setNeedsLayout];
    }else if (videoView == [DoorDuSipCallManager sharedInstance].remoteRTCEAGLVideoView) {
        [[DoorDuSipCallManager sharedInstance].remoteVideoBgView setNeedsLayout];
    }
}
/********** 以上是  视频界面尺寸变化回调(RTCEAGLVideoViewDelegate) *********/
#pragma mark - 本类中私有的接口在这里
#pragma mark (获取摄像头和屏幕的夹角)
+ (NSInteger)gainCameraOrientation:(NSInteger)cameraOrientation {
    //当前呼叫不是视频就不用旋转
    if ([DoorDuSipCallManager sharedInstance].localMediaCallType != kDoorDuMediaCallTypeVideo) {
        return 0;
    }
    //App之间通讯旋转
    UIInterfaceOrientation displatyRotation = [[UIApplication sharedApplication] statusBarOrientation];
    NSInteger degrees = 0;
    switch (displatyRotation) {
        case UIInterfaceOrientationPortrait:{
            degrees = 0;
        }break;
        case UIInterfaceOrientationLandscapeLeft:{
            degrees = 90;
        }break;
        case UIInterfaceOrientationPortraitUpsideDown:{
            degrees = 180;
        }break;
        case UIInterfaceOrientationLandscapeRight:{
            degrees = 270;
        }break;
        case UIInterfaceOrientationUnknown:{
        }break;
    }
    NSInteger result = 0;
    if (cameraOrientation > 180) {
        result = (cameraOrientation + degrees) % 360;
    }else {
        result = (cameraOrientation - degrees + 360) % 360;
    }
    if([DoorDuSipCallManager sharedInstance].localCameraOrientation == kDoorDuCallCameraOrientationBack) {
        if (result == 0) {
            result = 180;
        }else if(result == 180) {
            result = 0;
        }
    }
    return result;
}
#pragma mark (改变视频尺寸，这里实际是改变本地的视频尺寸，有sip引擎告诉远方尺寸改变)
+ (void)changeLocalRemoteVideoSize {
    //检查单例变量 & 当前呼叫对象
    if ([DoorDuSipCallManager sharedInstance]->_currentCall) {
        client::MediaStream *mediaStream = [DoorDuSipCallManager sharedInstance]->_currentCall->media_stream();
        if (!mediaStream) {
            return;
        }
        client::VideoStream *videoStream = mediaStream->video_stream();
        if (!videoStream) {
            return;
        }
        client::RTCVideoEngine *videoEngine = [[SipEngineManager sharedInstance] gainRTCVideoEngine];
        int cameraOrientation;
        if([DoorDuSipCallManager sharedInstance].localCameraOrientation == kDoorDuCallCameraOrientationFront) {
            cameraOrientation = videoEngine->GetCameraOrientation(1);
        }else {
            cameraOrientation = videoEngine->GetCameraOrientation(0);
        }
        videoStream->ChangeCaptureRotation((int)[DoorDuSipCallManager gainCameraOrientation:cameraOrientation]);
    }
}
/**在这里增加了判断，如果当前设备没有两个就给后置摄像头*/
- (DoorDuCallCameraOrientation)localCameraOrientation
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count < 2) {//当前设备的个数
        if (_localCameraOrientation == kDoorDuCallCameraOrientationFront) {
            _localCameraOrientation = kDoorDuCallCameraOrientationBack;
            [[self class] switchCameraDirection];
        }
    }
#pragma mark - 这里待测试
    client::RTCVideoEngine *videoEngine = [[SipEngineManager sharedInstance] gainRTCVideoEngine];
    DoorDuLog(@"videoEngine:设备的个数:( %d )",videoEngine->NumberOfCaptureDevices());
    if(videoEngine->NumberOfCaptureDevices()<2){//当前设备的个数，这个是SIP里面的
        if (_localCameraOrientation == kDoorDuCallCameraOrientationFront) {
            _localCameraOrientation = kDoorDuCallCameraOrientationBack;
            [[self class] switchCameraDirection];
        }
    };
    return _localCameraOrientation;
}
//######################## DTMF操作模块 ##########################
#pragma mark (发送指定的dtmf信令:code为[0-9,*,#]等单个字符)
+ (BOOL)sendDTMFWithCode:(NSString *)code {
    if ([DoorDuSipCallManager sharedInstance]->_currentCall) {
        //设置dtmf方法
        client::Call::DtmfMethod dtmfMethod = client::Call::kDtmfRFC2833;
        //发送dtmf信令
        [DoorDuSipCallManager sharedInstance]->_currentCall->SendDtmf(dtmfMethod, [code UTF8String], false);
        return YES;
    }
    return NO;
}
#pragma mark (媒体就绪后，在视频显示控件上渲染视频流)
+ (void)drawVideoStream {
    //检查单例变量 & 当前呼叫对象
    if (![DoorDuSipCallManager sharedInstance]->_currentCall) {
        return;
    }
    //是否支持视频
    if ([DoorDuSipCallManager sharedInstance]->_currentCall->support_video()) {
        //获取当前呼叫的帧率和码率
        SipEngineManager_VideoSize *videoSize = [[SipEngineManager sharedInstance] gainVideoSize];
        float fps = [[SipEngineManager sharedInstance] gainFrameRate];
        float bitrate = [[SipEngineManager sharedInstance] gainBitrate];
        //获取当前呼叫的视频流
        client::VideoStream *videoStream = [DoorDuSipCallManager sharedInstance]->_currentCall->media_stream()->video_stream();
        videoStream->SetMediaDirection(client::StreamParams::kInactive);
        //重置视频显示控件
        [[DoorDuSipCallManager sharedInstance].localRTCEAGLVideoView resetDisplay];
        [[DoorDuSipCallManager sharedInstance].remoteRTCEAGLVideoView resetDisplay];
        //获取视频引擎对象
        client::RTCVideoEngine *videoEngine = [[SipEngineManager sharedInstance] gainRTCVideoEngine];
        //获取本地摄像头方向
        int cameraOrientation = videoEngine->GetCameraOrientation([DoorDuSipCallManager sharedInstance].localCameraOrientation);
        //设置视频参数，如果检查到摄像头只有一个，本地摄像头方向默认设置为0
        //判断设备摄像头方向(RTCVideoEngine.NumberOfCaptureDevices)
        videoStream->SetupVideoStream([DoorDuSipCallManager sharedInstance].localCameraOrientation
                                      , NULL
                                      , NULL
                                      , [[DoorDuSipCallManager sharedInstance].localRTCEAGLVideoView externalRenderer]
                                      , [[DoorDuSipCallManager sharedInstance].remoteRTCEAGLVideoView externalRenderer]
                                      , (int)[DoorDuSipCallManager gainCameraOrientation:cameraOrientation]
                                      , videoSize->width
                                      , videoSize->height
                                      , bitrate
                                      , fps);
        //设置媒体流为"双向收发"
        videoStream->SetMediaDirection(client::StreamParams::kSendRecv);
        //改变视频尺寸
        [DoorDuSipCallManager changeLocalRemoteVideoSize];
    }
}
/**布局video界面*/
+ (void)configVideoUI
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        [[DoorDuSipCallManager sharedInstance] configVideoUI];
//    });    
}
/**布局video界面-对象方法*/
- (void)configVideoUI
{
    if (self.localVideoBgView) {
        self.localRTCEAGLVideoView = [[RTCEAGLVideoView alloc] init];
        self.localRTCEAGLVideoView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.localVideoBgView addSubview:self.localRTCEAGLVideoView];
        self.localRTCEAGLVideoView.dragEnable = NO;
        self.localRTCEAGLVideoView.delegate = self;
        [self.localVideoBgView addConstraint:[NSLayoutConstraint constraintWithItem:self.localVideoBgView
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.localRTCEAGLVideoView
                                                                          attribute:NSLayoutAttributeLeading
                                                                         multiplier:1.f
                                                                           constant:0.f]];
        [self.localVideoBgView addConstraint:[NSLayoutConstraint constraintWithItem:self.localVideoBgView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.localRTCEAGLVideoView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.f
                                                                           constant:0.f]];
        [self.localVideoBgView addConstraint:[NSLayoutConstraint constraintWithItem:self.localVideoBgView
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.localRTCEAGLVideoView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.f
                                                                           constant:0.f]];
        [self.localVideoBgView addConstraint:[NSLayoutConstraint constraintWithItem:self.localVideoBgView
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.localRTCEAGLVideoView
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.f
                                                                           constant:0.f]];
    }
    if (self.remoteVideoBgView) {
        self.remoteRTCEAGLVideoView = [[RTCEAGLVideoView alloc] init];
        self.remoteRTCEAGLVideoView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.remoteVideoBgView addSubview:self.remoteRTCEAGLVideoView];
        self.remoteRTCEAGLVideoView.dragEnable = NO;
        self.remoteRTCEAGLVideoView.delegate = self;
        [self.remoteVideoBgView addConstraint:[NSLayoutConstraint constraintWithItem:self.remoteVideoBgView
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.remoteRTCEAGLVideoView
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1.f
                                                                            constant:0.f]];
        [self.remoteVideoBgView addConstraint:[NSLayoutConstraint constraintWithItem:self.remoteVideoBgView
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.remoteRTCEAGLVideoView
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1.f
                                                                            constant:0.f]];
        [self.remoteVideoBgView addConstraint:[NSLayoutConstraint constraintWithItem:self.remoteVideoBgView
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.remoteRTCEAGLVideoView
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.f
                                                                            constant:0.f]];
        [self.remoteVideoBgView addConstraint:[NSLayoutConstraint constraintWithItem:self.remoteVideoBgView
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.remoteRTCEAGLVideoView
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.f
                                                                            constant:0.f]];
    }
    //刷新控件布局
    [self.localVideoBgView layoutIfNeeded];
    [self.remoteVideoBgView layoutIfNeeded];
    [self.localVideoBgView setNeedsLayout];
    [self.remoteVideoBgView setNeedsLayout];
}
/**清除视频渲染控件*/
+ (void)clearVideoUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DoorDuSipCallManager sharedInstance] clearVideoUI];
    });
}
/**清除视频渲染控件-对象方法*/
- (void)clearVideoUI
{
    if (self.localVideoBgView) {
        [self.localVideoBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.localVideoBgView removeFromSuperview];
        self.localVideoBgView = nil;
        self.localRTCEAGLVideoView = nil;
    }
    if (self.remoteVideoBgView) {
        [self.remoteVideoBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.remoteVideoBgView removeFromSuperview];
        self.remoteVideoBgView = nil;
        self.remoteRTCEAGLVideoView = nil;
    }
}
/*********************  以上是本类中私有的接口在这里  *************/
#pragma mark - 本类中对外开放的接口在这里
#pragma mark - 添加代理
+ (void)registrationDelegate:(id<DoorDuSipCallDelegate>)delegate
{
    [DoorDuSipCallManager sharedInstance].deleagte = delegate;
}
#pragma mark - 移除代理
+ (void)removeDelegate
{
    [DoorDuSipCallManager sharedInstance].deleagte = nil;
}
#pragma mark - 注册SIP账号
/**注册SIP账号*/
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
              turnPassword:(NSString *)turnPassword
{
    [DoorDuSipCallManager sharedInstance].userSipAccount = sipAccount;
    //刷新SIP帐号配置
    [[SipEngineManager sharedInstance] loadConfigureWithSipAccount:sipAccount
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
                                                         keepAlive:keepAlive
                                                         videoType:videoType
                                                        stunServer:stunServer
                                                    stunServerPort:stunServerPort
                                                        turnServer:turnServer
                                                    turnServerPort:turnServerPort
                                                      turnUserName:turnUserName
                                                      turnPassword:turnPassword];
}
/**呼叫接口*/
+ (void)makeCallWithCallType:(DoorDuCallType)callType
               mediaCallType:(DoorDuMediaCallType)mediaCallType
       localMicrophoneEnable:(BOOL)localMicrophoneEnable
          localSpeakerEnable:(BOOL)localSpeakerEnable
              localVideoView:(DoorDuVideoView *)localVideoView
      localCameraOrientation:(DoorDuCallCameraOrientation)localCameraOrientation
              remoteCallerID:(NSString *)remoteCallerID
             remoteVideoView:(DoorDuVideoView *)remoteVideoView
{
    if ([[SipEngineManager sharedInstance] inCalling]) {//检查是否正在通话
        return;
    }
    
    [DoorDuSipCallManager sharedInstance].localCameraOrientation = localCameraOrientation;
    [DoorDuSipCallManager sharedInstance].microphoneEnable = localMicrophoneEnable;
    [DoorDuSipCallManager sharedInstance].speakerEnable = localMicrophoneEnable;
    [DoorDuSipCallManager sharedInstance].localVideoBgView = localVideoView;
    [DoorDuSipCallManager sharedInstance].remoteVideoBgView = remoteVideoView;
    [DoorDuSipCallManager configVideoUI];
    //获取SIP管理器配置SIP属性
    client::SipProfile *profile = [[SipEngineManager sharedInstance] gainCurrentSipProfile];
    if (profile) {
        //获取呼叫管理器
        client::CallManager *callManager = [[SipEngineManager sharedInstance] gainCallManager];
        //添加自定义键值对
        /*!
         * key前面带"X-key"，对应的value会传给远程;
         * key前面不带"X-key"，对应的value只会传给自己;
         */
        client::ExtensionHeaderMap extension_hdr_map;
        NSString *targetSipNO = @" ";
        if (callType == kDoorDuCallEachFamilyAccess) {
            targetSipNO = [NSString stringWithFormat:@"loop%@", remoteCallerID];
        } else if (callType == kDoorDuCallDoor){
            targetSipNO = [NSString stringWithFormat:@"*%@", remoteCallerID];
        }
        //呼叫类型(语音/视频)
        BOOL enableVideo = YES;
        if (mediaCallType == kDoorDuMediaCallTypeAudio) {
            enableVideo = NO;
        }
        //呼叫
        callManager->MakeCall(profile
                              , [targetSipNO UTF8String]
                              , "ios-app"
                              , profile->webrtc_mode
                              , true
                              , enableVideo
                              , false
                              , extension_hdr_map);
    }
}
/**接听SIP电话*/
+ (void)answerSipCallWithMediaCallType:(DoorDuMediaCallType)mediaCallType
                 localMicrophoneEnable:(BOOL)localMicrophoneEnable
                    localSpeakerEnable:(BOOL)localSpeakerEnable
                localCameraOrientation:(DoorDuCallCameraOrientation)localCameraOrientation
                        localVideoView:(DoorDuVideoView *)localVideoView
                       remoteVideoView:(DoorDuVideoView *)remoteVideoView
{
    if (![DoorDuSipCallManager sharedInstance]->_currentCall
        || ([DoorDuSipCallManager sharedInstance].callDirection != kDoorDuCallDirectionIncoming)) {
        return;//判断当前是否有呼叫、判断呼叫方向是不是打进来的电话
    }
    if ([[SipEngineManager sharedInstance] inCalling]) {//检查是否正在通话
        return;
    }
//    [DoorDuSipCallManager clearVideoUI];
    [DoorDuSipCallManager sharedInstance].localCameraOrientation = localCameraOrientation;
    [DoorDuSipCallManager sharedInstance].microphoneEnable = localMicrophoneEnable;
    [DoorDuSipCallManager sharedInstance].speakerEnable = localMicrophoneEnable;
    [DoorDuSipCallManager sharedInstance].localVideoBgView = localVideoView;
    [DoorDuSipCallManager sharedInstance].remoteVideoBgView = remoteVideoView;
    [DoorDuSipCallManager configVideoUI];
    localVideoView.backgroundColor = [UIColor orangeColor];
    remoteVideoView.backgroundColor = [UIColor orangeColor];
    if (mediaCallType == kDoorDuMediaCallTypeVideo) {//本地视频是否开启
        [[SipEngineManager sharedInstance] answerIncomingCall:YES enableVideo:YES];
    } else {
        [[SipEngineManager sharedInstance] answerIncomingCall:YES enableVideo:NO];
    }
}
/**退出、注销当前账号*/
+ (void)logoutSipAccount
{
    //注销当前已注册的SIP账户
    [[SipEngineManager sharedInstance] deRegisterSipAccount];
}
/**刷新当前账号.*/
+ (void)refreshSipRegister
{
    [[SipEngineManager sharedInstance] refreshSipRegister];
}
/**获取当前对话对方的SIP账号*/
+ (NSString *)getCurrentSipAccount
{
    if (![DoorDuSipCallManager sharedInstance]->_currentCall) {
        return nil;
    }
    return [DoorDuSipCallManager sharedInstance].currentSipAccount;
}
/**获取登录者的SIP账号*/
+ (NSString *)getUserSipAccount
{
    return [DoorDuSipCallManager sharedInstance].userSipAccount;
}

/**是否正在通话中*/
+ (BOOL)isCalling
{
    if ([DoorDuSipCallManager sharedInstance]->_currentCall) {
        return [[SipEngineManager sharedInstance] inCalling];
    }
    return NO;
}
/**是否存在通话*/
+ (BOOL)isExistCall
{
    if ([DoorDuSipCallManager sharedInstance]->_currentCall) {
        return YES;
    }
    return NO;
}
/**检测当前SIP是否注册成功*/
+ (BOOL)checkSipRegisteredSussess
{
    return [[SipEngineManager sharedInstance] isSipRegistered];;
}
/**暂停当前通话*/
+ (void)pauseCurrentCall
{
    if ([DoorDuSipCallManager sharedInstance]->_currentCall&& [DoorDuSipCallManager sharedInstance]->_currentCall->support_video()) {
        client::MediaStream *mediaStream = [DoorDuSipCallManager sharedInstance]->_currentCall->media_stream();
        if (!mediaStream) {
            return;
        }
        client::VideoStream *videoStream = mediaStream->video_stream();
        if (!videoStream) {
            return;
        }
        videoStream->SetMediaDirection(client::StreamParams::kNone);
    }
}
/**恢复当前通话*/
+ (void)resumeCurrentCall
{
    if ([DoorDuSipCallManager sharedInstance]->_currentCall&& [DoorDuSipCallManager sharedInstance]->_currentCall->support_video()) {
        //获取当前呼叫的帧率和码率
        SipEngineManager_VideoSize *videoSize = [[SipEngineManager sharedInstance] gainVideoSize];
        float fps = [[SipEngineManager sharedInstance] gainFrameRate];
        float bitrate = [[SipEngineManager sharedInstance] gainBitrate];
        //获取当前呼叫的视频流
        client::VideoStream *videoStream = [DoorDuSipCallManager sharedInstance]->_currentCall->media_stream()->video_stream();
        //重置视频显示控件
        [[DoorDuSipCallManager sharedInstance].localRTCEAGLVideoView resetDisplay];
        [[DoorDuSipCallManager sharedInstance].remoteRTCEAGLVideoView resetDisplay];
        //获取视频引擎对象
        client::RTCVideoEngine *videoEngine = [[SipEngineManager sharedInstance] gainRTCVideoEngine];
        //获取本地摄像头方向
        int cameraOrientation = videoEngine->GetCameraOrientation([DoorDuSipCallManager sharedInstance].localCameraOrientation);
        //设置视频参数
        videoStream->SetupVideoStream([DoorDuSipCallManager sharedInstance].localCameraOrientation
                                      , NULL
                                      , NULL
                                      , [[DoorDuSipCallManager sharedInstance].localRTCEAGLVideoView externalRenderer]
                                      , [[DoorDuSipCallManager sharedInstance].remoteRTCEAGLVideoView externalRenderer]
                                      , (int)[DoorDuSipCallManager gainCameraOrientation:cameraOrientation]
                                      , videoSize->width
                                      , videoSize->height
                                      , bitrate
                                      , fps);
        //设置媒体流为"双向收发"
        videoStream->SetMediaDirection(client::StreamParams::kSendRecv);
        //改变视频尺寸
        [DoorDuSipCallManager changeLocalRemoteVideoSize];
    }
}
/**拒接来电*/
+ (void)rejectCurrentCall
{
    if ([DoorDuSipCallManager sharedInstance]->_currentCall){
        //拒接来电(呼入/呼出)
        [[SipEngineManager sharedInstance] rejectCurrentCall];
    }
}
/**挂断当前呼叫*/
+ (void)hangupCurrentCall
{
    if ([DoorDuSipCallManager sharedInstance]->_currentCall){
        //挂断当前呼叫(呼入/呼出)
        [[SipEngineManager sharedInstance] hangUpCurrentCall];
    }
}
/**切换话筒状态,enable为YES打开话筒、为NO关闭话筒*/
+ (BOOL)switchMicrophone:(BOOL)enable
{
    if ([DoorDuSipCallManager sharedInstance]->_currentCall){
        client::MediaStream *mediaStream = [DoorDuSipCallManager sharedInstance]->_currentCall->media_stream();
        if (!mediaStream) {
            return NO;
        }
        client::AudioStream *audioStream = mediaStream->audio_stream();
        if (!audioStream) {
            return NO;
        }
        //开关话筒
        audioStream->MuteMic(!enable);
        //保存状态
        [DoorDuSipCallManager sharedInstance].microphoneEnable = enable;
        return YES;
    }
    return NO;
}
/**切换扬声器状态,enable为YES打开扬声器、为NO关闭扬声器*/
+ (BOOL)switchSpeaker:(BOOL)enable
{
    if ([DoorDuSipCallManager sharedInstance]->_currentCall){
        //开关扬声器
        client::RTCVoiceEngine *rtcVoiceEngine = [[SipEngineManager sharedInstance] gainRTCVoiceEngine];
        rtcVoiceEngine->SetLoudspeakerStatus(enable);
        //保存状态
        [DoorDuSipCallManager sharedInstance].speakerEnable = enable;
        return YES;
    }
    return NO;
}
/**开关视频，这个接口暂时去掉，用不到，用到的时候再加上*/
+ (BOOL)enableVideo:(BOOL)enable {
    //检查单例变量 & 当前呼叫对象
    if ([DoorDuSipCallManager sharedInstance]->_currentCall) {
        //如果开启视频，则启动收发模式(不会更新信令)
        if (enable) {
            client::MediaStream *mediaStream = [DoorDuSipCallManager sharedInstance]->_currentCall->media_stream();
            if (mediaStream) {
                client::VideoStream *videoStream = mediaStream->video_stream();
                if (videoStream) {
                    videoStream->SetMediaDirection(client::StreamParams::kSendRecv);
                }
            }
            [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeVideo;
        } else {
            [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeAudio;
        }
        //开启或关闭视频流(会更新信令)
        [DoorDuSipCallManager sharedInstance]->_currentCall->UpdateCall(enable);
        return YES;
    }
    [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeUnknown;
    return NO;
}
/**摄像头是否可用*/
+ (BOOL)enableCamera:(BOOL)enable
{
    //检查单例变量 & 当前呼叫对象
    if ([DoorDuSipCallManager sharedInstance]->_currentCall) {
        client::MediaStream *mediaStream = [DoorDuSipCallManager sharedInstance]->_currentCall->media_stream();
        if (!mediaStream) {
            [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeAudio;
            return NO;
        }
        client::VideoStream *videoStream = mediaStream->video_stream();
        if (!videoStream) {
            [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeAudio;
            return NO;
        }
        //开关摄像头
        if (enable) {
            //双向收发媒体流
            videoStream->SetMediaDirection(client::StreamParams::kSendRecv);
            [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeVideo;
        }else {
            //仅接收媒体流
            videoStream->SetMediaDirection(client::StreamParams::kRecvOnly);
            [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeAudio;
        }
        return YES;
    }
    [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeUnknown;
    return NO;
}
/**切换摄像头方向*/
+ (BOOL)switchCameraDirection
{
    //检查单例变量 & 当前呼叫对象
    if ([DoorDuSipCallManager sharedInstance] ->_currentCall) {
        client::MediaStream *mediaStream = [DoorDuSipCallManager sharedInstance]->_currentCall->media_stream();
        if (!mediaStream) {
            return NO;
        }
        client::VideoStream *videoStream = mediaStream->video_stream();
        if (!videoStream) {
            return NO;
        }
        //切换本地摄像头
        client::RTCVideoEngine *videoEngine = [[SipEngineManager sharedInstance] gainRTCVideoEngine];
        int cameraOrientation;
        if([DoorDuSipCallManager sharedInstance].localCameraOrientation == kDoorDuCallCameraOrientationFront) {
            cameraOrientation = videoEngine->GetCameraOrientation(1);
        }else {
            cameraOrientation = videoEngine->GetCameraOrientation(0);
        }
        if ([DoorDuSipCallManager sharedInstance].localCameraOrientation == kDoorDuCallCameraOrientationFront) {
            //切换到后摄像头
            videoStream->ChangeCamera(0, (int)[DoorDuSipCallManager gainCameraOrientation:cameraOrientation], NULL, [[DoorDuSipCallManager sharedInstance].localRTCEAGLVideoView externalRenderer]);
            //更新参数
            [DoorDuSipCallManager sharedInstance].localCameraOrientation = kDoorDuCallCameraOrientationBack;
        }else if ([DoorDuSipCallManager sharedInstance].localCameraOrientation == kDoorDuCallCameraOrientationBack) {
            //切换到前摄像头
            videoStream->ChangeCamera(1, (int)[DoorDuSipCallManager gainCameraOrientation:cameraOrientation], NULL, [[DoorDuSipCallManager sharedInstance].localRTCEAGLVideoView externalRenderer]);
            //更新参数
            [DoorDuSipCallManager sharedInstance].localCameraOrientation = kDoorDuCallCameraOrientationFront;
        }else {
            //切换到前摄像头
            videoStream->ChangeCamera(1, (int)[DoorDuSipCallManager gainCameraOrientation:cameraOrientation], NULL, [[DoorDuSipCallManager sharedInstance].localRTCEAGLVideoView externalRenderer]);
            //更新参数
            [DoorDuSipCallManager sharedInstance].localCameraOrientation = kDoorDuCallCameraOrientationFront;
        }
        //改变视频尺寸
        [DoorDuSipCallManager changeLocalRemoteVideoSize];
        return YES;
    }
    return NO;
}
/**切换媒体流（视频流）模式*/
+ (BOOL)switchVideoStreamDirection:(DoorDuCallVideoStreamDirection)videoStreamDirection
{
    if ([DoorDuSipCallManager sharedInstance] ->_currentCall) {
        client::MediaStream *mediaStream = [DoorDuSipCallManager sharedInstance]->_currentCall->media_stream();
        if (!mediaStream) {
            return NO;
        }
        client::VideoStream *videoStream = mediaStream->video_stream();
        if (!videoStream) {
            return NO;
        }
        switch (videoStreamDirection) {
            case kDoorDuCallVideoStreamDirectionSendRecv:{//接收&发送
                videoStream->SetMediaDirection(client::StreamParams::kSendRecv);
                [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeVideo;
                return YES;
            }break;
            case kDoorDuCallVideoStreamDirectionSendOnly:{//只接收
                videoStream->SetMediaDirection(client::StreamParams::kSendOnly);
                [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeAudio;
                return YES;
            }break;
            case kDoorDuCallVideoStreamDirectionRecvOnly:{//只发送
                videoStream->SetMediaDirection(client::StreamParams::kRecvOnly);
                [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeVideo;
                return YES;
            }break;
            default:{
                return NO;
            }break;
        }
    }
    return NO;
}
/**视频模式切换到语言模式（内部发送DTMF操作）*/
+ (BOOL)switchVideoModeToAudioMode
{
    if ([DoorDuSipCallManager sharedInstance] ->_currentCall) {
        //向远程发送视频切换语音信令(发送dtmf一定要在UpdateCall前面发送，UpdateCall没有完成之前获取通话状态为false)
        [DoorDuSipCallManager sendDTMFWithCode:DTMF_SWITCH_VIDEO_TO_AUDIO];
        //关闭视频，只接收模式(不会更新信令)
        client::MediaStream *mediaStream = [DoorDuSipCallManager sharedInstance]->_currentCall->media_stream();
        if (mediaStream) {
            client::VideoStream *videoStream = mediaStream->video_stream();
            if (videoStream) {
                videoStream->SetMediaDirection(client::StreamParams::kRecvOnly);
            }
        }
        //开启或关闭视频流(会更新信令)
        [DoorDuSipCallManager sharedInstance]->_currentCall->UpdateCall(false);
        [DoorDuSipCallManager sharedInstance].localMediaCallType = kDoorDuMediaCallTypeAudio;
        return YES;
    }
    return NO;
}
@end
