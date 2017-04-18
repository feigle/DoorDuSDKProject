//
//  DoorDuDoorCallModel.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/11.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuBaseResponse.h"
#import "DoorDuClientEnum.h"

/**
 门禁呼叫通推送数据模型
 */
@interface DoorDuDoorCallModel : DoorDuBaseModel

@property (nonatomic,assign) DoorDuCallType callType;/**来电类型*/
@property (nonatomic,copy) NSString *doorName;/**门禁机的名称*/
@property (nonatomic,copy) NSString *doorCallerNO;/**门禁机的呼叫账号*/
@property (nonatomic,copy) NSString *doorGuid;/**门禁机的guid*/
@property (nonatomic,copy) NSString *doorID;/**门禁机的唯一标识*/
@property (nonatomic,copy) NSString *appRoomID;/**被叫(App)的房间唯一标识*/

/**
 校验数据有效性
 
 @return YES表示数据有效
 */
- (BOOL)checkDataInvalid;

@end

