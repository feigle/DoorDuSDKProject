//
//  DoorVideoChatViewController.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/14.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//
//  呼叫门禁机

#import "BaseViewController.h"

@interface DoorVideoChatViewController : BaseViewController

/**
  主叫方房号ID
 */
@property (strong, nonatomic, readwrite) NSString *roomID;

/**
 门禁名称
 */
@property (strong, nonatomic, readwrite) NSString *doorName;

/**
 门禁通话账号
 */
@property (strong, nonatomic, readwrite) NSString *doorCallerNo;

/**
 门禁唯一识别码
 */
@property (strong, nonatomic, readwrite) NSString *doorGuid;

/**
 门禁ID
 */
@property (strong, nonatomic, readwrite) NSString *doorID;

@end
