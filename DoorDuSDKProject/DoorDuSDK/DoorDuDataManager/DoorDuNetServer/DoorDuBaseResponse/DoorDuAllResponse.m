//
//  DoorDuAllResponse.m
//  NetTest
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuAllResponse.h"

@implementation DoorDuToken
@end

@implementation DoorDuUserInfo

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"user_id"]) {
        self.userId = value;
    }else if ([key isEqualToString:@"mobile_no"]) {
        self.mobileNo = value;
    }else if ([key isEqualToString:@"nation_code"]) {
        self.nationCode = value;
    }else if ([key isEqualToString:@"is_disturb"]) {
        self.isDisturb = value;
    }else if ([key isEqualToString:@"is_called_disturb"]) {
        self.isCalledDisturb = value;
    }else if ([key isEqualToString:@"sip_no"]) {
        self.callerNo = value;
    }else if ([key isEqualToString:@"sip_password"]) {
        self.callerPassword = value;
    }else if ([key isEqualToString:@"sip_domain"]) {
        self.callerDomain = value;
    }else if ([key isEqualToString:@"tls_port"]) {
        self.tlsPort = value;
    }else if ([key isEqualToString:@"tcp_port"]) {
        self.tcpPort = value;
    }else if ([key isEqualToString:@"udp_port"]) {
        self.udpPort = value;
    }else if ([key isEqualToString:@"coturn_server"]) {
        self.coturnServer = value;
    }else if ([key isEqualToString:@"coturn_port"]) {
        self.coturnPort = value;
    }else if ([key isEqualToString:@"coturn_user"]) {
        self.coturnUser = value;
    }else if ([key isEqualToString:@"coturn_pass"]) {
        self.coturnPass = value;
    }else if ([key isEqualToString:@"rtcp_fb"]) {
        self.rtcpFb = value;
    }else {
        [super setValue:value forKey:key];
    }
}

@end

@implementation DoorDuDepartments

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"department_id"]) {
        self.departmentId = value;
    }else if ([key isEqualToString:@"department_name"]) {
        self.departmentName = value;
    }else {
        [super setValue:value forKey:key];
    }
}

@end

@implementation DoorDuBuilding

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"building_id"]) {
        self.buildingId = value;
    }else if ([key isEqualToString:@"building_name"]) {
        self.buildingName = value;
    }else if ([key isEqualToString:@"building_no"]) {
        self.buildingNo = value;
    }else if ([key isEqualToString:@"units_of_each_floor"]) {
        self.unitsOfEachFloor = value;
    }else if ([key isEqualToString:@"building_type"]) {
        self.buildingType = value;
    }else if ([key isEqualToString:@"department_id"]) {
        self.departmentId = value;
    }else if ([key isEqualToString:@"department_name"]) {
        self.departmentName = value;
    }else {
        [super setValue:value forKey:key];
    }
}

@end

@implementation DoorDuUnit

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"unit_id"]) {
        self.unitId = value;
    }else if ([key isEqualToString:@"unit_name"]) {
        self.unitName = value;
    }else if ([key isEqualToString:@"building_id"]) {
        self.buildingId = value;
    }else {
        [super setValue:value forKey:key];
    }
}

@end

@implementation DoorDuRoom

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"status"]) {
        self.roomStatus = value;
    }else if ([key isEqualToString:@"room_id"]) {
        self.roomId = value;
    }else if ([key isEqualToString:@"room_name"]) {
        self.roomName = value;
    }else if ([key isEqualToString:@"unit_id"]) {
        self.unitId = value;
    }else if ([key isEqualToString:@"people_number"]) {
        self.peopleNumber = value;
    }else {
        [super setValue:value forKey:key];
    }
}


@end

@implementation DoorDuUserRoom

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"door_list"]){
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([value isKindOfClass:[NSArray class]]) {
            
            for (NSMutableDictionary *dic in value)
            {
                [array addObject:[[DoorDuDoorInfo alloc] initWithDictionary:dic]];
            }
            
        }else if ([value isKindOfClass:[NSDictionary class]]) {
            
            [array addObject:[[DoorDuDoorInfo alloc] initWithDictionary:value]];
        }
        self.doorList = array;
    }else if ([key isEqualToString:@"room_id"]) {
        self.roomId = value;
    }else if ([key isEqualToString:@"room_no"]) {
        self.roomNo = value;
    }else if ([key isEqualToString:@"unit_no"]) {
        self.unitNo = value;
    }else if ([key isEqualToString:@"building_no"]) {
        self.buildingNo = value;
    }else if ([key isEqualToString:@"is_owner"]) {
        self.isOwner = value;
    }else if ([key isEqualToString:@"is_disturb"]) {
        self.isDisturb = value;
    }else if ([key isEqualToString:@"is_upload_card"]) {
        self.isUploadCard = value;
    }else if ([key isEqualToString:@"application_list"]) {
        self.applicationList = value;
    }else if ([key isEqualToString:@"transfer_mobile"]) {
        self.transferMobile = value;
    }else if ([key isEqualToString:@"department_name"]) {
        self.departmentName = value;
    }else if ([key isEqualToString:@"building_unit_room_name"]) {
        self.buildingUnitRoomName = value;
    }else if ([key isEqualToString:@"province_name"]) {
        self.provinceName = value;
    }else if ([key isEqualToString:@"city_name"]) {
        self.cityName = value;
    }else if ([key isEqualToString:@"district_name"]) {
        self.districtName = value;
    }else if ([key isEqualToString:@"dep_id"]) {
        self.depId = value;
    }else if ([key isEqualToString:@"is_called_disturb"]) {
        self.isCalledDisturb = value;
    }else if ([key isEqualToString:@"nation_code"]) {
        self.nationCode = value;
    }else if ([key isEqualToString:@"building_id"]) {
        self.buildingId = value;
    }else if ([key isEqualToString:@"unit_id"]) {
        self.unitId = value;
    }else if ([key isEqualToString:@"auth_end_time"]) {
        self.authEndTime = value;
    }else {
        [super setValue:value forKey:key];
    }
}


@end

@implementation DoorDuDoorInfo

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"door_id"]) {
        self.doorId = value;
    }else if ([key isEqualToString:@"door_name"]) {
        self.doorName = value;
    }else if ([key isEqualToString:@"door_alias"]) {
        self.doorAlias = value;
    }else if ([key isEqualToString:@"door_guid"]) {
        self.doorGuid = value;
    }else if ([key isEqualToString:@"door_sip_no"]) {
        self.doorCallerNo = value;
    }else if ([key isEqualToString:@"ssid_secretkey"]) {
        self.ssidSecretkey = value;
    }else if ([key isEqualToString:@"ssid_pwd"]) {
        self.ssidPwd = value;
    }else {
        [super setValue:value forKey:key];
    }
}

@end

@implementation DoorDuCall

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"expired_seconds"]) {
        self.expiredSeconds = value;
    }else if ([key isEqualToString:@"transaction_id"]) {
        self.transactionId = value;
    }else if ([key isEqualToString:@"sip_list"]) {
        self.callerList = value;
    }else if ([key isEqualToString:@"to_room_id"]) {
        self.toRoomId = value;
    }else {
        [super setValue:value forKey:key];
    }
}


@end

@implementation DoorDuApplyPwd

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"list"]){
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([value isKindOfClass:[NSArray class]]) {
            
            for (NSMutableDictionary *dic in value)
            {
                [array addObject:[[DoorDuDeviceStatus alloc] initWithDictionary:dic]];
            }
            
        }else if ([value isKindOfClass:[NSDictionary class]]) {
            
            [array addObject:[[DoorDuDeviceStatus alloc] initWithDictionary:value]];
        }
        self.list = array;
    }else if ([key isEqualToString:@"expired_time"]) {
        self.expiredTime = value;
    }else {
        [super setValue:value forKey:key];
    }
}
@end

@implementation DoorDuDeviceStatus

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"door_guid"]) {
        self.doorGuid = value;
    }else {
        [super setValue:value forKey:key];
    }
}

@end

@implementation DoorDuOperateRecord

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"description"]) {
        self.detailDescription = value;
    }else if ([key isEqualToString:@"open_type"]) {
        self.openType = value;
    }else if ([key isEqualToString:@"open_type_info"]) {
        self.openTypeInfo = value;
    }else if ([key isEqualToString:@"thumbnail_url"]) {
        self.thumbnailUrl = value;
    }else if ([key isEqualToString:@"img_url"]) {
        self.imgUrl = value;
    }else if ([key isEqualToString:@"is_connect"]) {
        self.isConnect = value;
    }else if ([key isEqualToString:@"room_id"]) {
        self.roomId = value;
    }else if ([key isEqualToString:@"door_guid"]) {
        self.doorGuid = value;
    }else {
        [super setValue:value forKey:key];
    }
}
@end




