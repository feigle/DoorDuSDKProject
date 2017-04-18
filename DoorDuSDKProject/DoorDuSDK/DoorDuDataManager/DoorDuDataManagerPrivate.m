//
//  DoorDuDataManagerPrivate.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/11.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuDataManagerPrivate.h"
#import "DoorDuAllResponse.h"
#import "DoorDuAllRequestParam.h"
#import "DoorDuNetServices.h"
#import "DoorDuProxyInfo.h"

@implementation DoorDuDataManagerPrivate

+ (void)makeCall:(NSString *)deviceUUID
      fromRoomId:(NSString *)fromRoomId
        toRoomId:(NSString *)toRoomId
        toRoomNo:(NSString *)toRoomNo
        callType:(NSString *)callType
      completion:(void(^)(DoorDuCall *callData, DoorDuError *error))completion
{
    DoorDuCallParam *param = [DoorDuCallParam new];
    param.device_guid = deviceUUID;
    param.from_room_id = fromRoomId;
    param.to_room_id = toRoomId;
    param.to_room_no = toRoomNo;
    param.call_type = callType;
    [DoorDuNetServices getDoorDuSDKData:param bodyType:[DoorDuCall class] success:^(DoorDuBaseResponse *object) {
        
        DoorDuCall *callData = [object.body firstObject];
        // 保存token
        completion(callData, nil);
    } failure:^(DoorDuError *error) {
        completion(nil, error);
    }];
}

@end
