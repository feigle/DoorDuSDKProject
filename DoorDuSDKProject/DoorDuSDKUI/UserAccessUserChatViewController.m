//
//  UserAccessUserChatViewController.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/19.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "UserAccessUserChatViewController.h"

#import "DoorDuClient.h"
#import "DoorDuAudioPlayer.h"
#import "DoorDuVideoView.h"
#import "AppHelp.h"

#import "UserInfoManager.h"

@interface UserAccessUserChatViewController ()<DoorDuCallManagerDelegate>
{
    NSTimer *timer;
    NSTimer *callTimeOutTimer;
    int min;
    int sec;
}

@property (weak, nonatomic, readwrite) IBOutlet DoorDuVideoView *videoView;//终端上显示门禁机来电视频控件
@property (weak, nonatomic, readwrite) IBOutlet DoorDuVideoView *videoPreview;//终端上显示用户视频控件

@property (weak, nonatomic, readwrite) IBOutlet NSLayoutConstraint *videoViewWidthConstraint;

@property (weak, nonatomic, readwrite) IBOutlet UIView *tips_layoutView;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic, readwrite) IBOutlet UIImageView *tipsHeadImageView;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *doorNameLabel;

@property (weak, nonatomic, readwrite) IBOutlet UIView *acceptMode_layoutView;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *acceptMode_turnOffButton;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *acceptMode_turnOffLabel;

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

@property (weak, nonatomic, readwrite) IBOutlet UILabel *timeLabel;

@property (assign, nonatomic, readwrite) BOOL isEnableMic;//话筒是否开启
@property (assign, nonatomic, readwrite) BOOL isEnableSpeaker;//扬声器是否开启
@property (assign, nonatomic, readwrite) BOOL isFontCamera;//是否前摄像头
@property (assign, nonatomic, readwrite) BOOL isVideoMode;//是否视频通话模式
@property (assign, nonatomic, readwrite) BOOL isHangUp;//是否本地挂断

@end

@implementation UserAccessUserChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isStartAutoAccept = NO;
    
    [self initUI];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //播放呼出语音
    [[DoorDuAudioPlayer sharedInstance] playOutgoingAudio:YES];
    
    [DoorDuClient registCallManagerDelegate:self];
}


- (void)initUI
{
    //时间
    self.timeLabel.hidden = YES;
    self.timeLabel.text = @"00:00";
    min = 0;
    sec = 0;
    
    //提示控件
    self.videoPreview.hidden = YES;
    self.tips_layoutView.hidden = NO;
    self.tipsLabel.text = @"正在等待对方接受邀请...";
    if (self.toRoomNO && ![self.toRoomNO isEqualToString:@""]) {
        self.doorNameLabel.text = self.toRoomNO;
    }else {
        self.doorNameLabel.text = @"...";
    }
    
    //语音或者视频呼叫
    self.videoPreview.backgroundColor = [UIColor clearColor];
    self.acceptMode_layoutView.hidden = NO;
    self.isHangUp = NO;
    if (self.type == kDoorDuMediaCallTypeAudio) {
        //语音
        self.audioMode_layoutView.hidden = NO;
        self.videoMode_layoutView.hidden = YES;
        
        //语音模式默认开启麦克风和开启话筒
        self.isEnableMic = YES;
        self.isEnableSpeaker = YES;
        self.isVideoMode = NO;
    }else if(self.type == kDoorDuMediaCallTypeVideo){
        
        //视频
        self.audioMode_layoutView.hidden = YES;
        self.videoMode_layoutView.hidden = NO;
        
        //视频模式默认开启麦克风和话筒
        self.isEnableMic = YES;
        self.isEnableSpeaker = YES;
        self.isVideoMode = YES;
    }
    
    //摄像头默认前摄像头
    self.isFontCamera = YES;
    
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

    if ([AppHelp checkMediaAndAudioAuthStateWithParentViewController:self]) {
        //开启请求超时监听
        if (callTimeOutTimer) {
            
            [callTimeOutTimer invalidate];
            callTimeOutTimer = nil;
        }
        
        callTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:40
                                                             target:self
                                                           selector:@selector(callAutoEnd)
                                                           userInfo:nil
                                                            repeats:NO];
        
        
        DoorDuCallCameraOrientation cameralOrientation = (self.isFontCamera ? kDoorDuCallCameraOrientationFront : kDoorDuCallCameraOrientationBack);
        
        [DoorDuClient makeCallWithCallType:kDoorDuCallEachFamilyAccess mediaCallType:_type localMicrophoneEnable:self.isEnableMic localSpeakerEnable:self.isEnableSpeaker localCameraOrientation:cameralOrientation remoteCallerID:nil localVideoView:self.videoPreview remoteVideoView:self.videoView fromRoomID:[UserInfoManager shareInstance].roomInfo.roomId toRoomNo:self.toRoomNO];
    }
}

- (void)callAutoEnd {
    
    if (!self.isStartAutoAccept) {
        
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        
        if (callTimeOutTimer) {
            [callTimeOutTimer invalidate];
            callTimeOutTimer = nil;
        }
        
        //停止播放音效
        [[DoorDuAudioPlayer sharedInstance] stopPlayAudioAndVibrate];
        
        //播放正忙
        [[DoorDuAudioPlayer sharedInstance] playBusyAudio:NO];
        
        //返回上级场景
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dismissSelf
{
    if (timer) {
        if (timer.isValid) {
            [timer invalidate];
        }
        timer = nil;
    }
    if (callTimeOutTimer.isValid) {
        [callTimeOutTimer invalidate];
    }
    //停止播放音效
    [[DoorDuAudioPlayer sharedInstance] stopPlayAudioAndVibrate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.isVideoMode = NO;
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
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1.f
                                              target:self
                                            selector:@selector(timerFunction)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)timerFunction {
    
    sec = sec + 1;
    if (sec == 60) {
        
        sec = 0;
        min = min + 1;
    }
    NSString *min1 = @"";
    if (min < 10) {
        min1 = [NSString stringWithFormat:@"0%d", min];
    }else {
        min1 = [NSString stringWithFormat:@"%d", min];
    }
    
    NSString *sec1 = @"";
    if (sec < 10) {
        sec1 = [NSString stringWithFormat:@"0%d", sec];
    }else {
        sec1 = [NSString stringWithFormat:@"%d", sec];
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
    [self showErrWithTitle:@"呼叫取消"];
    [self dismissSelf];
}

/**
 * 呼叫失败或错误（呼入/呼出）
 */
- (void)callDidCallFailedOrWrong
{
    [self showErrWithTitle:@"号码拨叫出错"];
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
    if (callTimeOutTimer) {
        
        [callTimeOutTimer invalidate];
        callTimeOutTimer = nil;
    }
    
    //开启自动接听
    self.isStartAutoAccept = YES;
    self.tipsLabel.text = @"正在连接中...";
    
    self.audioMode_micButton.enabled = NO;
    self.audioMode_speakerButton.enabled = NO;
    self.videoMode_switchAudioButton.enabled = NO;
    self.videoMode_switchCameraButton.enabled = NO;
    
    //获取来电类型
    if (!self.isVideoMode) {
        
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
        
    //接听来电
    DoorDuMediaCallType callType = self.isVideoMode ? kDoorDuMediaCallTypeVideo : kDoorDuMediaCallTypeAudio;
    DoorDuCallCameraOrientation cameralOrientation = (self.isFontCamera ? kDoorDuCallCameraOrientationFront : kDoorDuCallCameraOrientationBack);
    
    [DoorDuClient answerCallWithCallType:kDoorDuCallEachFamilyAccess mediaCallType:callType localMicrophoneEnable:self.isEnableMic localSpeakerEnable:self.isEnableSpeaker localCameraOrientation:cameralOrientation remoteCallerID:nil localVideoView:self.videoView remoteVideoView:self.videoPreview];
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
