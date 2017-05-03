//
//  DoorDuDataApi.m
//  NetTest
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuDataManager.h"
#import "DoorDuAllResponse.h"
#import "DoorDuAllRequestParam.h"
#import "DoorDuNetServices.h"
#import "DoorDuProxyInfo.h"

@implementation DoorDuDataManager

+ (void)getTokenWithAppId:(NSString *)appId secretKey:(NSString *)secretKey completion:(void(^)(DoorDuToken *resToken, DoorDuError *error))completion
{
    DoorDuTokenParam *param = [DoorDuTokenParam new];
    param.app_id = appId;
    param.secret_key = secretKey;
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuToken class] success:^(DoorDuBaseResponse *object) {
        
        DoorDuToken *token = [object.body firstObject];
        // 保存token
        [DoorDuProxyInfo sharedInstance].token = token.token;
        completion(token, nil);
    } failure:^(DoorDuError *error) {
        completion(nil, error);
    }];
}
/** 向Doordu注册该设备的deviceToken，便于发送Push消息
 @param deviceToken APNs返回的deviceToken
 */
+ (void)registerDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenStr = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                 stringByReplacingOccurrencesOfString:@">" withString:@""]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    [DoorDuProxyInfo sharedInstance].deviceTokenString = deviceTokenStr;
}
/**获取deviceToken字符串*/
+ (NSString *)getDeviceTokenString
{
    return [DoorDuProxyInfo sharedInstance].deviceTokenString;
}
+ (void)bindingDeviceToken:(NSString *)pushToken
                    userId:(NSString *)userId
                  sdkToken:(NSString *)sdkToken
                deviceUUID:(NSString *)deviceUUID
                completion:(void(^)(BOOL isSuccess, DoorDuError *error))completion
{
    DoorDuPushParam *param = [DoorDuPushParam new];
    param.token = sdkToken;
    param.user_id = userId;
    param.device_token = pushToken;
    param.device_guid = deviceUUID;
    param.isBinding = YES;
    
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuBaseResponse class] success:^(DoorDuBaseResponse *object) {
            completion(YES, nil);
    } failure:^(DoorDuError *error) {
        completion(NO, error);
    }];
}
+ (void)unbindingDeviceToken:(NSString *)token
                      userId:(NSString *)userId
                    sdkToken:(NSString *)sdkToken
                  deviceUUID:(NSString *)deviceUUID
                  completion:(void(^)(BOOL isSuccess, DoorDuError *error))completion
{
    DoorDuPushParam *param = [DoorDuPushParam new];
    param.token = token;
    param.user_id = userId;
    param.device_token = sdkToken;
    param.device_guid = deviceUUID;
    param.isBinding = NO;
    
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuBaseResponse class] success:^(DoorDuBaseResponse *object) {
            completion(YES, nil);
    } failure:^(DoorDuError *error) {
        completion(NO, error);
    }];
}


+ (void)getUserInfoWithMobileNo:(NSString *)mobileNo
                     nationCode:(NSString *)nationCode
                     deviceUUID:(NSString *)deviceUUID
                     completion:(void(^)(DoorDuUserInfo *token, DoorDuError *error))completion
{
    DoorDuUserInfoParam *userInfoParam = [DoorDuUserInfoParam new];
    userInfoParam.token = [DoorDuProxyInfo sharedInstance].token;
    userInfoParam.nation_code = nationCode;
    userInfoParam.mobile_no = mobileNo; //13410010212
    userInfoParam.device_guid = deviceUUID;
    [DoorDuNetServices getDoorDuSDKData:userInfoParam bodyType:[DoorDuUserInfo class] success:^(DoorDuBaseResponse *object) {
        
        DoorDuUserInfo *userInfo = [object.body firstObject];
        [DoorDuProxyInfo sharedInstance].userInfo = userInfo;
        completion(userInfo, nil);
    } failure:^(DoorDuError *error) {
        completion(nil, error);
    }];
}

+ (void)openDoorServiceWithDoorId:(NSString *)doorId
                           roomId:(NSString *)roomId
                      operateType:(NSString *)type
                       deviceUUID:(NSString *)deviceUUID
                       completion:(void(^)(BOOL isSuccess, DoorDuError *error))completion
{
    DoorDuOpenDoorParam *param = [DoorDuOpenDoorParam new];
    param.token = [DoorDuProxyInfo sharedInstance].token;
    param.user_id = [DoorDuProxyInfo sharedInstance].userInfo.userId;
    param.device_guid = deviceUUID;
    param.door_id = doorId;
    param.room_id = roomId;
    param.operate_type = type;
    
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuBaseResponse class] success:^(DoorDuBaseResponse *object) {
        
        completion(YES, nil);
    } failure:^(DoorDuError *error) {
        completion(NO, error);
    }];
}

+ (void)getDepartmentsCompletion:(void(^)(NSArray *departments, DoorDuError *error))completion
{
    DoorDuDepartmentParam *param = [DoorDuDepartmentParam new];
    param.token = [DoorDuProxyInfo sharedInstance].token;
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuDepartments class] success:^(DoorDuBaseResponse *object) {
        
        completion(object.body, nil);
    } failure:^(DoorDuError *error) {
        completion(nil, error);
    }];
}

+ (void)getBuildingListWithDepartmentId:(NSNumber *)departmentId
                             completion:(void(^)(NSArray *allBuilding, DoorDuError *error))completion
{
    DoorDuBuildingParam *param = [DoorDuBuildingParam new];
    param.token = [DoorDuProxyInfo sharedInstance].token;
    param.department_id = departmentId;
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuBuilding class] success:^(DoorDuBaseResponse *object) {
        
        completion(object.body, nil);
    } failure:^(DoorDuError *error) {
         completion(nil, error);
    }];
}

+ (void)getUnitListWithBuildingId:(NSNumber *)buildingId
                       completion:(void(^)(NSArray *allUnit, DoorDuError *error))completion
{
    DoorDuUnitParam *param = [DoorDuUnitParam new];
    param.token = [DoorDuProxyInfo sharedInstance].token;
    param.building_id = buildingId;
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuUnit class] success:^(DoorDuBaseResponse *object) {
        
        completion(object.body, nil);
    } failure:^(DoorDuError *error) {
        completion(nil, error);
    }];
}

+ (void)getUnitRoomListWithUnitId:(NSNumber *)unitId
                       completion:(void(^)(NSArray *rooms, DoorDuError *error))completion
{
    DoorDuRoomParam *param = [DoorDuRoomParam new];
    param.token = [DoorDuProxyInfo sharedInstance].token;
    param.unit_id = unitId;
    
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuUserRoom class] success:^(DoorDuBaseResponse *object) {
        
        completion(object.body, nil);
    } failure:^(DoorDuError *error) {
        completion(nil, error);
    }];
}

+ (void)getUserRoomListWithDeviceUUID:(NSString *)deviceUUID
                           completion:(void(^)(NSArray *rooms, DoorDuError *error))completion
{
    DoorDuUserRoomsParam *param = [DoorDuUserRoomsParam new];
    param.token = [DoorDuProxyInfo sharedInstance].token;
    param.user_id = [DoorDuProxyInfo sharedInstance].userInfo.userId;
    param.device_guid = deviceUUID;
    param.device_type = @"3";
    
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuUserRoom class] success:^(DoorDuBaseResponse *object) {
        
        completion(object.body, nil);
    } failure:^(DoorDuError *error) {
        completion(nil, error);
    }];
}

+ (void)configUserDisturbingWithCallStatus:(NSNumber *)callStatus
                                deviceUUID:(NSString *)deviceUUID
                          forwardingStatus:(NSNumber *)forwardingStatus
                                completion:(void(^)(BOOL success, DoorDuError *error))completion;
{
    DoorDuDisturbParam *param = [DoorDuDisturbParam new];
    param.token = [DoorDuProxyInfo sharedInstance].token;
    param.user_id = [DoorDuProxyInfo sharedInstance].userInfo.userId;
    param.device_guid = deviceUUID;
    param.call_status = callStatus;
    param.forwarding_status = forwardingStatus;
    
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuBaseResponse class] success:^(DoorDuBaseResponse *object) {
        
        completion(YES, nil);
    } failure:^(DoorDuError *error) {
        completion(NO, error);
    }];
}

+ (void)configRoomDisturbingWithRoomId:(NSString *)roomId
                            callerror:(NSNumber *)callStatus
                            deviceUUID:(NSString *)deviceUUID
                      forwardingerror:(NSNumber *)forwardingStatus
                            completion:(void(^)(BOOL success, DoorDuError *error))completion
{
    DoorDuRoomDisturbParam *param = [DoorDuRoomDisturbParam new];
    param.token = [DoorDuProxyInfo sharedInstance].token;
    param.user_id = [DoorDuProxyInfo sharedInstance].userInfo.userId;
    param.device_guid = deviceUUID;
    param.call_status = callStatus;
    param.forwarding_status = forwardingStatus;
    param.room_id = roomId;
    
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuBaseResponse class] success:^(DoorDuBaseResponse *object) {
        
        completion(YES, nil);
    } failure:^(DoorDuError *error) {
        completion(NO, error);
    }];
}

+ (void)applyDoorPasswordWithRoomId:(NSString *)roomId
                         deviceUUID:(NSString *)deviceUUID
                         completion:(void(^)(DoorDuApplyPwd *doorPwd, DoorDuError *error))completion
{
    DoorDuApplyPwdParam *param = [DoorDuApplyPwdParam new];
    param.token = [DoorDuProxyInfo sharedInstance].token;
    param.user_id = [DoorDuProxyInfo sharedInstance].userInfo.userId;
    param.device_guid = deviceUUID;
    param.room_id = roomId;
    
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuApplyPwd class] success:^(DoorDuBaseResponse *object) {
        
        DoorDuApplyPwd *doorPWD = [object.body firstObject];
        completion(doorPWD, nil);
    } failure:^(DoorDuError *error) {
        completion(nil, error);
    }];
}

+ (void)getOpenDoorRecordsWithRoomId:(NSString *)roomId
                           startPage:(NSNumber *)startPage
                            pageSize:(NSNumber *)pageSize
                            openType:(NSNumber *)openType
                          completion:(void(^)(NSArray *records, DoorDuError *error))completion
{
    DoorDuOperateRecordParam *param = [DoorDuOperateRecordParam new];
    param.token = [DoorDuProxyInfo sharedInstance].token;;
    param.user_id = [DoorDuProxyInfo sharedInstance].userInfo.userId;
    param.room_id = roomId;
    param.start_page = startPage;
    param.page_no = pageSize;
    param.open_type = openType;
    
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuOperateRecord class] success:^(DoorDuBaseResponse *object) {
        
        completion(object.body, nil);
    } failure:^(DoorDuError *error) {
        completion(nil, error);
    }];
}

+ (void)getCallerPhotoWithDoorSipNo:(NSString *)doorSipNo
                         completion:(void(^)(id image, DoorDuError *error))completion
{
    DoorDuCallPhoto *param = [DoorDuCallPhoto new];
    param.token = [DoorDuProxyInfo sharedInstance].token;
    param.user_id = [DoorDuProxyInfo sharedInstance].userInfo.userId;
    param.fromSipNo = doorSipNo;
    
    [DoorDuNetServices getDoorDuSDKData:param bodyType:nil success:^(DoorDuBaseResponse *object) {
        
        completion(object.body.firstObject, nil);
    } failure:^(DoorDuError *error) {
        completion(nil, error);
    }];
}

@end
