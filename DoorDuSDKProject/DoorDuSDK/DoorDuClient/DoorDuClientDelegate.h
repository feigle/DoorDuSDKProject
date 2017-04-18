//
//  DoorDuClientDelegate.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/30.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DoorDuEachFamilyAccessCallModel;
@class DoorDuDoorCallModel;

@protocol DoorDuClientDelegate <NSObject>

/**接收到户户通来电*/
- (void)callDidReceiveEachFamilyAccess:(DoorDuEachFamilyAccessCallModel *)model;
/**接收到门禁呼叫来电*/
- (void)callDidReceiveDoor:(DoorDuDoorCallModel *)model;
/**
 * 以下情况会接收到挂断通知：
 * 1.主叫方挂断了电话（取消电话呼叫）
 * 2.户户通和门禁打过来的时候同房间的人比你先接听
 * 3.呼叫超时
 */
- (void)callDidHangupMessage;

@end
