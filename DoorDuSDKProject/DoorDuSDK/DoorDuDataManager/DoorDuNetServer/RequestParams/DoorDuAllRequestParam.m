//
//  DoorDuAllRequestParam.m
//  NetTest
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuAllRequestParam.h"

@implementation DoorDuRootParam
- (DoorDuRequestMethod )buildRequestMethod;
{
    return DoorDuRequestTypeGet;
}
- (NSString *)buildRequestPath
{
    return nil;
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.token)
    {
        [dic setObject:self.token forKey:@"token"];
    }
    
    return dic;
}
@end

@implementation DoorDuTokenParam
- (NSString *)buildRequestPath
{
    return @"v1/token";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.app_id)
    {
        [dic setObject:self.app_id forKey:@"app_id"];
    }
    
    if (self.secret_key)
    {
        [dic setObject:self.secret_key forKey:@"secret_key"];
    }
    
    return dic;
}
@end

@implementation DoorDuPushParam

- (DoorDuRequestMethod)buildRequestMethod
{
    return DoorDuRequestTypePost;
}

- (NSString *)buildRequestPath
{
    if (_isBinding) {
        return @"v1/push/binding";
    }else {
        return @"v1/push/unbinding";
    }
    
}

- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.token)
    {
        [dic setObject:self.token forKey:@"token"];
    }
    
    if (self.device_guid)
    {
        [dic setObject:self.device_guid forKey:@"device_guid"];
    }
    
    if (self.user_id)
    {
        [dic setObject:self.user_id forKey:@"user_id"];
    }
    
    if (self.device_token)
    {
        [dic setObject:self.device_token forKey:@"device_token"];
    }
    
    if (_isBinding) {
        [dic setObject:@"1" forKey:@"system_type"];
    }
    
    return dic;
}


@end

@implementation DoorDuUserInfoParam
- (NSString *)buildRequestPath
{
    return @"v1/user/info";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.token)
    {
        [dic setObject:self.token forKey:@"token"];
    }
    
    if (self.nation_code)
    {
        [dic setObject:self.nation_code forKey:@"nation_code"];
    }
    
    if (self.mobile_no)
    {
        [dic setObject:self.mobile_no forKey:@"mobile_no"];
    }
    
    if (self.device_guid)
    {
        [dic setObject:self.device_guid forKey:@"device_guid"];
    }
    
    if (self.device_type)
    {
        [dic setObject:self.device_type forKey:@"device_type"];
    }else {
        [dic setObject:@"3" forKey:@"device_type"];
    }
    
    return dic;
}
@end

@implementation DoorDuDepartmentParam
- (NSString *)buildRequestPath
{
    return @"v1/all/department";
}
@end

@implementation DoorDuBuildingParam
- (NSString *)buildRequestPath
{
    return @"v1/building";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.department_id)
    {
        [dic setObject:self.department_id forKey:@"department_id"];
    }
    
    return dic;
}
@end

@implementation DoorDuUnitParam
- (NSString *)buildRequestPath
{
    return @"v1/unit";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.building_id)
    {
        [dic setObject:self.building_id forKey:@"building_id"];
    }
    
    return dic;
}
@end

@implementation DoorDuRoomParam
- (NSString *)buildRequestPath
{
    return @"v1/room";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.unit_id)
    {
        [dic setObject:self.unit_id forKey:@"unit_id"];
    }
    
    return dic;
}
@end

@implementation DoorDuDisturbParam
- (DoorDuRequestMethod )buildRequestMethod;
{
    return DoorDuRequestTypePost;
}

- (NSString *)buildRequestPath
{
    return @"v1/user/disturb";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.user_id)
    {
        [dic setObject:self.user_id forKey:@"user_id"];
    }
    if (self.device_guid)
    {
        [dic setObject:self.device_guid forKey:@"device_guid"];
    }
    if (self.call_status)
    {
        [dic setObject:self.call_status forKey:@"call_status"];
    }
    if (self.forwarding_status)
    {
        [dic setObject:self.forwarding_status forKey:@"forwarding_status"];
    }
    
    return dic;
}
@end

@implementation DoorDuUserRoomsParam
- (DoorDuRequestMethod )buildRequestMethod;
{
    return DoorDuRequestTypeGet;
}

- (NSString *)buildRequestPath
{
    return @"v1/user/rooms";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.user_id)
    {
        [dic setObject:self.user_id forKey:@"user_id"];
    }
    if (self.device_guid)
    {
        [dic setObject:self.device_guid forKey:@"device_guid"];
    }
    if (self.device_type)
    {
        [dic setObject:self.device_type forKey:@"device_type"];
    }else {
        [dic setObject:@"3" forKey:@"device_type"];
    }

    return dic;
}
@end



@implementation DoorDuRoomDisturbParam
- (DoorDuRequestMethod )buildRequestMethod;
{
    return DoorDuRequestTypePost;
}

- (NSString *)buildRequestPath
{
    return @"v1/rooms/disturb";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.user_id)
    {
        [dic setObject:self.user_id forKey:@"user_id"];
    }
    if (self.device_guid)
    {
        [dic setObject:self.device_guid forKey:@"device_guid"];
    }
    if (self.room_id)
    {
        [dic setObject:self.room_id forKey:@"room_id"];
    }
    if (self.call_status)
    {
        [dic setObject:self.call_status forKey:@"call_status"];
    }
    if (self.forwarding_status)
    {
        [dic setObject:self.forwarding_status forKey:@"forwarding_status"];
    }
    
    return dic;
}
@end

#pragma mark --获取token
@implementation DoorDuCallCallParam
- (DoorDuRequestMethod )buildRequestMethod;
{
    return DoorDuRequestTypePost;
}

- (NSString *)buildRequestPath
{
    return @"dds/community/v2/new_push/call";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.caller_type)
    {
        [dic setObject:self.caller_type forKey:@"caller_type"];
    }
    if (self.caller_device_id)
    {
        [dic setObject:self.caller_device_id forKey:@"caller_device_id"];
    }
    if (self.cmd)
    {
        [dic setObject:self.cmd forKey:@"cmd"];
    }
    if (self.room_id)
    {
        [dic setObject:self.room_id forKey:@"room_id"];
    }
        return dic;
}


@end


@implementation DoorDuCallParam
- (DoorDuRequestMethod )buildRequestMethod;
{
    return DoorDuRequestTypePost;
}

- (NSString *)buildRequestPath
{
    return @"v1/call";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.user_id)
    {
        [dic setObject:self.user_id forKey:@"user_id"];
    }
    if (self.device_guid)
    {
        [dic setObject:self.device_guid forKey:@"device_guid"];
    }
    if (self.from_room_id)
    {
        [dic setObject:self.from_room_id forKey:@"from_room_id"];
    }
    if (self.to_room_id)
    {
        [dic setObject:self.to_room_id forKey:@"to_room_id"];
    }
    if (self.to_room_no)
    {
        [dic setObject:self.to_room_no forKey:@"to_room_no"];
    }
    if (self.call_type)
    {
        [dic setObject:self.call_type forKey:@"call_type"];
    }
    return dic;
}
@end

@implementation DoorDuOpenDoorParam
- (DoorDuRequestMethod )buildRequestMethod;
{
    return DoorDuRequestTypePost;
}

- (NSString *)buildRequestPath
{
    return @"v1/doors/open";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.user_id)
    {
        [dic setObject:self.user_id forKey:@"user_id"];
    }
    if (self.device_guid)
    {
        [dic setObject:self.device_guid forKey:@"device_guid"];
    }
    if (self.door_id)
    {
        [dic setObject:self.door_id forKey:@"door_id"];
    }
    if (self.room_id)
    {
        [dic setObject:self.room_id forKey:@"room_id"];
    }
    if (self.operate_type)
    {
        [dic setObject:self.operate_type forKey:@"operate_type"];
    }
    return dic;
}
@end

@implementation DoorDuApplyPwdParam
- (DoorDuRequestMethod )buildRequestMethod;
{
    return DoorDuRequestTypePost;
}

- (NSString *)buildRequestPath
{
    return @"v1/doors/password";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.user_id)
    {
        [dic setObject:self.user_id forKey:@"user_id"];
    }
    if (self.device_guid)
    {
        [dic setObject:self.device_guid forKey:@"device_guid"];
    }
       if (self.room_id)
    {
        [dic setObject:self.room_id forKey:@"room_id"];
    }
    return dic;
}
@end

@implementation DoorDuOperateRecordParam
- (DoorDuRequestMethod )buildRequestMethod;
{
    return DoorDuRequestTypeGet;
}

- (NSString *)buildRequestPath
{
    return @"v1/visitor_log";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.user_id)
    {
        [dic setObject:self.user_id forKey:@"user_id"];
    }
    if (self.room_id)
    {
        [dic setObject:self.room_id forKey:@"room_id"];
    }
    if (self.start_page)
    {
        [dic setObject:self.start_page forKey:@"start_page"];
    }
    if (self.page_no)
    {
        [dic setObject:self.page_no forKey:@"page_no"];
    }
    if (self.open_type)
    {
        [dic setObject:self.open_type forKey:@"open_type"];
    }
    return dic;
}
@end

@implementation DoorDuCallPhoto

- (DoorDuRequestMethod )buildRequestMethod;
{
    return DoorDuRequestTypeGet;
}

- (DoorDuResponseDataType)buildResponseType
{
    return DoorDuResponseTypeImage;
}

- (NSString *)buildRequestPath
{
    return @"v1/caller/photo";
}
- (NSMutableDictionary *)buildRequestParam
{
    NSMutableDictionary *dic = [super buildRequestParam];
    
    if (self.user_id)
    {
        [dic setObject:self.user_id forKey:@"user_id"];
    }
    if (self.fromSipNo)
    {
        [dic setObject:self.fromSipNo forKey:@"door_sip_no"];
    }
    return dic;
}

@end



