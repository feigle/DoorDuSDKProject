//
//  DoorDuAllRequestParam.h
//  NetTest
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuBaseRequestParam.h"

#pragma mark --包含token的所有param
@interface DoorDuRootParam : DoorDuBaseRequestParam
/**
 *  用户令牌
 */
@property (nonatomic,copy) NSString *token;
@end

#pragma mark --获取token
@interface DoorDuTokenParam : DoorDuBaseRequestParam
/**
 *  申请的app_id
 */
@property (nonatomic,copy) NSString *app_id;
/**
 *  申请的secret_key
 */
@property (nonatomic,copy) NSString *secret_key;
@end

@interface DoorDuPushParam : DoorDuBaseRequestParam
/**
 绑定 or 解绑
 */
@property (nonatomic,assign) BOOL isBinding;
/**
 SDK授权令牌
 */
@property (nonatomic,copy) NSString *token;

/**
 用户id
 */
@property (nonatomic,copy) NSString *user_id;

/**
 推送token
 */
@property (nonatomic,copy) NSString *device_token;

/**
 设备唯一标识符
 */
@property (nonatomic,copy) NSString *device_guid;

@end


#pragma mark --获取token
@interface DoorDuCallCallParam : DoorDuBaseRequestParam
//caller_device_id=366754&cmd=doorIncoming&room_id=349083&caller_type=1
/**
 *  申请的app_id
 */
@property (nonatomic,copy) NSString *caller_device_id;
/**
 *  申请的secret_key
 */
@property (nonatomic,copy) NSString *cmd;
@property (nonatomic,copy) NSString *room_id;
@property (nonatomic,copy) NSString *caller_type;
@end


#pragma mark --获取用户信息
@interface DoorDuUserInfoParam : DoorDuBaseRequestParam
/**
 *  用户令牌
 */
@property (nonatomic,copy) NSString *token;
/**
 *  国家码：中国 86
 */
@property (nonatomic,copy) NSString *nation_code;
/**
 *  手机号码
 */
@property (nonatomic,copy) NSString *mobile_no;
/**
 *  设备识别
 */
@property (nonatomic,copy) NSString *device_guid;
/**
 *  设备类型 2-安卓 3-IOS
 */
@property (nonatomic,copy) NSString *device_type;
@end

#pragma mark --获取小区列表
@interface DoorDuDepartmentParam : DoorDuRootParam

@end

#pragma mark --获取栋列表
@interface DoorDuBuildingParam : DoorDuRootParam
/**
 *  小区id
 */
@property (nonatomic,copy) NSNumber *department_id;
@end

#pragma mark --获取所有单元列表
@interface DoorDuUnitParam : DoorDuRootParam
/**
 *  小区id
 */
@property (nonatomic,copy) NSNumber *building_id;
@end

#pragma mark --获取某单元下的所有房间
@interface DoorDuRoomParam : DoorDuRootParam
/**
 *  小区id
 */
@property (nonatomic,copy) NSNumber *unit_id;
@end

#pragma mark --获取用户房间信息
@interface DoorDuUserRoomsParam : DoorDuRootParam
/**
 *  用户id
 */
@property (nonatomic,copy) NSString *user_id;
/**
 *  用户设备标识
 */
@property (nonatomic,copy) NSString *device_guid;
/**
 *  设备类型 2-安卓 3-IOS
 */
@property (nonatomic,copy) NSString *device_type;
@end

#pragma mark --设置一键免打扰
@interface DoorDuDisturbParam : DoorDuRootParam
/**
 *  用户id
 */
@property (nonatomic,copy) NSString *user_id;
/**
 *  设备标识
 */
@property (nonatomic,copy) NSString *device_guid;
/**
 *  呼叫免打扰 0--off  1--on
 */
@property (nonatomic,copy) NSNumber *call_status;
/**
 *  呼叫转接免打扰 0--off  1--on
 */
@property (nonatomic,copy) NSNumber *forwarding_status;
@end

#pragma mark --设置房间免打扰
@interface DoorDuRoomDisturbParam : DoorDuRootParam
/**
 *  用户id
 */
@property (nonatomic,copy) NSString *user_id;
/**
 *  设备标识
 */
@property (nonatomic,copy) NSString *device_guid;
/**
 *  房间号
 */
@property (nonatomic,copy) NSString *room_id;
/**
 *  呼叫免打扰 0--off  1--on 2--只在夜间开启
 */
@property (nonatomic,copy) NSNumber *call_status;
/**
 *  呼叫转接免打扰 0--off  1--on 2--只在夜间开启
 */
@property (nonatomic,copy) NSNumber *forwarding_status;
@end

#pragma mark --呼叫
@interface DoorDuCallParam : DoorDuRootParam
/**
 *  用户id
 */
@property (nonatomic,copy) NSString *user_id;
/**
 *  设备标识
 */
@property (nonatomic,copy) NSString *device_guid;
/**
 *  主叫方房间ID
 */
@property (nonatomic,copy) NSString *from_room_id;
/**
 *  被叫方房间ID
 */
@property (nonatomic,copy) NSString *to_room_id;
/**
 *  被叫方房间房号（to_room_id和to_room_no两者必传一个）
 */
@property (nonatomic,copy) NSString *to_room_no;
/**
 *  0--语音呼叫， 1--视频呼叫
 */
@property (nonatomic,copy) NSString *call_type;
@end

#pragma mark --开门
@interface DoorDuOpenDoorParam : DoorDuRootParam
/**
 *  用户id
 */
@property (nonatomic,copy) NSString *user_id;
/**
 *  设备标识
 */
@property (nonatomic,copy) NSString *device_guid;
/**
 *  门禁设备id
 */
@property (nonatomic,copy) NSString *door_id;
/**
 *  房间ID
 */
@property (nonatomic,copy) NSString *room_id;
/**
 *  开门方式： 2 app开门， 6 视频开门
 */
@property (nonatomic,copy) NSString *operate_type;
@end

#pragma mark --申请开门密码
@interface DoorDuApplyPwdParam : DoorDuRootParam
/**
 *  用户id
 */
@property (nonatomic,copy) NSString *user_id;
/**
 *  设备标识
 */
@property (nonatomic,copy) NSString *device_guid;
/**
 *  房间ID
 */
@property (nonatomic,copy) NSString *room_id;
@end

#pragma mark --开门记录列表
@interface DoorDuOperateRecordParam : DoorDuRootParam
/**
 *  用户id
 */
@property (nonatomic,copy) NSString *user_id;
/**
 *  房间ID
 */
@property (nonatomic,copy) NSString *room_id;
/**
 *  起始页，以1开始页
 */
@property (nonatomic,copy) NSNumber *start_page;
/**
 *  一页显示数量
 */
@property (nonatomic,copy) NSNumber *page_no;
/**
 *  开门类型  0-所有记录  1-IC卡开门  2-APP开门 3-呼叫开门 4-密码开门 5-未接通
 */
@property (nonatomic,copy) NSNumber *open_type;
@end

// 来电快照图片获取
@interface DoorDuCallPhoto : DoorDuRootParam

@property (nonatomic,copy) NSString *user_id;
/**
 *  来电sip账号
 */
@property (nonatomic,copy) NSString *fromSipNo;

@end





