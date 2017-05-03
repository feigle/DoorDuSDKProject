//
//  UserIncomingViewController.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/19.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "UserIncomingViewController.h"
#import "DoorDuClient.h"
#import "DoorDuAudioPlayer.h"
#import "DoorDuVideoView.h"
#import "AppHelp.h"

@interface UserIncomingViewController ()<DoorDuCallManagerDelegate>
{
    NSTimer *_timer;
    NSTimer *_callTimeOutTimer;
    int _min;
    int _sec;
}

@property (weak, nonatomic, readwrite) IBOutlet DoorDuVideoView *videoView;//终端上显示门禁机来电视频控件
@property (weak, nonatomic, readwrite) IBOutlet NSLayoutConstraint *videoViewWidthConstraint;

@property (weak, nonatomic, readwrite) IBOutlet DoorDuVideoView *videoPreview;//终端上显示用户视频控件

@property (weak, nonatomic, readwrite) IBOutlet UIView *tips_layoutView;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic, readwrite) IBOutlet UIImageView *tipsHeadImageView;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *fromRoomNameLabel;

@property (weak, nonatomic, readwrite) IBOutlet UIView *acceptMode_layoutView;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *acceptMode_acceptButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *acceptMode_turnOffButton;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *acceptMode_acceptLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *acceptMode_turnOffLabel;

@property (weak, nonatomic, readwrite) IBOutlet UIView *waitMode_layoutView;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *waitMode_hungUpButton;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *waitMode_turnOffLabel;

@property (weak, nonatomic, readwrite) IBOutlet UIView *audioMode_layoutView;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *audioMode_micLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *audioMode_turnOffLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *audioMode_speakerLabel;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *audioMode_micButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *audioMode_turnOffButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *audioMode_speakerButton;

@property (weak, nonatomic, readwrite) IBOutlet UIView *videoMode_layoutView;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *videoMode_switchAudioLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *videoMode_turnoffLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *videoMode_switchCameraLabel;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *videoMode_switchAudioButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *videoMode_turnOffButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *videoMode_switchCameraButton;

@property (assign, nonatomic, readwrite) BOOL isEnableMic;//话筒是否开启
@property (assign, nonatomic, readwrite) BOOL isEnableSpeaker;//扬声器是否开启
@property (assign, nonatomic, readwrite) BOOL isFontCamera;//是否前摄像头

@property (assign, nonatomic, readwrite) IBOutlet UILabel *timeLabel;

@property (assign, nonatomic, readwrite) BOOL onCallConnected;//呼叫是否已连接
@property (assign, nonatomic, readwrite) BOOL isHangUp;//是否本地挂断


@end

@implementation UserIncomingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isStartAutoAccept = NO;
    self.onCallConnected = NO;
    //摄像头默认前摄像头
    self.isFontCamera = YES;
    
    _min = 0;
    _sec = 0;
    
    [self initUI];
}

- (void)initUI
{
    //时间
    self.timeLabel.hidden = YES;
    self.timeLabel.text = @"00:00";

    //提示控件
    self.tips_layoutView.hidden = NO;
    if (self.mediaCallType == kDoorDuMediaCallTypeAudio) {
        self.tipsLabel.text = NSLocalizedString(@"邀请你语音聊天", nil);
    }else {
        self.tipsLabel.text = NSLocalizedString(@"邀请你视频聊天", nil);
    }
    
    if (self.fromRoomName && ![self.fromRoomName isEqualToString:@""]) {
        self.fromRoomNameLabel.text = self.fromRoomName;
    }else {
        self.fromRoomNameLabel.text = @"户户通来电呼叫";
    }
    
    //显示布局
    self.acceptMode_layoutView.hidden = NO;
    self.waitMode_layoutView.hidden = YES;
    self.audioMode_layoutView.hidden = YES;
    self.videoMode_layoutView.hidden = YES;
    
    self.videoPreview.hidden = YES;
    self.acceptMode_layoutView.hidden = NO;
    self.isHangUp = NO;
    if (self.mediaCallType == kDoorDuMediaCallTypeAudio) {
        //语音模式默认开启麦克风和话筒
        self.isEnableMic = YES;
        self.isEnableSpeaker = YES;
    }else {
        //视频模式默认开启麦克风和话筒
        self.isEnableMic = YES;
        self.isEnableSpeaker = YES;
    }
    
    //设置图片
    if (self.isEnableMic) {
        [self.audioMode_micButton setBackgroundImage:[UIImage imageNamed:@"关闭的静音"] forState:UIControlStateNormal];
    }else {
        [self.audioMode_micButton setBackgroundImage:[UIImage imageNamed:@"开启的静音"] forState:UIControlStateNormal];
    }
    
    if (self.isEnableSpeaker) {
        [self.audioMode_speakerButton setBackgroundImage:[UIImage imageNamed:@"开启的免提"] forState:UIControlStateNormal];
    }else {
        [self.audioMode_speakerButton setBackgroundImage:[UIImage imageNamed:@"关闭的免提"] forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //播放来电语音
    [[DoorDuAudioPlayer sharedInstance] playIncomingAudio:YES];
    
    [DoorDuClient registCallManagerDelegate:self];
    
    //开启请求超时监听
    if (_callTimeOutTimer) {
        
        [_callTimeOutTimer invalidate];
        _callTimeOutTimer = nil;
    }
    
    _callTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:40
                                                         target:self
                                                       selector:@selector(callAutoEnd)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)callAutoEnd {
    
    if (!self.isStartAutoAccept) {
        [self dismissSelf];
    }
}

- (void)dismissSelf
{
    if (_timer) {
        if (_timer.isValid) {
            [_timer invalidate];
        }
        _timer = nil;
    }
    if (_callTimeOutTimer.isValid) {
        [_callTimeOutTimer invalidate];
    }
    //停止播放音效
    [[DoorDuAudioPlayer sharedInstance] stopPlayAudioAndVibrate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark (接听按钮动作)
- (IBAction)acceptButtonAction:(id)sender {
    
    self.isStartAutoAccept = YES;
    
    //播放呼出语音
    [[DoorDuAudioPlayer sharedInstance] playOutgoingAudio:YES];
    
    if ([AppHelp checkMediaAndAudioAuthStateWithParentViewController:self]) {
        
        self.tipsLabel.text = @"正在启动...";
        self.acceptMode_turnOffButton.enabled = NO;
        self.acceptMode_acceptButton.enabled = NO;
        
        self.acceptMode_layoutView.hidden = YES;
        self.waitMode_layoutView.hidden = NO;
        self.audioMode_layoutView.hidden = YES;
        self.videoMode_layoutView.hidden = YES;

        DoorDuMediaCallType callType = (self.mediaCallType == kDoorDuMediaCallTypeAudio) ? kDoorDuMediaCallTypeAudio : kDoorDuMediaCallTypeVideo;
        DoorDuCallCameraOrientation cameralOrientation = (self.isFontCamera ? kDoorDuCallCameraOrientationFront : kDoorDuCallCameraOrientationBack);
        
        [DoorDuClient answerCallWithCallType:kDoorDuCallEachFamilyAccess mediaCallType:callType localMicrophoneEnable:self.isEnableMic localSpeakerEnable:self.isEnableSpeaker localCameraOrientation:cameralOrientation remoteCallerID:self.fromSipNO localVideoView:self.videoPreview remoteVideoView:self.videoView];

    }
}

#pragma mark -
#pragma mark (通话操作)
- (IBAction)rejectButtonAction:(id)sender {
    
    [DoorDuClient rejectCurrentCall];
    [self dismissSelf];
}

- (IBAction)hangUpButtonAction:(id)sender {
    
    self.isHangUp = YES;
    [DoorDuClient hangupCurrentCall];
    [self showWithTitle:@"通话结束"];
    [self dismissSelf];
}

- (IBAction)micButtonAction:(id)sender {
    if (self.isEnableMic) {
        //关闭麦克风
        [self.audioMode_micButton setBackgroundImage:[UIImage imageNamed:@"开启的静音"] forState:UIControlStateNormal];
        self.isEnableMic = false;
        [DoorDuClient switchMicrophone:NO];
    }else {
        //开启麦克风
        [self.audioMode_micButton setBackgroundImage:[UIImage imageNamed:@"关闭的静音"] forState:UIControlStateNormal];
        self.isEnableMic = true;
        [DoorDuClient switchMicrophone:YES];
    }
}

- (IBAction)speakerButtonAction:(id)sender {
    
    if (self.isEnableSpeaker) {
        //关闭免提
        [self.audioMode_speakerButton setBackgroundImage:[UIImage imageNamed:@"关闭的免提"] forState:UIControlStateNormal];
        self.isEnableSpeaker = false;
        self.tipsLabel.text = @"请使用听筒接听";
        [DoorDuClient switchSpeaker:NO];
        
    }else {
        //开启免提
        [self.audioMode_speakerButton setBackgroundImage:[UIImage imageNamed:@"开启的免提"] forState:UIControlStateNormal];
        self.isEnableSpeaker = true;
        self.tipsLabel.text = @"";
        [DoorDuClient switchSpeaker:YES];
    }
}

#pragma mark -
#pragma mark (切换语音按钮动作)
- (IBAction)switchAudioButtonAction:(id)sender {
    
    [self showWithTitle:@"已切到语音聊天"];
    
    //切换语音模式
    [DoorDuClient switchVideoModeToAudioMode];
    
    //布局设置
    self.videoPreview.hidden = YES;
    self.tips_layoutView.hidden = NO;
    self.acceptMode_layoutView.hidden = YES;
    self.audioMode_layoutView.hidden = NO;
    self.videoMode_layoutView.hidden = YES;
    
    //开启计时
    [self startTimer];
    
    //提示语
    if (!self.isEnableSpeaker) {
        self.tipsLabel.text = @"请使用听筒接听";
    }else {
        self.tipsLabel.text = @"";
    }
    
    //关闭静音(开启麦克风)
    self.isEnableMic = true;
    [self.audioMode_micButton setBackgroundImage:[UIImage imageNamed:@"关闭的静音"] forState:UIControlStateNormal];
    [DoorDuClient switchMicrophone:YES];
    
    //开启免提(开启听筒)
    self.isEnableSpeaker = true;
    [self.audioMode_speakerButton setBackgroundImage:[UIImage imageNamed:@"开启的免提"] forState:UIControlStateNormal];
    self.tipsLabel.text = @"";
    [DoorDuClient switchSpeaker:YES];
}

#pragma mark -
#pragma mark (开启计时)
- (void)startTimer {
    
    self.timeLabel.hidden = NO;
    if (_timer) {
        
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.f
                                              target:self
                                            selector:@selector(timerFunction)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)timerFunction {
    
    _sec = _sec + 1;
    if (_sec == 60) {
        _sec = 0;
        _min = _min + 1;
    }
    
    NSString *min1 = @"";
    if (_min < 10) {
        min1 = [NSString stringWithFormat:@"0%d", _min];
    }else {
        min1 = [NSString stringWithFormat:@"%d", _min];
    }
    
    NSString *sec1 = @"";
    if (_sec < 10) {
        sec1 = [NSString stringWithFormat:@"0%d", _sec];
    }else {
        sec1 = [NSString stringWithFormat:@"%d", _sec];
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@", min1, sec1];
}


#pragma mark -
#pragma mark (切换摄像头按钮动作)
- (IBAction)switchCameraButtonAction:(id)sender {
    if ([DoorDuClient switchCameraDirection]) {
        self.isFontCamera = !self.isFontCamera;
    }
}


#pragma mark -- DoorDuCallManagerDelegate
/**
 *  呼叫被取消(呼入/呼出)
 */
- (void)callDidTheCallIsCanceled
{
    [self dismissSelf];
}

/**
 * 呼叫失败或错误（呼入/呼出）
 */
- (void)callDidCallFailedOrWrong
{
    [self dismissSelf];
}

/**
 * 呼叫被拒接
 */
- (void)callDidTheCallWasRejected
{
    //停止播放音效
    [[DoorDuAudioPlayer sharedInstance] stopPlayAudioAndVibrate];
    //播放门禁主机正忙
    [[DoorDuAudioPlayer sharedInstance] playDoorisBusyAudio:NO];
}

/**
 * 呼叫结束（呼入/呼出）
 */
- (void)callDidTheCallEnds
{
    [self dismissSelf];
}

/**
 * 呼叫接通（呼入/呼出）
 * @param   supportVideo    呼叫是否支持视频.
 * @param   supportData     呼叫是否支持数据.
 */
- (void)callDidTheCallIsConnectedSupportVideo:(BOOL)supportVideo
                                  supportData:(BOOL)supportData
{
    //停止播放音效
    [[DoorDuAudioPlayer sharedInstance] stopPlayAudioAndVibrate];
    
    //关闭呼叫超时监听
    if (_callTimeOutTimer) {
        
        [_callTimeOutTimer invalidate];
        _callTimeOutTimer = nil;
    }
    
    //开启自动接听
    self.isStartAutoAccept = YES;
    self.tipsLabel.text = @"正在连接中...";
    
    self.audioMode_micButton.enabled = NO;
    self.audioMode_speakerButton.enabled = NO;
    self.videoMode_switchAudioButton.enabled = NO;
    self.videoMode_switchCameraButton.enabled = NO;
    
    //获取来电类型
    if (self.mediaCallType == kDoorDuMediaCallTypeUnknown) {
        
        //布局设置
        self.videoPreview.hidden = YES;
        self.tips_layoutView.hidden = NO;
        self.acceptMode_layoutView.hidden = YES;
        self.audioMode_layoutView.hidden = NO;
        self.videoMode_layoutView.hidden = YES;
        
        //开启计时
        [self startTimer];
        
        //提示语
        if (!self.isEnableSpeaker) {
            self.tipsLabel.text = @"请使用听筒接听";
        }else {
            self.tipsLabel.text = @"";
        }
    }else {
        //布局设置
        self.videoPreview.hidden = NO;
        self.tips_layoutView.hidden = YES;
        self.acceptMode_layoutView.hidden = YES;
        self.audioMode_layoutView.hidden = YES;
        self.videoMode_layoutView.hidden = NO;
        
        //开启计时
        [self startTimer];
    }
    
//    //接听来电
//    DoorDuMediaCallType callType = (self.callType == 1) ? kDoorDuMediaCallTypeVideo : kDoorDuMediaCallTypeAudio;
//    DoorDuCallCameraOrientation cameralOrientation = (self.isFontCamera ? kDoorDuCallCameraOrientationFront : kDoorDuCallCameraOrientationBack);
//    
//    [DoorDuClient answerCallWithCallType:kDoorDuCallEachFamilyAccess mediaCallType:callType localMicrophoneEnable:self.isEnableMic localSpeakerEnable:self.isEnableSpeaker localCameraOrientation:cameralOrientation remoteCallerID:nil localVideoView:self.videoView remoteVideoView:self.videoPreview];
}

/**
 * 远程视频画面尺寸改变
 * @param   width    宽度.
 * @param   height   高度.
 */
- (void)callDidRemoteVideoScreenSizeChangeWidth:(NSInteger)width
                                         height:(NSInteger)height
{
    
}

/**
 *  收到远程终端由视频模式切换到语音模式
 */
- (void)callDidReceiveRemoteSwitchVideoModeToAudioMode
{
    [self switchAudioButtonAction:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
