//
//  DoorIncomingViewController.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/17.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "BaseViewController.h"

@interface DoorIncomingViewController : BaseViewController

@property (copy, nonatomic, readwrite) NSString *transactionID;
@property (assign, nonatomic, readwrite) int callType;//呼叫类型，0语音呼叫，1视频呼叫
@property (copy, nonatomic, readwrite) NSString *doorName;
@property (copy, nonatomic, readwrite) NSString *doorSipNO;
@property (copy, nonatomic, readwrite) NSString *doorGuid;
@property (copy, nonatomic, readwrite) NSString *doorID;
@property (copy, nonatomic, readwrite) NSString *appRoomID;

@property (assign, nonatomic, readwrite) BOOL isStartAutoAccept;

@end
