//
//  DoorVideoChatViewController.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/14.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorVideoChatViewController.h"
#import "DoorDuVideoView.h"

#import <AddressBook/AddressBook.h>
#import <AVFoundation/AVFoundation.h>

#import "DoorDuAudioPlayer.h"
#import "DoorDuClient.h"
#import "DoorDuDataManager.h"

#import "AppHelp.h"

@interface DoorVideoChatViewController ()<DoorDuCallManagerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic, readwrite)      IBOutlet UILabel *doorNameLabel;
@property (weak, nonatomic, readwrite)      IBOutlet DoorDuVideoView *videoView;
@property (weak, nonatomic, readwrite)      IBOutlet UIView *tips_layoutView;
@property (weak, nonatomic, readwrite)      IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic, readwrite)      IBOutlet UIButton *turnOffButton;
@property (weak, nonatomic, readwrite)      IBOutlet UIButton *switchButton;
@property (weak, nonatomic, readwrite)      IBOutlet UIButton *openDoorButton;
@property (weak, nonatomic, readwrite)      IBOutlet UILabel *turnOffLabel;
@property (weak, nonatomic, readwrite)      IBOutlet UILabel *switchLabel;
@property (weak, nonatomic, readwrite)      IBOutlet UILabel *openDoorLabel;
@property (assign, nonatomic, readwrite)    IBOutlet UILabel *timeLabel;

@property (weak, nonatomic, readwrite)      IBOutlet NSLayoutConstraint *videoViewHeightConstraint;
@property (weak, nonatomic, readwrite)      IBOutlet NSLayoutConstraint *turnOff_layoutView_Constraint;

@property (assign, nonatomic, readwrite)    BOOL isEnableMic;
@property (assign, nonatomic, readwrite)    BOOL isEnableSpeaker;
@property (assign, nonatomic, readwrite)    BOOL isFirstConnect;

@end

@implementation DoorVideoChatViewController
{
    NSTimer *timer; // 通话时间定时器
    NSUInteger min; // 通话分钟
    NSUInteger sec; // 通话秒数
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUIContent];
    
    [DoorDuClient registCallManagerDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.doorCallerNo || [self.doorCallerNo isEqualToString:@""]) {
        return;
    }
    
    self.isEnableMic = NO;
    self.isEnableSpeaker = YES;
    self.isFirstConnect = YES;
    min = 0;
    sec = 0;
    
    if ([AppHelp checkMediaAndAudioAuthStateWithParentViewController:self]) {
        // 呼叫门禁机
        [DoorDuClient makeCallWithCallType:kDoorDuCallDoor
                             mediaCallType:kDoorDuMediaCallTypeVideo
                     localMicrophoneEnable:YES
                        localSpeakerEnable:YES
                    localCameraOrientation:kDoorDuCallCameraOrientationFront
                            remoteCallerID:self.doorCallerNo
                            localVideoView:nil
                           remoteVideoView:self.videoView
                                fromRoomID:nil
                                  toRoomNo:self.roomID];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //播放呼叫声音
    [[DoorDuAudioPlayer sharedInstance] playOutgoingAudio:YES];
}

- (void)dealloc {
    
    [[DoorDuAudioPlayer sharedInstance] stopPlayAudioAndVibrate];
}


- (void)initUIContent
{
    self.doorNameLabel.text = self.doorName;
    
    self.timeLabel.hidden = YES;
    self.timeLabel.text = @"00:00";
    
    self.tips_layoutView.hidden = NO;
    self.tipsLabel.text = @"正在启动...";
    
    self.isFirstConnect = YES;
    self.turnOffLabel.text = @"挂断";
    self.switchLabel.text = @"切换";
    self.openDoorLabel.text = @"开门";
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

- (void)dismissSelf
{
    [DoorDuClient hangupCurrentCall];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -- 挂断电话
- (IBAction)hangupAction:(id)sender {
    
    [DoorDuClient hangupCurrentCall];
    [self dismissSelf];
}

#pragma mark -- 开门
- (IBAction)openDoorAction:(id)sender {
    
    WeakSelf
    [self showWithTitle:@"正在为您开门,请稍等"];
    [DoorDuDataManager openDoorServiceWithDoorId:self.doorID
                                          roomId:self.roomID
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

#pragma mark -- 切换音视频模式
- (IBAction)switchMedieModel:(id)sender {
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
    
    [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:5.0];
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
    
    //提示控件
    if (self.isFirstConnect) {
        self.isFirstConnect = NO;
        self.tips_layoutView.hidden = YES;
        
        [self.view setNeedsLayout];
        self.turnOff_layoutView_Constraint.constant = self.view.frame.size.width * 2 / 3;
        [UIView animateWithDuration:0.5f animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            //开启计时
            self.timeLabel.hidden = NO;
            [self startTimer];
        }];
        //调整控件布局
        [self.view layoutIfNeeded];
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

@end
