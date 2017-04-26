//
//  UserInfoManager.h
//  DoorDuSDKProject
//
//  Created by feigle on 2017/4/26.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuAllResponse.h"

@interface UserInfoManager : NSObject
{
    DoorDuUserInfo *userInfo;
    DoorDuDoorInfo *doorInfo;
    DoorDuUserRoom *room;
}

@property (nonatomic,strong) DoorDuUserInfo *userInfo;
@property (nonatomic,strong) DoorDuDoorInfo *doorInfo;
@property (nonatomic,strong) DoorDuUserRoom *roomInfo;

+ (instancetype)shareInstance;

@end
