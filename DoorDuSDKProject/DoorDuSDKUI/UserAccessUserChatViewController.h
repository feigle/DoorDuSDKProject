//
//  UserAccessUserChatViewController.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/19.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "BaseViewController.h"
#import "DoorDuClient.h"

@interface UserAccessUserChatViewController : BaseViewController

@property (assign, nonatomic, readwrite) DoorDuMediaCallType type;
@property (copy, nonatomic, readwrite) NSString *fromRoomID;
@property (copy, nonatomic, readwrite) NSString *fromRoomName;
@property (copy, nonatomic, readwrite) NSString *toRoomNO;
@property (copy, nonatomic, readwrite) NSString *toRoomID;

@property (assign, nonatomic, readwrite) BOOL isStartAutoAccept;

@end
