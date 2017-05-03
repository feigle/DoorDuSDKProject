//
//  DoorDuMainViewController.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/14.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuMainViewController.h"
#import "DoorVideoChatViewController.h"
#import "DoorIncomingViewController.h"
#import "UserAccessUserViewController.h"
#import "UserIncomingViewController.h"
#import "DoorDuDataManager.h"
#import "YYModel.h"

#import "DoorDuClient.h"
#import "DoorDuDoorCallModel.h"

#import "UserInfoManager.h"

#import "DoorDuEachFamilyAccessCallModel.h"

@interface DoorDuMainViewController ()<DoorDuClientDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DoorDuMainViewController
{
    NSString *tokenStr;
    DoorDuUserInfo *_userInfo;
    DoorDuDoorInfo *doorInfo;
    DoorDuUserRoom *room;
    
    UIViewController *topViewContoller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [DoorDuClient registClientDelegate:self];
}

#pragma mark -- 初始化DoorDuSDK
- (void)initDoorDuSDK
{
    DoorDuOptions *options = [DoorDuOptions optionsWithToken:tokenStr];
    options.isShowLog = YES;
    options.mode = DoorDuPreDistributeMode;
    
    // 默认开发环境， 并且输入日志
    [DoorDuClient configSDKOptions:options];

    // 启动DoorDuSDK
    [DoorDuClient initDoorDuSDKWithUserInfo:_userInfo];
}

/*
 APPID：e6mdd6w5mpux6gx1vslq61riowe0mgk1
 SECRETKEY：yrg35me6yjxd193mrpc2usp5eiz7yurc
 
 59ae3ec1070fd686c837cc6916057357
 bb58042b70d6c1b63e32ca293bad1c9f
*/
#pragma mark --获取推送令牌
- (IBAction)getSDKToken:(id)sender {
    
    WeakSelf
    [self show];
    [DoorDuDataManager getTokenWithAppId:@"e6mdd6w5mpux6gx1vslq61riowe0mgk1"
                               secretKey:@"yrg35me6yjxd193mrpc2usp5eiz7yurc"
                              completion:^(DoorDuToken *token, DoorDuError *error) {
                                  StrongSelf
                                  [strongSelf dismiss];
                                  if (token.token) {
                                    
                                      NSString *jsonStr = [token yy_modelToJSONString];
                                      [strongSelf setTextValue:[NSString stringWithFormat:@"token信息-> %@", jsonStr]];
                                      tokenStr = token.token;
                                  }else {
                                      NSLog(@"error message: %@", error.message);
                                  }
                              }];
}

#pragma mark --获取用户信息
- (IBAction)getUserInfo:(id)sender {
    
    WeakSelf
    [self show];//18588234262  13410010212
    [DoorDuDataManager getUserInfoWithMobileNo:@"18588234262"
                                    nationCode:@"86"
                                    deviceUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                    completion:^(DoorDuUserInfo *userInfo, DoorDuError *error) {
        
                                        StrongSelf
                                        [strongSelf dismiss];
                                        if (userInfo) {
                                            _userInfo = userInfo;
                                            [UserInfoManager shareInstance].userInfo = userInfo;
                                            [strongSelf setTextValue:[NSString stringWithFormat:@"用户账号信息-> %@", [userInfo yy_modelToJSONString]]];
            
                                            //启动SDK
                                            [strongSelf initDoorDuSDK];
                                            
                                            //绑定通知
                                            NSString *deviceTokenStr = [DoorDuDataManager getDeviceTokenString];
                                            [DoorDuDataManager bindingDeviceToken:deviceTokenStr
                                                                           userId:userInfo.userId
                                                                         sdkToken:tokenStr
                                                                       deviceUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                                                       completion:^(BOOL isSuccess, DoorDuError *error) {
                                                                           if (isSuccess) {
                                                                               NSLog(@"绑定推送成功");
                                                                           }else {
                                                                               NSLog(@"绑定推送失败");
                                                                           }
                
                                                                       }];
                                        }else {
                                            NSLog(@"error message: %@", error.message);
                                        }
                                    }];
}

- (IBAction)getRoomInfo:(id)sender {
    
    WeakSelf
    [self show];
    //10112
    [DoorDuDataManager getUserRoomListWithDeviceUUID:[[[UIDevice currentDevice] identifierForVendor] UUIDString] completion:^(NSArray *rooms, DoorDuError *error) {
        
        StrongSelf
        [strongSelf dismiss];
        if (rooms.count > 0) {
            room = [rooms firstObject];
            [UserInfoManager shareInstance].roomInfo = room;
            doorInfo = [room.doorList firstObject];
            [UserInfoManager shareInstance].doorInfo = doorInfo;
            NSString *string = [NSString stringWithFormat:@"房间信息-> name:%@ , room_id=%@, room_no=%@ door_list={door_id=%@, door_name=%@, door_guid=%@, door_sip_no=%@...}", room.name, room.roomId, room.roomNo, doorInfo.doorId, doorInfo.doorName, doorInfo.doorGuid, doorInfo.doorCallerNo];
            [strongSelf setTextValue:string];
        }
    }];
}


#pragma mark --门禁机呼叫
- (IBAction)doorCall:(id)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DoorVideoChatViewController *videoChatVC = [sb instantiateViewControllerWithIdentifier:@"DoorVideoChatID"];
    
    videoChatVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    videoChatVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    videoChatVC.roomID = room.roomId;
    videoChatVC.doorID = doorInfo.doorId;
    videoChatVC.doorGuid = doorInfo.doorGuid;
    videoChatVC.doorName = doorInfo.doorName;
    videoChatVC.doorCallerNo = doorInfo.doorCallerNo;
    
    [self presentViewController:videoChatVC animated:YES completion:nil];
    
    topViewContoller = videoChatVC;
}

#pragma mark --房间号呼叫
- (IBAction)roomCall:(id)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserAccessUserViewController *userAccessUserVC = [sb instantiateViewControllerWithIdentifier:@"UserAccessUserID"];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:userAccessUserVC animated:YES];
}


- (void)setTextValue:(NSString *)text
{
    NSString *string = _textView.text;
    string = [NSString stringWithFormat:@"%@ \n\n-----------------------\n%@", string, text];
    _textView.text = string;
}

#pragma mark -- DoorDuClientDelegate
/**接收到户户通来电*/
- (void)callDidReceiveEachFamilyAccess:(DoorDuEachFamilyAccessCallModel *)model;
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserIncomingViewController *userIncomingVC = [sb instantiateViewControllerWithIdentifier:@"UserIncomingID"];
    
    userIncomingVC.fromSipNO = model.appCallerNO;
    userIncomingVC.mediaCallType = model.mediaCallType;
    
    userIncomingVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    userIncomingVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:userIncomingVC animated:YES completion:nil];
    
    topViewContoller = userIncomingVC;
}

/**接收到门禁呼叫来电*/
- (void)callDidReceiveDoor:(DoorDuDoorCallModel *)model
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DoorIncomingViewController *doorIncomingVC = [sb instantiateViewControllerWithIdentifier:@"DoorIncomingID"];
    
    doorIncomingVC.doorName = model.doorName;
    doorIncomingVC.doorSipNO = model.doorCallerNO;
    doorIncomingVC.doorGuid = model.doorGuid;
    doorIncomingVC.doorID = model.doorID;
    doorIncomingVC.appRoomID = model.appRoomID;
    doorIncomingVC.callType = model.callType;
    doorIncomingVC.isStartAutoAccept = NO;
    
    doorIncomingVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    doorIncomingVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:doorIncomingVC animated:YES completion:nil];
    
    topViewContoller = doorIncomingVC;
}

/**
 * 以下情况会接收到挂断通知：
 * 1.主叫方挂断了电话（取消电话呼叫）
 * 2.户户通和门禁打过来的时候同房间的人比你先接听
 * 3.呼叫超时
 */
- (void)callDidHangupMessage
{
    [topViewContoller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
