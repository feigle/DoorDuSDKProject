//
//  DoorDuDataManagerPrivate.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/11.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoorDuError.h"
#import "DoorDuAllResponse.h"

/**内部私有数据接口*/
@interface DoorDuDataManagerPrivate : NSObject

/*! @brief DoorDuDataApi成员函数， 呼叫接口
 *
 * @param       deviceUUID  呼叫设备UUID
 * @param       fromRoomId  主叫房间id
 * @param       toRoomId    被叫房间ID
 * @param       toRoomNo    被叫房间号码
 * @param       callType    呼叫类型 0-语音呼叫、1-视频呼叫
 * @param       completion  获取状
 */
+ (void)makeCall:(NSString *)deviceUUID
      fromRoomId:(NSString *)fromRoomId
        toRoomId:(NSString *)toRoomId
        toRoomNo:(NSString *)toRoomNo
        callType:(NSString *)callType
      completion:(void(^)(DoorDuCall *callData, DoorDuError *error))completion;

@end
