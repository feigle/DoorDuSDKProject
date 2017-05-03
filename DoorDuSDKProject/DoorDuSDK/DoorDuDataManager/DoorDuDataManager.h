//
//  DoorDuDataApi.h
//  NetTest
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuError.h"
#import "DoorDuAllResponse.h"

@interface DoorDuDataManager : NSObject

/*! @brief DoorDuDataApi成员函数， 获取token
 *
 * @param       appId       doordu授权的的appid
 * @param       secretKey   doordu授权的的secretKey
 * @param       completion  获取状态（如果token有值， error为nil）
 */
+ (void)getTokenWithAppId:(NSString *)appId
                secretKey:(NSString *)secretKey
               completion:(void(^)(DoorDuToken *token, DoorDuError *error))completion;

/** 向Doordu注册该设备的deviceToken，便于发送Push消息
 @param deviceToken APNs返回的deviceToken
 */
+ (void)registerDeviceToken:(NSData *)deviceToken;
/**获取deviceToken字符串*/
+ (NSString *)getDeviceTokenString;

/**
 绑定推送
 
 @param pushToken               消息推送令牌
 @param userId              用户id
 @param sdkToken            sdk授权token
 @param deviceUUID          用户设备唯一编码
 @param completion          结果回调
 */
+ (void)bindingDeviceToken:(NSString *)pushToken
                    userId:(NSString *)userId
                  sdkToken:(NSString *)sdkToken
                deviceUUID:(NSString *)deviceUUID
                completion:(void(^)(BOOL isSuccess, DoorDuError *error))completion;

/**
 解绑推送（用户注销的时候调用）
 
 @param token               消息推送令牌
 @param userId              用户id
 @param sdkToken            sdk授权token
 @param deviceUUID          用户设备唯一编码
 @param completion          结果回调
 */
+ (void)unbindingDeviceToken:(NSString *)token
                      userId:(NSString *)userId
                    sdkToken:(NSString *)sdkToken
                  deviceUUID:(NSString *)deviceUUID
                  completion:(void(^)(BOOL isSuccess, DoorDuError *error))completion;

/*! @brief DoorDuDataApi成员函数， 获取用户信息
 *
 * @param       mobileNo     用户手机号码
 * @param       nationCode   用户国际编码（中国 “86”，只传数字即可，不用传“+”）
 * @param       deviceUUID   用户设备唯一编码
 * @param       completion   获取状态（如果userInfo有值， error为nil）
 */
+ (void)getUserInfoWithMobileNo:(NSString *)mobileNo
                     nationCode:(NSString *)nationCode
                     deviceUUID:(NSString *)deviceUUID
                     completion:(void(^)(DoorDuUserInfo *userInfo, DoorDuError *error))completion;


/*! @brief DoorDuDataApi成员函数， 一键开门
 *
 * @param       doorId      门禁id
 * @param       roomId      房间id
 * @param       type        开门方式：“2” APP开门，“6” 视频开门
 * @param       completion  获取状态（开门成功isSuccess为yes， error为nil）
 */
+ (void)openDoorServiceWithDoorId:(NSString *)doorId
                           roomId:(NSString *)roomId
                      operateType:(NSString *)type
                       deviceUUID:(NSString *)deviceUUID
                       completion:(void(^)(BOOL isSuccess, DoorDuError *error))completion;


/*! @brief DoorDuDataApi成员函数， 获取小区列表
 *
 * @param       completion  获取状态（departments为返回小区数组类型<DoorDuDepartments>， error为nil）
 */
+ (void)getDepartmentsCompletion:(void(^)(NSArray *departments, DoorDuError *error))completion;


/*! @brief DoorDuDataApi成员函数， 获取栋列表
 *
 * @param   departmentId    小区id
 * @param   completion      获取状态（allBuilding为返回楼栋数组类型<DoorDuBuilding>， error为nil）
 */
+ (void)getBuildingListWithDepartmentId:(NSNumber *)departmentId
                             completion:(void(^)(NSArray *allBuilding, DoorDuError *error))completion;


/*! @brief DoorDuDataApi成员函数， 获取单元列表
 *
 * @param   buildingId      楼栋id
 * @param   completion      获取状态（allUnit为返回楼栋数组类型<DoorDuUnit>， error为nil）
 */
+ (void)getUnitListWithBuildingId:(NSNumber *)buildingId
                       completion:(void(^)(NSArray *allUnit, DoorDuError *error))completion;


/*! @brief DoorDuDataApi成员函数， 获取单元房间列表
 *
 * @param   unitId      单元id
 * @param   completion  获取状态（rooms为返回楼栋数组类型<DoorDuUserRoom>， error为nil）
 */
+ (void)getUnitRoomListWithUnitId:(NSNumber *)unitId
                       completion:(void(^)(NSArray *rooms, DoorDuError *error))completion;


/*! @brief DoorDuDataApi成员函数， 获取用户房间列表
 *
 * @param   deviceUUID  设备唯一码
 * @param   completion  获取状态（rooms为返回楼栋数组类型<DoorDuUserRoom>， error为nil）
 */
+ (void)getUserRoomListWithDeviceUUID:(NSString *)deviceUUID
                           completion:(void(^)(NSArray *rooms, DoorDuError *error))completion;



/*! @brief DoorDuDataApi成员函数， 针对用户设置一键免打扰
 *
 * @param   callStatus          呼叫免打扰：0-关闭 1-开启
 * @param   deviceUUID          设备标识
 * @param   forwardingStatus    呼叫转接免打扰：0-关闭 1-开启
 * @param   completion          获取状态（设置成功isSuccess为yes， error为nil）
 */
+ (void)configUserDisturbingWithCallStatus:(NSNumber *)callStatus
                                deviceUUID:(NSString *)deviceUUID
                          forwardingStatus:(NSNumber *)forwardingStatus
                                completion:(void(^)(BOOL success, DoorDuError *error))completion;


/*! @brief DoorDuDataApi成员函数， 设置房间免打扰
 *
 * @param   roomId              用户房间标示
 * @param   callStatus          呼叫免打扰：0-关闭 1-开启
 * @param   deviceUUID          设备标识
 * @param   forwardingStatus    呼叫转接免打扰：0-关闭 1-开启
 * @param   completion          获取状态（设置成功isSuccess为yes， error为nil）
 */
+ (void)configRoomDisturbingWithRoomId:(NSString *)roomId
                            callerror:(NSNumber *)callStatus
                            deviceUUID:(NSString *)deviceUUID
                      forwardingerror:(NSNumber *)forwardingStatus
                            completion:(void(^)(BOOL success, DoorDuError *error))completion;


/*! @brief DoorDuDataApi成员函数， 申请密码开门
 *
 * @param   roomId              用户房间标示
 * @param   deviceUUID          设备标识
 * @param   completion          获取状态
 */
+ (void)applyDoorPasswordWithRoomId:(NSString *)roomId
                         deviceUUID:(NSString *)deviceUUID
                         completion:(void(^)(DoorDuApplyPwd *doorPwd, DoorDuError *error))completion;


/*! @brief DoorDuDataApi成员函数， 获取开门记录列表
 *
 * @param   roomId              用户房间标示
 * @param   startPage           起始页 以1开始页
 * @param   pageSize            一页显示数量
 * @param   openType            开门类型 0-所有记录 1-IC卡开门 2-APP开门 3-呼叫开门 4-密码开门 5-未接通
 * @param   completion          获取结果返回
 */
+ (void)getOpenDoorRecordsWithRoomId:(NSString *)roomId
                           startPage:(NSNumber *)startPage
                            pageSize:(NSNumber *)pageSize
                            openType:(NSNumber *)openType
                          completion:(void(^)(NSArray *records, DoorDuError *error))completion;

/*! @brief DoorDuDataApi成员函数， 获取来电留影照片
 *
 * @param   doorSipNo           来电方sip账号
 * @param   completion          获取结果返回
 */
+ (void)getCallerPhotoWithDoorSipNo:(NSString *)doorSipNo
                         completion:(void(^)(id image, DoorDuError *error))completion;

@end
