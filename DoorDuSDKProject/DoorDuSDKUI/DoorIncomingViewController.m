//
//  DoorIncomingViewController.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/17.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorIncomingViewController.h"
#import "DoorDuVideoView.h"

#import <AddressBook/AddressBook.h>
#import <AVFoundation/AVFoundation.h>

#import "DoorDuAudioPlayer.h"
#import "DoorDuClient.h"
#import "DoorDuDataManager.h"

#import "UIImage+scale.h"
#import "AppHelp.h"

@interface DoorIncomingViewController ()<DoorDuCallManagerDelegate, UIActionSheetDelegate>
{
    NSTimer *timer;
    NSTimer *callTimeOutTimer;
    int min;
    int sec;
}

@property (weak, nonatomic, readwrite) IBOutlet UILabel         *doorNameLabel;
@property (weak, nonatomic)            IBOutlet UIImageView     *snapshotImageView;
@property (weak, nonatomic, readwrite) IBOutlet UILabel         *snapshotTipsLabel;

@property (weak, nonatomic, readwrite) IBOutlet UIView   *accept_layoutView;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *accept_turnOffButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *accept_acceptButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *accept_openDoorButton;
@property (weak, nonatomic, readwrite) IBOutlet UILabel  *accept_turnOffLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel  *accept_acceptLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel  *accept_openDoorLabel;

@property (weak, nonatomic, readwrite) IBOutlet DoorDuVideoView     *videoView;
@property (weak, nonatomic, readwrite) IBOutlet UILabel             *callStateLabel;
@property (weak, nonatomic, readwrite) IBOutlet UIButton            *turnOffButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton            *switchButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton            *openDoorButton;
@property (weak, nonatomic, readwrite) IBOutlet UILabel             *turnOffLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel             *switchLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel             *openDoorLabel;
@property (assign, nonatomic, readwrite) IBOutlet UILabel           *timeLabel;

@property (weak, nonatomic, readwrite) IBOutlet NSLayoutConstraint  *turnOff_layoutView_Constraint;
@property (weak, nonatomic, readwrite) IBOutlet NSLayoutConstraint  *videoViewHeightConstraint;

@property (assign, nonatomic, readwrite) BOOL isVideoMode;
@property (assign, nonatomic, readwrite) BOOL isEnableMic;
@property (assign, nonatomic, readwrite) BOOL isEnableSpeaker;
@property (assign, nonatomic, readwrite) BOOL isFirstConnect;

@property (assign, nonatomic, readwrite) BOOL onCallConnected;//呼叫是否已连接
@property (assign, nonatomic, readwrite) BOOL isHangUp;//是否本地挂断

@end

@implementation DoorIncomingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    min = 0;
    sec = 0;
    
    self.onCallConnected = NO;
    self.isHangUp = NO;

    // 初始化UI
    [self initUIContent];
    
    [DoorDuClient registCallManagerDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //播放来电语音
    [[DoorDuAudioPlayer sharedInstance] playIncomingAudio:YES];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //开启请求超时监听
    if (callTimeOutTimer) {
        
        if ([callTimeOutTimer isValid]) {
            [callTimeOutTimer invalidate];
        }
        callTimeOutTimer = nil;
    }
    
    callTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:40
                                                         target:self
                                                       selector:@selector(callAutoEnd)
                                                       userInfo:nil
                                                        repeats:NO];
    
    // 获取门禁截图
    [DoorDuDataManager getCallerPhotoWithDoorSipNo:self.doorSipNO completion:^(id image, DoorDuError *error) {
        if (image) {
            if ([image isKindOfClass:[UIImage class]]) {
                self.snapshotImageView.image = [UIImage scaleImageToScale:2.0 image:image];
            }
            self.snapshotTipsLabel.text = @"此画面为实时抓取截图";
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.doorName = nil;
    self.doorSipNO = nil;
    self.doorGuid = nil;
    self.doorID = nil;
    self.appRoomID = nil;
    
    if (timer) {
        
        if (timer.isValid) {
            [timer invalidate];
        }
        timer = nil;
    }
    
    if (callTimeOutTimer) {
        if (callTimeOutTimer.isValid) {
            [callTimeOutTimer invalidate];
        }
        callTimeOutTimer = nil;
    }
    
    //停止播放音效
    [[DoorDuAudioPlayer sharedInstance] stopPlayAudioAndVibrate];
    
}


- (void)initUIContent
{
    //门禁主机名称
    self.doorNameLabel.text = self.doorName;
    self.snapshotTipsLabel.text = @"正在获取访客头像...";
    
    self.snapshotImageView.hidden = NO;
    self.snapshotTipsLabel.hidden = NO;
    
    //非视频
    self.accept_turnOffLabel.text = @"拒绝";
    self.accept_openDoorLabel.text = @"开门";
    self.accept_acceptLabel.text = @"接听";
    
    self.accept_layoutView.hidden = NO;
    
    //视频
    self.callStateLabel.text = @"正在接通...";
    self.turnOffLabel.text = @"挂断";
    self.switchLabel.text = @"切换";
    self.openDoorLabel.text = @"开门";
    self.videoView.hidden = YES;
    
    //时间
    self.isFirstConnect = YES;
    self.timeLabel.hidden = YES;
    self.timeLabel.text = @"00:00";
}

- (void)callAutoEnd {
    
    if (!self.isStartAutoAccept) {
        //返回上级场景
        [self dismissSelf];
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


#pragma mark -- 拒接电话
- (IBAction)rejectCalling:(id)sender {
    
    self.isHangUp = YES;
    
    [DoorDuClient rejectCurrentCall];
    [self dismissSelf];
}

#pragma mark -- 挂断电话
- (IBAction)hangupCalling:(id)sender {
    
    self.isHangUp = YES;
    
    [DoorDuClient hangupCurrentCall];
    [self dismissSelf];
}

#pragma mark -- 开门
- (IBAction)openDoor:(id)sender {
    
    //开门按钮
    self.accept_openDoorButton.enabled = NO;
    self.openDoorButton.enabled = NO;
    
    WeakSelf
    [self showWithTitle:@"正在为您开门,请稍等"];
    [DoorDuDataManager openDoorServiceWithDoorId:self.doorID
                                          roomId:self.appRoomID
                                     operateType:@"2"
                                      deviceUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                      completion:^(BOOL isSuccess, DoorDuError *error) {
                                          StrongSelf
                                          [strongSelf dismiss];
                                          [strongSelf dismissSelf];
                                          if (isSuccess) {
                                              [strongSelf showSuccessWithTitle:@"开门成功"];
                                          }else {
                                              [strongSelf showSuccessWithTitle:@"开门失败"];
                                          }
                                          
                                      }];
}

#pragma mark -- 接听电话
- (IBAction)acceptCalling:(id)sender {
    
    self.isStartAutoAccept = YES;
    
    //播放呼出语音
    [[DoorDuAudioPlayer sharedInstance] playOutgoingAudio:YES];
    
    //隐藏接听控件
    self.accept_layoutView.hidden = YES;
    
    if ([AppHelp checkMediaAndAudioAuthStateWithParentViewController:self]) {
        
        self.accept_turnOffButton.enabled = NO;
        self.accept_openDoorButton.enabled = NO;
        self.accept_acceptButton.enabled = NO;
        
        // 呼叫门禁机
        [DoorDuClient makeCallWithCallType:kDoorDuCallDoor
                             mediaCallType:kDoorDuMediaCallTypeVideo
                     localMicrophoneEnable:self.isEnableMic
                        localSpeakerEnable:self.isEnableSpeaker
                    localCameraOrientation:kDoorDuCallCameraOrientationFront
                            remoteCallerID:self.doorSipNO
                            localVideoView:nil
                           remoteVideoView:self.videoView
                                fromRoomID:self.appRoomID
                                  toRoomNo:nil];
    }
}

#pragma mark -- 转换接听模式
- (IBAction)switchCallMode:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    
    if (self.isEnableMic) {
        [sheet addButtonWithTitle:@"开启静音"];
    }else {
        [sheet addButtonWithTitle:@"关闭静音"];
    }
    
    if (self.isEnableSpeaker) {
        [sheet addButtonWithTitle:@"关闭免提"];
    }else {
        [sheet addButtonWithTitle:@"开启免提"];
    }
    
    [sheet addButtonWithTitle:NSLocalizedString(@"取消", nil)];
    [sheet setCancelButtonIndex:2];
    [sheet setDelegate:self];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        if (self.isEnableMic) {
            self.isEnableMic = NO;
        }else {
            self.isEnableMic = YES;
        }
        [DoorDuClient switchMicrophone:self.isEnableMic];
    }else if (buttonIndex == 1) {
        if (self.isEnableSpeaker) {
            self.isEnableSpeaker = NO;
        }else {
            self.isEnableSpeaker = YES;
        }
        [DoorDuClient switchSpeaker:self.isEnableSpeaker];
        
    }
}

- (void)startTimer
{
    [self invalideTimer];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (void)invalideTimer
{
    [timer invalidate];
    timer = nil;
}

- (void)tick:(id)info
{
    ++sec;
    if (60 == sec) {
        sec = 0;
        ++min;
    }
    
    NSString *minStr = nil;
    NSString *secStr = nil;
    if (min < 10) {
        minStr = [NSString stringWithFormat:@"0%d", min];
    }else {
        minStr = [NSString stringWithFormat:@"%d", min];
    }
    if (sec < 10) {
        secStr = [NSString stringWithFormat:@"0%d", sec];
    }else {
        secStr = [NSString stringWithFormat:@"%d", sec];
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@", minStr, secStr];
}


#pragma mark -- DoorDuCallManagerDelegate

/**
 * 正在建立连接（呼叫）
 */
- (void)callDidCallConnectionIsBeingEstablished
{
}

/**
 *  呼叫被取消(呼入/呼出)
 */
- (void)callDidTheCallIsCanceled
{
    [self hangupCalling:nil];
}

/**
 * 呼叫失败或错误（呼入/呼出）
 */
- (void)callDidCallFailedOrWrong
{
    [self hangupCalling:nil];
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
    
    [self hangupCalling:nil];
    
    [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:5.0];
}

/**
 * 呼叫结束（呼入/呼出）
 */
- (void)callDidTheCallEnds
{
    [self hangupCalling:nil];
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
    
    //标记呼叫已建立
    self.onCallConnected = YES;
    //默认视频模式
    self.snapshotImageView.hidden = YES;
    self.snapshotTipsLabel.hidden = YES;
    self.videoView.hidden = NO;
    self.callStateLabel.hidden = YES;
    
    if (self.isFirstConnect) {
        self.isFirstConnect = NO;
        if (self.isVideoMode) {
            self.callStateLabel.text = @"视频通话模式";
        }else {
            self.callStateLabel.text = @"语音通话模式";
        }
        
        //调整控件布局
        [self.view setNeedsLayout];
        self.turnOff_layoutView_Constraint.constant = self.view.frame.size.width * 2 / 3;
        [UIView animateWithDuration:0.5f animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            //开启计时
            self.timeLabel.hidden = NO;
            [self startTimer];
        }];
        
        //开启计时
        self.timeLabel.hidden = NO;
    }

}

/**
 * 远程视频画面尺寸改变
 * @param   width    宽度.
 * @param   height   高度.
 */
- (void)callDidRemoteVideoScreenSizeChangeWidth:(NSInteger)width
                                         height:(NSInteger)height
{
    //根据实际视频尺寸修改当前视频控件尺寸
    WeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        StrongSelf
        strongSelf.videoViewHeightConstraint.constant = self.view.frame.size.width * height / width;
        [strongSelf.videoView setNeedsLayout];
    });
    
}

/**
 *  收到远程终端由视频模式切换到语音模式
 */
- (void)callDidReceiveRemoteSwitchVideoModeToAudioMode
{
    [DoorDuClient switchVideoModeToAudioMode];
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
