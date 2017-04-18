//
//  DoorDuAllResponse.h
//  NetTest
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuBaseResponse.h"

#pragma mark -- 获取token
@interface DoorDuToken : DoorDuBaseResponse
/**
 *  注册SDK生成令牌
 */
@property (nonatomic,copy) NSString *token;
@end

#pragma mark -- 获取用户信息
@interface DoorDuUserInfo : DoorDuBaseResponse
/**
 *  用户ID
 */
@property (nonatomic,copy) NSString *userId;
/**
 *  昵称
 */
@property (nonatomic,copy) NSString *nickname;
/**
 *  生日
 */
@property (nonatomic,copy) NSString *birthday;
/**
 *  性别
 */
@property (nonatomic,copy) NSString *gender;
/**
 *  星座
 */
@property (nonatomic,copy) NSString *constellation;
/**
 *  头像地址
 */
@property (nonatomic,copy) NSString *avatar;
/**
 *  手机号
 */
@property (nonatomic,copy) NSString *mobileNo;
/**
 *  国家电话编码
 */
@property (nonatomic,copy) NSString *nationCode;
@property (nonatomic,copy) NSString *isDisturb;
@property (nonatomic,copy) NSString *isCalledDisturb;
/**
 *  需订阅的MQTT主题
 */
@property (nonatomic,copy) NSArray *topic;
/**
 *  caller账号
 */
@property (nonatomic,copy) NSString *callerNo;
/**
 *  caller密码
 */
@property (nonatomic,copy) NSString *callerPassword;
/**
 *  caller服务端IP
 */
@property (nonatomic,copy) NSString *callerDomain;
/**
 *  tls端口
 */
@property (nonatomic,copy) NSString *tlsPort;
/**
 *  tcp端口
 */
@property (nonatomic,copy) NSString *tcpPort;
/**
 *  udp端口
 */
@property (nonatomic,copy) NSString *udpPort;
/**
 *  ICE点对点通信
 */
@property (nonatomic,copy) NSNumber *ice;
/**
 *  ICE服务器域名
 */
@property (nonatomic,copy) NSString *coturnServer;
/**
 *  ICE服务器端口
 */
@property (nonatomic,copy) NSString *coturnPort;
/**
 *  ICE服务器用户名
 */
@property (nonatomic,copy) NSString *coturnUser;
/**
 *  ICE服务器密码
 */
@property (nonatomic,copy) NSString *coturnPass;
/**
 *  RTCP关键帧同步
 */
@property (nonatomic,copy) NSNumber *rtcpFb;
@end

#pragma mark -- 获取小区列表
@interface DoorDuDepartments : DoorDuBaseResponse
/**
 *  小区id
 */
@property (nonatomic,copy) NSNumber *departmentId;
/**
 *  小区名称
 */
@property (nonatomic,copy) NSString *departmentName;
//
@property (nonatomic,copy) NSString *xqlx;
@property (nonatomic,copy) NSString *szdq;
@property (nonatomic,copy) NSString *jwh;
@property (nonatomic,copy) NSString *xxdz;
@property (nonatomic,copy) NSString *xqjwd;
@property (nonatomic,copy) NSString *xqds;
@property (nonatomic,copy) NSString *xqhs;
@property (nonatomic,copy) NSString *glcfzr;
@property (nonatomic,copy) NSString *glcdh;
@property (nonatomic,copy) NSString *xqtp;
@property (nonatomic,copy) NSString *bz;
@end

#pragma mark -- 获取栋列表
@interface DoorDuBuilding : DoorDuBaseResponse
/**
 *  栋d
 */
@property (nonatomic,copy) NSNumber *buildingId;
/**
 *  栋名称
 */
@property (nonatomic,copy) NSString *buildingName;
/**
 *  小区id
 */
@property (nonatomic,copy) NSNumber *departmentId;
//
@property (nonatomic,copy) NSString *departmentName;
@property (nonatomic,copy) NSString *buildingNo;
@property (nonatomic,copy) NSNumber *floors;
@property (nonatomic,copy) NSNumber *unitsOfEachFloor;
@property (nonatomic,copy) NSString *buildingType;
@property (nonatomic,copy) NSNumber *devices;
@property (nonatomic,copy) NSString *pics;
@property (nonatomic,copy) NSString *sxjx;
@property (nonatomic,copy) NSString *fwjg;
@property (nonatomic,copy) NSString *fwglzt;
@property (nonatomic,copy) NSString *fdxm;
@property (nonatomic,copy) NSString *fdxb;
@property (nonatomic,copy) NSString *fdwhcd;
@property (nonatomic,copy) NSString *fdsfzh;
@property (nonatomic,copy) NSString *fdlx;
@property (nonatomic,copy) NSString *fdlxfs;
@property (nonatomic,copy) NSString *fdpoxm;
@property (nonatomic,copy) NSString *fdim;
@property (nonatomic,copy) NSString *fddz;
@property (nonatomic,copy) NSString *fdtp;
@property (nonatomic,copy) NSString *bz;
@end

#pragma mark -- 获取单元列表
@interface DoorDuUnit : DoorDuBaseResponse
/**
 *  栋d
 */
@property (nonatomic,copy) NSNumber *unitId;
/**
 *  栋名称
 */
@property (nonatomic,copy) NSString *unitName;
/**
 *  小区id
 */
@property (nonatomic,copy) NSNumber *buildingId;
@end

#pragma mark -- 房间
@interface DoorDuRoom : DoorDuBaseResponse
/**
 *  栋d
 */
@property (nonatomic,copy) NSNumber *roomId;
/**
 *  栋名称
 */
@property (nonatomic,copy) NSString *roomName;
/**
 *  小区id
 */
@property (nonatomic,copy) NSNumber *unitId;
//
@property (nonatomic,copy) NSString *position;
@property (nonatomic,copy) NSNumber *roomStatus;
@property (nonatomic,copy) NSNumber *peopleNumber;
@property (nonatomic,copy) NSNumber *rental;
@property (nonatomic,copy) NSNumber *purpose;
@property (nonatomic,copy) NSString *remark;
@end

#pragma mark -- 用户房间信息
@interface DoorDuUserRoom : DoorDuBaseResponse
/**
 *  房号完整名称
 */
@property (nonatomic,copy) NSString *name;
/**
 *  房间ID
 */
@property (nonatomic,copy) NSString *roomId;
/**
 *  房号
 */
@property (nonatomic,copy) NSString *roomNo;
//
@property (nonatomic,copy) NSString *unitNo;
@property (nonatomic,copy) NSString *buildingNo;
@property (nonatomic,copy) NSString *isOwner;
@property (nonatomic,copy) NSString *isDisturb;
@property (nonatomic,copy) NSString *isUploadCard;
@property (nonatomic,copy) NSString *applicationList;
@property (nonatomic,copy) NSString *transferMobile;
@property (nonatomic,copy) NSString *departmentName;
@property (nonatomic,copy) NSString *buildingUnitRoomName;
@property (nonatomic,copy) NSString *provinceName;
@property (nonatomic,copy) NSString *cityName;
@property (nonatomic,copy) NSString *districtName;
@property (nonatomic,copy) NSString *depId;
@property (nonatomic,copy) NSString *isCalledDisturb;
@property (nonatomic,copy) NSString *nationCode;
@property (nonatomic,copy) NSString *buildingId;
@property (nonatomic,copy) NSString *unitId;
@property (nonatomic,copy) NSString *authEndTime;
@property (nonatomic,copy) NSArray *doorList;
@end

// 门禁信息
@interface DoorDuDoorInfo : DoorDuBaseModel

@property (nonatomic,copy) NSString *doorId;
@property (nonatomic,copy) NSString *doorName;
@property (nonatomic,copy) NSString *doorAlias;
@property (nonatomic,copy) NSString *doorGuid;
@property (nonatomic,copy) NSString *doorCallerNo;
@property (nonatomic,copy) NSString *ssid;
@property (nonatomic,copy) NSString *ssidSecretkey;
@property (nonatomic,copy) NSString *ssidPwd;

@end

#pragma mark -- 呼叫响应
@interface DoorDuCall : DoorDuBaseResponse
/**
 *  过期时间
 */
@property (nonatomic,copy) NSString *expiredSeconds;
/**
 *  呼叫事物ID
 */
@property (nonatomic,copy) NSString *transactionId;
/**
 *  被呼叫的caller列表
 */
@property (nonatomic,copy) NSArray *callerList;
/**
 *  被呼叫房号的roomID
 */
#warning 服务端缺少这个参数，后期调试的时候需要加上，加上的时候把这里警告删了
@property (nonatomic,copy) NSString *toRoomId;

@end

#pragma mark -- 申请开门密码响应数据
@interface DoorDuApplyPwd : DoorDuBaseResponse
/**
 *  过期时间
 */
@property (nonatomic,copy) NSString *expiredTime;
/**
 *  呼叫事物ID
 */
@property (nonatomic,copy) NSString *password;
/**
 *  被呼叫的caller列表
 */
@property (nonatomic,copy) NSArray *list;
@end

@interface DoorDuDeviceStatus : DoorDuBaseModel

@property (nonatomic,copy) NSString *doorGuid;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,copy) NSString *success;

@end

#pragma mark -- 申请开门密码响应数据
@interface DoorDuOperateRecord : DoorDuBaseResponse
/**
 *  开门类型  0-所有记录  1-IC卡开门  2-APP开门 3-呼叫开门 4-密码开门 5-未接通
 */
@property (nonatomic,copy) NSNumber *openType;
/**
 *  开门类型解释
 */
@property (nonatomic,copy) NSString *openTypeInfo;
/**
 *  详情描述
 */
@property (nonatomic,copy) NSString *detailDescription;
/**
 *  缩略图地址
 */
@property (nonatomic,copy) NSString *thumbnailUrl;
/**
 *  访客照片原址
 */
@property (nonatomic,copy) NSString *imgUrl;
/**
 *  是否接通 0-未接通 1-已接通， 开门类型为呼叫开门时有效
 */
@property (nonatomic,copy) NSNumber *isConnect;
/**
 *  开门时间戳
 */
@property (nonatomic,copy) NSNumber *timestamp;
/**
 *  房间id
 */
@property (nonatomic,copy) NSNumber *roomId;
/**
 *  门禁GUID
 */
@property (nonatomic,copy) NSNumber *doorGuid;
@end






