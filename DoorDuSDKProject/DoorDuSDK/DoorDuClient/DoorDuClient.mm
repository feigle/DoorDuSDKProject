//
//  DoorDuClient.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/30.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuClient.h"
#import "DoorDuVideoView.h"
#import "DoorDuSipCallManager.h"
#import "DoorDuMQTTManager.h"
#import "DoorDuProxyInfo.h"
#import "DoorDuNetServices.h"
#import "DoorDuAllRequestParam.h"
#import "DoorDuDataManagerPrivate.h"
#import "DoorDuLog.h"
#import "DoorDuGlobleConfig.h"

@interface DoorDuClient ()<DoorDuSipCallDelegate,DoorDuMQTTDelegate>
{/**使用HTTP接口呼叫的时候记录下，在反呼叫过来的时候，用于接听用*/
    DoorDuMediaCallType  _httpMakeCallMediaCallType;
    BOOL _httpMakeCallLocalMicrophoneEnable;
    BOOL _httpMakeCallLocalSpeakerEnable;
    DoorDuCallCameraOrientation _httpMakeCallLocalCameraOrientation;
    DoorDuVideoView * _httpMakeCallLocalVideoView;
    DoorDuVideoView * _httpMakeCallRemoteVideoView;
}
/**DoorDuClientDelegate 的代理*/
@property (nonatomic,weak) id<DoorDuClientDelegate>clientDelegate;
/**DoorDuCallManagerDelegate 的代理*/
@property (nonatomic,weak) id<DoorDuCallManagerDelegate>callManagerDelegate;
/**DoorDuOptions 配置数据*/
@property (nonatomic,strong) DoorDuOptions * configOpentions;
/**记录下呼叫类型*/
@property (nonatomic,assign) DoorDuCallType makeCallType;
/**内部是否调用的SIP呼叫，不是就是HTTP接口呼叫，默认是NO，这里有作用，在新来电那里，因为是反打的机制，比如：户户通（我拨打电话，其实是接听者调用makeCall接口，在SIP回调的心来电那里（SDK内部接听）*/
@property (nonatomic,assign) BOOL isHTTPMakeCallOther;
/**户户通的时候，HTTP请求时返回过来的房间信息*/
@property (nonatomic,strong) DoorDuCall * doorDuCallModel;
/**收到来电的时候，来电roomID*/
@property (nonatomic,strong) NSString * receiveCallToRoomID;
/**是否呼叫连接成功*/
@property (nonatomic,assign) BOOL isCallConnectedSuccessed;

/**呼叫定时器，超出20秒发送挂断通知*/
@property (nonatomic,strong) NSTimer * callTimeOutTimer;
/**呼叫的时候，定时器挂断时间，默认20s，20s后发送挂断通知给SDK使用者*/
@property (nonatomic,assign) NSInteger callOutTimerNumber;

@end

@implementation DoorDuClient

//静态单例变量
static DoorDuClient * doorDuClient = nil;
#pragma mark (创建线程安全单例)
+ (instancetype)sharedInstance {
    if (doorDuClient == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            doorDuClient = [[DoorDuClient alloc] init];
        });
    }
    return doorDuClient;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupDoorDuClientData];
    }
    return self;
}
#pragma mark - 初始化数据
- (void)setupDoorDuClientData
{
    self.callOutTimerNumber = 30;
}
/**配置SDK初始化参数*/
+ (void)configSDKOptions:(DoorDuOptions *)options
{
    [DoorDuClient sharedInstance].configOpentions = options;
    
    // 环境参数设置
    DoorDuGlobleConfig *globleConfig = [DoorDuGlobleConfig sharedInstance];
    [globleConfig setDoorDuSDKMode:options.mode];
    
    if (options.isShowLog) {
        [DoorDuLog enableLog];
    }else {
        [DoorDuLog disableLog];
    }
}

/**初始化DoorDuSDK*/
+ (void)initDoorDuSDKWithUserInfo:(DoorDuUserInfo *)userInfo
{
    // 连接MQTT服务器
    if (userInfo.topic && userInfo.callerNo) {
        [DoorDuMQTTManager setDelegate:[DoorDuClient sharedInstance]];
        [DoorDuMQTTManager conenctWithTopics:userInfo.topic clientID:userInfo.callerNo];
    }
    
    // 连接sip服务器
    if (![userInfo.ice boolValue]) {
        userInfo.coturnServer = nil;
        userInfo.coturnPort = nil;
        userInfo.coturnServer = nil;
        userInfo.coturnPort = nil;
        userInfo.coturnUser = nil;
        userInfo.coturnPass = nil;
    }
    
    
    [DoorDuSipCallManager registrationDelegate:[DoorDuClient sharedInstance]];
    [DoorDuSipCallManager registerSipAccount:userInfo.callerNo
                                 sipAuthName:nil
                                 sipPassword:userInfo.callerPassword
                                   sipDomain:[NSString stringWithFormat:@"%@:%@", userInfo.callerDomain, userInfo.tlsPort]
                             supportSipProxy:NO
                                    sipProxy:nil
                            sipTransportType:kSipEngineManager_SipTransportType_TLS
                               supportWebrtc:NO
                               supportRtcpFb:[userInfo.rtcpFb boolValue]
                                   sipExpire:1800
                              sipDisplayName:nil
                                   keepAlive:YES
                                   videoType:kSipEngineManager_VideoType_QVGA
                                  stunServer:nil
                              stunServerPort:nil
                                  turnServer:userInfo.coturnServer
                              turnServerPort:userInfo.coturnPort
                                turnUserName:userInfo.coturnUser
                                turnPassword:userInfo.coturnPass];
    
}

/**
 注册clientDelegate
 */
+ (void)registClientDelegate:(id<DoorDuClientDelegate>)delegate
{
    [DoorDuClient sharedInstance].clientDelegate = delegate;
}
/**移除clientDelegate代理*/
+ (void)removeClientDelegate
{
    [DoorDuClient sharedInstance].clientDelegate = nil;
}
/**注册通话状态回调*/
+ (void)registCallManagerDelegate:(id<DoorDuCallManagerDelegate>)delegate
{
    [DoorDuClient sharedInstance].callManagerDelegate = delegate;
}
/**移除通话状态管理*/
+ (void)removeCallManagerDelegate
{
    [DoorDuClient sharedInstance].callManagerDelegate = nil;
}

#pragma mark - 这里是调用    DoorDuSipCallManager 的一些方法接口
#pragma mark - /**呼叫接口*/
+ (void)makeCallWithCallType:(DoorDuCallType)callType
               mediaCallType:(DoorDuMediaCallType)mediaCallType
       localMicrophoneEnable:(BOOL)localMicrophoneEnable
          localSpeakerEnable:(BOOL)localSpeakerEnable
      localCameraOrientation:(DoorDuCallCameraOrientation)localCameraOrientation
              remoteCallerID:(NSString *)remoteCallerID
              localVideoView:(DoorDuVideoView *)localVideoView
             remoteVideoView:(DoorDuVideoView *)remoteVideoView
                  fromRoomID:(NSString *)fromRoomID
                    toRoomNo:(NSString *)toRoomNO
{
    [DoorDuClient sharedInstance].makeCallType = callType;
    if (callType == kDoorDuCallEachFamilyAccess) {
        [DoorDuClient sharedInstance].isHTTPMakeCallOther = YES;
        /**这里需要请求HTTP接口拨打呼叫电话，后台通过MQTT推送给对应房间的用户，对应房间用户会收到MQTT的推送，这是要过滤调是不是这个人（通过SIP账号），不是就通知到SDK外部，让开发者吊起来电通知*/
        [DoorDuClient sharedInstance]->_httpMakeCallMediaCallType = mediaCallType;
        [DoorDuClient sharedInstance]->_httpMakeCallLocalMicrophoneEnable = localMicrophoneEnable;
        [DoorDuClient sharedInstance]->_httpMakeCallLocalSpeakerEnable = localSpeakerEnable;
        [DoorDuClient sharedInstance]->_httpMakeCallLocalCameraOrientation = localCameraOrientation;
        [DoorDuClient sharedInstance]->_httpMakeCallLocalVideoView = localVideoView;
        [DoorDuClient sharedInstance]->_httpMakeCallRemoteVideoView = remoteVideoView;
        /**这里请求HTTP接口，呼叫对应的房间号，callTypeStr：0-语音呼叫、1-视频呼叫*/
        NSString * callTypeStr = mediaCallType== kDoorDuMediaCallTypeAudio?@"0":@"1";
        __weak __typeof(self)weakSelf = self;
        [DoorDuDataManagerPrivate makeCall:[[[UIDevice currentDevice] identifierForVendor] UUIDString] fromRoomId:fromRoomID toRoomId:@"" toRoomNo:toRoomNO callType:callTypeStr completion:^(DoorDuCall *callData, DoorDuError *error) {
            /**呼叫回调 ，如果失败了回调出去*/
            __strong __typeof(weakSelf)strongSelf = weakSelf;
#warning callData 这里缺少一个参数，一个要拨打对方的roomID（对应拨打房号唯一标示符）
            if (!error) {/**请求成功*/
                [DoorDuClient sharedInstance].doorDuCallModel = callData;
                /**通知后台服务器拨打电话成功，开启呼叫定时器*/
                [strongSelf __startCallTimeOutTimer];
            } else {/**拨打失败*/
                [strongSelf __clearDoorDuClientCallData];
                [[DoorDuClient sharedInstance] sipCallFailedOrWrong];
            }
        }];
    } else if (callType == kDoorDuCallDoor){
        [DoorDuSipCallManager makeCallWithCallType:callType mediaCallType:mediaCallType localMicrophoneEnable:localMicrophoneEnable localSpeakerEnable:localSpeakerEnable localVideoView:localVideoView localCameraOrientation:localCameraOrientation remoteCallerID:remoteCallerID remoteVideoView:remoteVideoView];
        /**开启呼叫定时器*/
        [self __startCallTimeOutTimer];
    }
}
#pragma mark - /**接听接口,所有的接听都是反打过去*/
+ (void)answerCallWithCallType:(DoorDuCallType)callType
                 mediaCallType:(DoorDuMediaCallType)mediaCallType
         localMicrophoneEnable:(BOOL)localMicrophoneEnable
            localSpeakerEnable:(BOOL)localSpeakerEnable
        localCameraOrientation:(DoorDuCallCameraOrientation)localCameraOrientation
                remoteCallerID:(NSString *)remoteCallerID
                localVideoView:(DoorDuVideoView *)localVideoView
               remoteVideoView:(DoorDuVideoView *)remoteVideoView
{
    [DoorDuClient sharedInstance].makeCallType = callType;
    /**这里接通其实是反打过去SIP，这接通成功的时候发送一个MQTT消息（sipTheCallIsConnectedDirection:），告诉其他想接通的人我这里已经接通了，你们可以挂断了，这里过滤掉自己挂断，因为这时自己也会收到这个MQTT推送订阅*/
    /**这里的接听其实是SIP反呼叫过去，*/
    [DoorDuSipCallManager makeCallWithCallType:callType mediaCallType:mediaCallType localMicrophoneEnable:localMicrophoneEnable localSpeakerEnable:localSpeakerEnable localVideoView:localVideoView localCameraOrientation:localCameraOrientation remoteCallerID:remoteCallerID remoteVideoView:remoteVideoView];
    /**
     [DoorDuSipCallManager answerSipCallWithMediaCallType:mediaCallType localMicrophoneEnable:localMicrophoneEnable localSpeakerEnable:localSpeakerEnable localCameraOrientation:localCameraOrientation localVideoView:localVideoView remoteVideoView:remoteVideoView];
     */
}
#pragma mark - /**是否正在通话中*/
+ (BOOL)isCalling
{
    return [DoorDuSipCallManager isCalling];
}
#pragma mark - /**是否存在通话*/
+ (BOOL)isExistCall
{
    return [DoorDuSipCallManager isExistCall];
}
#pragma mark - /**拒接来电*/
+ (void)rejectCurrentCall
{
    [[self class] __endCallTimeOutTimer];
    [DoorDuSipCallManager rejectCurrentCall];
}
#pragma mark - /**挂断当前呼叫*/
+ (void)hangupCurrentCall
{
    if ([self isExistCall]) {/**判断当前是否在通话中，如果在通话中就挂断电话，如果没有接通就发送MQTT消息，主叫方挂断了消息，其他接听了也要挂断了*/
        [DoorDuSipCallManager hangupCurrentCall];
    } else {/**发送MQTT消息，发送挂断通知*/
        if ([DoorDuClient sharedInstance].doorDuCallModel) {
            [DoorDuMQTTManager publishCallEnd:@"" roomID:[DoorDuClient sharedInstance].doorDuCallModel.toRoomId transactionID:[DoorDuClient sharedInstance].doorDuCallModel.transactionId];
        }
    }
    
    [self __clearDoorDuClientCallData];
}

/**切换话筒状态,enable为YES打开话筒、为NO关闭话筒*/
+ (BOOL)switchMicrophone:(BOOL)enable
{
    return [DoorDuSipCallManager switchMicrophone:enable];
}

/**切换扬声器状态,enable为YES打开扬声器、为NO关闭扬声器*/
+ (BOOL)switchSpeaker:(BOOL)enable;
{
    return [DoorDuSipCallManager switchMicrophone:enable];
}

#pragma mark - /**切换摄像头方向*/
+ (BOOL)switchCameraDirection
{
    return [DoorDuSipCallManager switchCameraDirection];
}
#pragma mark - /**视频模式切换到语言模式*/
+ (BOOL)switchVideoModeToAudioMode
{
    return [DoorDuSipCallManager switchVideoModeToAudioMode];
}
#pragma mark - /**退出注销当前账号*/
+ (void)logoutCurrentAccount
{
    [self __clearDoorDuClientCallData];
    [DoorDuMQTTManager clearCurrentSession];
    [DoorDuSipCallManager logoutSipAccount];
}
/**************************以上是   DoorDuSipCallManager 对外的接口*/
#pragma mark -----------------------  DoorDuSipCallDelegate《sip管理的代理方法回调》
/**Sip正在注册*/
- (void)sipIsRegistering
{
    
}
/**Sip注册成功*/
- (void)sipRegistrationSuccess
{
    
}
/**Sip注销成功*/
- (void)sipCanceledSuccessfully
{
    
}
/**Sip注册失败*/
- (void)sipRegistrationFailed:(DoorDuSipRegistErrorCode)errorCode errorMessage:(NSString *)errorMessage
{
    
}
/**Sip新的呼叫（呼入/呼出），callDirection：呼叫方向，incomingCallType：呼叫来电类型，callerSipID：呼叫ID，remoteCallName（这个现在已经没有了，remoteCallName老版本的）*/
- (void)sipNewCallDirection:(DoorDuCallDirection)callDirection
           incomingCallType:(DoorDuCurrentIncomingCallType)incomingCallType
                callerSipID:(NSString *)callerSipID
             remoteCallName:(NSString *)remoteCallName
{
    /**来新消息了，户户通的时候，别人反打过来的，这里用代码接听*/
    if ([DoorDuClient sharedInstance].isHTTPMakeCallOther) {
        /**这里是通过HTTP接口呼叫别人，别人用SIP反呼叫过来的，这里就用代码接听*/
        /**这里调用SIP的接听接口*/
        [DoorDuSipCallManager answerSipCallWithMediaCallType:_httpMakeCallMediaCallType localMicrophoneEnable:_httpMakeCallLocalMicrophoneEnable localSpeakerEnable:_httpMakeCallLocalSpeakerEnable localCameraOrientation:_httpMakeCallLocalCameraOrientation localVideoView:_httpMakeCallLocalVideoView remoteVideoView:_httpMakeCallRemoteVideoView];
    }
}
/**Sip呼叫被取消(呼入/呼出)，callDirection   呼叫方向.*/
- (void)sipTheCallIsCanceledDirection:(DoorDuCallDirection)callDirection
{
    [[self class] __clearDoorDuClientCallData];
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidTheCallIsCanceled)]) {
        [self.callManagerDelegate callDidTheCallIsCanceled];
    }
}
/**Sip呼叫失败或错误（呼入/呼出）*/
- (void)sipCallFailedOrWrong
{
    [[self class] __clearDoorDuClientCallData];
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidCallFailedOrWrong)]) {
        [self.callManagerDelegate callDidCallFailedOrWrong];
    }
}
/**Sip呼叫被拒接*/
- (void)sipTheCallWasRejected
{
    [[self class] __clearDoorDuClientCallData];
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidTheCallWasRejected)]) {
        [self.callManagerDelegate callDidTheCallWasRejected];
    }
}
/**Sip正在建立连接（呼叫）*/
- (void)sipCallConnectionIsBeingEstablished
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidCallConnectionIsBeingEstablished)]) {
        [self.callManagerDelegate callDidCallConnectionIsBeingEstablished];
    }
}
/**Sip被叫方振铃*/
- (void)sipTheCalledPartyRings
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidTheCalledPartyRings)]) {
        [self.callManagerDelegate callDidTheCalledPartyRings];
    }
}
/**Sip呼叫接通（呼入/呼出），callDirection：呼叫方向.，supportVideo：呼叫是否支持视频，supportData：呼叫是否支持数据.*/
#pragma mark - 呼叫建立连接了
- (void)sipTheCallIsConnectedDirection:(DoorDuCallDirection)callDirection
                          supportVideo:(BOOL)supportVideo
                           supportData:(BOOL)supportData
{
    [DoorDuClient sharedInstance].isCallConnectedSuccessed = YES;
    /**如果是接通需要发送MQTT推送消息，告知其他房间人，我这里接通了，除了直接呼叫门禁机，只要反打都需要，本类的answerCallWithCallType都是反打机制*/
    if (![DoorDuClient sharedInstance].isHTTPMakeCallOther) {/**只要是本类的answerCallWithCallType，都是反打机制，在理需要发送MQTT告知这里接听 了，其他终端可以挂断了*/
#pragma mark - 这是别人打过来，反打过去的时候，发送一个MQTT消息告知其他同房间用户接听了，你们可以挂断电话了
#pragma mark - 这里不是户户通拨打着，接听之后需要发送挂断消息，户户通打过来和门禁机打过来，反打过去的时候建立通话之后需要发送一个挂断消息，告知其他用户可以挂断了
        if ([DoorDuClient sharedInstance].makeCallType != kDoorDuCallNone) {
            [DoorDuMQTTManager publishCallConnected:[DoorDuSipCallManager getUserSipAccount] roomID:self.receiveCallToRoomID transactionID:[DoorDuMqttMessageHandle sharedInstance].transcationID];
        }
    }
    [[self class] __endCallTimeOutTimer];
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidTheCallIsConnectedSupportVideo:supportData:)]) {
        [self.callManagerDelegate callDidTheCallIsConnectedSupportVideo:supportVideo supportData:supportData];
    }
}
/**Sip呼叫结束（呼入/呼出），callDirection   呼叫方向.*/
- (void)sipTheCallEndsDirection:(DoorDuCallDirection)callDirection
{
    [[self class] __clearDoorDuClientCallData];
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidTheCallEnds)]) {
        [self.callManagerDelegate callDidTheCallEnds];
    }
}
/**Sip正在设置呼叫暂停(呼入/呼出)，callDirection   呼叫方向.*/
- (void)sipACallPauseIsBeingSetDirection:(DoorDuCallDirection)callDirection
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidACallPauseIsBeingSet)]) {
        [self.callManagerDelegate callDidACallPauseIsBeingSet];
    }
}
/**Sip呼叫已暂停(呼入/呼出)，callDirection   呼叫方向.*/
- (void)sipTheCallIsPausedDirection:(DoorDuCallDirection)callDirection
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidTheCallIsPaused)]) {
        [self.callManagerDelegate callDidTheCallIsPaused];
    }
}
/**Sip正在设置终止呼叫暂停（呼入/呼出），callDirection   呼叫方向.*/
- (void)sipSettingUpTerminationCallPauseDirection:(DoorDuCallDirection)callDirection
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidSettingUpTerminationCallPause)]) {
        [self.callManagerDelegate callDidSettingUpTerminationCallPause];
    }
}
/**Sip已终止呼叫暂停，恢复通话（呼入/呼出），callDirection   呼叫方向.*/
- (void)sipTerminatedCallPauseResumeCallDirection:(DoorDuCallDirection)callDirection
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidTerminatedCallPauseResume)]) {
        [self.callManagerDelegate callDidTerminatedCallPauseResume];
    }
}
/**Sip呼叫远程设置正在更新（远程） */
- (void)sipCallRemoteSettingsAreBeingUpdated
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidCallRemoteSettingsAreBeingUpdated)]) {
        [self.callManagerDelegate callDidCallRemoteSettingsAreBeingUpdated];
    }
}
/**Sip呼叫远程设置已更新（远程）*/
- (void)sipCallRemoteSettingsHaveBeenUpdated
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidCallRemoteSettingsHaveBeenUpdated)]) {
        [self.callManagerDelegate callDidCallRemoteSettingsHaveBeenUpdated];
    }
}
/**Sip呼叫转移被接受（呼入/呼出），呼叫方向.*/
- (void)sipCallTransferIsAcceptedDirection:(DoorDuCallDirection)callDirection
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidCallTransferIsAccepted)]) {
        [self.callManagerDelegate callDidCallTransferIsAccepted];
    }
}
/**Sip呼叫转移被拒绝（呼入/呼出）,callDirection   呼叫方向.*/
- (void)sipCallForwardingIsRejectedDirection:(DoorDuCallDirection)callDirection
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidCallForwardingIsRejected)]) {
        [self.callManagerDelegate callDidCallForwardingIsRejected];
    }
}
/**Sip媒体就绪（语音媒体流就绪）*/
- (void)sipVoiceMediaStreamReady
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidVoiceMediaStreamReady)]) {
        [self.callManagerDelegate callDidVoiceMediaStreamReady];
    }
}
/**Sip媒体就绪（视频媒体流就绪）*/
- (void)sipVideoMediaStreamReady
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidVideoMediaStreamReady)]) {
        [self.callManagerDelegate callDidVideoMediaStreamReady];
    }
}
/**Sip媒体就绪（数据媒体流就绪）*/
- (void)sipDataMediaStreamReady
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidDataMediaStreamReady)]) {
        [self.callManagerDelegate callDidDataMediaStreamReady];
    }
}
/**Sip远程视频画面尺寸改变*/
- (void)sipRemoteVideoScreenSizeChangeWidth:(NSInteger)width height:(NSInteger)height
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidRemoteVideoScreenSizeChangeWidth:height:)]) {
        [self.callManagerDelegate callDidRemoteVideoScreenSizeChangeWidth:width height:height];
    }
}
/**Sip远程视频码率和帧率*/
- (void)sipRemoteVideoFps:(NSInteger)fps bitrate:(NSInteger)bitrate
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidRemoteVideoFps:bitrate:)]) {
        [self.callManagerDelegate callDidRemoteVideoFps:fps bitrate:bitrate];
    }
}
/**Sip本地视频码率和帧率*/
- (void)sipLocalVideoFps:(NSInteger)fps bitrate:(NSInteger)bitrate
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidLocalVideoFps:bitrate:)]) {
        [self.callManagerDelegate callDidLocalVideoFps:fps bitrate:bitrate];
    }
}
/**Sip收到远程终端由视频模式切换到语音模式*/
- (void)sipReceiveRemoteSwitchVideoModeToAudioMode
{
    if ([self.callManagerDelegate respondsToSelector:@selector(callDidReceiveRemoteSwitchVideoModeToAudioMode)]) {
        [self.callManagerDelegate callDidReceiveRemoteSwitchVideoModeToAudioMode];
    }
}
/*******************以上是  DoorDuSipCallDelegate《sip管理的代理方法回调》 *****************/
#pragma mark -----------------------  DoorDuMQTTDelegate《接收DoorDuMQTTDelegate代理》
/*mqtt连接成功*/
- (void)mqttConnectedSuccess
{
    DoorDuLogDebug(@"长链接-连接成功");
}
/*mqtt断开连接*/
- (void)mqttConnectedClosed
{
    DoorDuLogDebug(@"长链接-断开了");
}
/*mqtt连接失败*/
- (void)mqttConnectError:(NSError *)error
{
    DoorDuLogDebug(@"长链接-连接失败%@",error);
}
/*mqtt连接被拒*/
- (void)mqttConnectRefused:(NSError *)error
{
    DoorDuLogDebug(@"长链接-连接被拒%@",error);
}
#pragma mark - 这里都是后台推过来的，需要反打过去
/*app来电推送消息，这里主要是户户通的时候来电*/
- (void)appIncomingMessage:(DoorDuEachFamilyAccessCallModel *)model
{
    /**判断是不是我自己呼叫的,不是自己的呼叫就要通知外包SDK使用者调起来电通知，让SDK使用者调用接听电话*/
    if (![model.appCallerNO isEqualToString:[DoorDuProxyInfo sharedInstance].userInfo.callerNo]) {
        if (![[self class] isExistCall]) {/**不存在通话的情况下回调*/
            DoorDuLogDebug(@"远程推送-有新来电（户户通）");
            [DoorDuClient sharedInstance].receiveCallToRoomID = model.remoteRoomID;
            if ([self.clientDelegate respondsToSelector:@selector(callDidReceiveEachFamilyAccess:)]) {
                [self.clientDelegate callDidReceiveEachFamilyAccess:model];
                /**开启呼叫定时器*/
                [[self class] __startCallTimeOutTimer];
            }
        }
    }
}
/*门禁来电推送消息*/
- (void)doorIncomingMessage:(DoorDuDoorCallModel *)model
{
    /**这里为了避免服务器出现错误，反呼叫门禁，按理可以不用判断的*/
    if (![model.doorCallerNO isEqualToString:[DoorDuProxyInfo sharedInstance].userInfo.callerNo]) {
        if (![[self class] isExistCall]) {/**不存在通话的情况下回调*/
            DoorDuLogDebug(@"远程推送-有新来电（门禁）");
            [DoorDuClient sharedInstance].receiveCallToRoomID = model.appRoomID;
            if ([self.clientDelegate respondsToSelector:@selector(callDidReceiveDoor:)]) {
                [self.clientDelegate callDidReceiveDoor:model];
                /**开启呼叫定时器*/
                [[self class] __startCallTimeOutTimer];
            }
        }
    }
}
/*挂断推送消息*/
- (void)hangupMessage
{/**DoorDuMQTTManager里面处理了过滤自己发送的挂断消息*/
    if (![[self class] isExistCall] || [DoorDuSipCallManager currentCallStatus] != kDoorDuAnswered) {/**不存在通话的情况下回调*/
        DoorDuLogDebug(@"远程推送-收到挂断通知");
        if ([self.clientDelegate respondsToSelector:@selector(callDidHangupMessage)]) {
            [self.clientDelegate callDidHangupMessage];
        }
        [[self class] __clearDoorDuClientCallData];
        
        if ([DoorDuSipCallManager currentCallStatus] != kDoorDuAnswered) {
            [[self class] hangupCurrentCall];
        }
    }
}
/*****************以上是  DoorDuMQTTDelegate《接收DoorDuMQTTDelegate代理》 *****************/
#pragma mark - DoorDuClient 私有的方法
/**清空呼叫时候的一些数据*/
+ (void)__clearDoorDuClientCallData
{
    [DoorDuClient sharedInstance].makeCallType = kDoorDuCallNone;
    [DoorDuClient sharedInstance].doorDuCallModel = nil;
    [DoorDuClient sharedInstance].receiveCallToRoomID = nil;
    //这里就不接听电话了，如果有来电也不自动接听了
    [DoorDuClient sharedInstance].isHTTPMakeCallOther = NO;
    [[DoorDuMqttMessageHandle sharedInstance] clearTransaction];
    [DoorDuClient sharedInstance].isCallConnectedSuccessed = NO;
    [DoorDuClient sharedInstance]->_httpMakeCallMediaCallType = kDoorDuMediaCallTypeNone;
    [DoorDuClient sharedInstance]->_httpMakeCallLocalMicrophoneEnable = NO;
    [DoorDuClient sharedInstance]->_httpMakeCallLocalSpeakerEnable = NO;
    [DoorDuClient sharedInstance]->_httpMakeCallLocalCameraOrientation = kDoorDuCallCameraOrientationBack;
    [DoorDuClient sharedInstance]->_httpMakeCallLocalVideoView = nil;
    [DoorDuClient sharedInstance]->_httpMakeCallRemoteVideoView = nil;
}
/**开启定时器，监听呼叫是否超时，超时的时候，回调挂断回调*/
+ (void)__startCallTimeOutTimer
{
    [[DoorDuClient sharedInstance] __startCallTimeOutTimer];
}
/**开启定时器对象方法*/
- (void)__startCallTimeOutTimer
{
    if (_callTimeOutTimer) {
        [_callTimeOutTimer invalidate];
        _callTimeOutTimer = nil;
    }
    _callTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:self.callOutTimerNumber target:self selector:@selector(__callTimeOutEnd) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_callTimeOutTimer forMode:NSRunLoopCommonModes];
}
/**取消定时器*/
+ (void)__endCallTimeOutTimer
{
    [[DoorDuClient sharedInstance] __endCallTimeOutTimer];
}
- (void)__endCallTimeOutTimer
{
    if (_callTimeOutTimer) {
        [_callTimeOutTimer invalidate];
        _callTimeOutTimer = nil;
    }
}
/**呼叫超时*/
- (void)__callTimeOutEnd
{
    DoorDuLogDebug(@"呼叫超时---了");
    [[self class] __clearDoorDuClientCallData];
    [self hangupMessage];
}
/*****************以上是  DoorDuClient 私有的方法 *****************/


@end
