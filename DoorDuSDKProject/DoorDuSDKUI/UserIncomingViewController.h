//
//  UserIncomingViewController.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/19.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "BaseViewController.h"

@interface UserIncomingViewController : BaseViewController

@property (copy, nonatomic, readwrite) NSString *transactionID;
@property (assign, nonatomic, readwrite) int callType;//呼叫类型，0语音呼叫，1视频呼叫
@property (copy, nonatomic, readwrite) NSString *fromRoomID;
@property (copy, nonatomic, readwrite) NSString *fromRoomName;
@property (copy, nonatomic, readwrite) NSString *fromSipNO;
@property (copy, nonatomic, readwrite) NSString *toRoomID;

@property (assign, nonatomic, readwrite) BOOL isStartAutoAccept;

@end