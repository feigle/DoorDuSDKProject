//
//  DoorDuAppCallModel.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/11.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuBaseResponse.h"
#import "DoorDuClientEnum.h"

/**
 户户通推送数据模型
 */
@interface DoorDuEachFamilyAccessCallModel : DoorDuBaseModel

@property (nonatomic,assign) DoorDuCallType callType;/**来电类型*/
@property (nonatomic,assign) DoorDuMediaCallType mediaCallType;/**呼叫类型，0语音呼叫，1视频呼叫*/
@property (nonatomic,copy) NSString *roomID;/**主叫(A)房间的唯一标识*/
@property (nonatomic,copy) NSString *roomName;/**主叫(A)房间的名称*/
@property (nonatomic,copy) NSString *appCallerNO;/**主叫(A)的呼叫账号*/
@property (nonatomic,copy) NSString *remoteRoomID;/**被叫的房间唯一标识*/

/**
 校验数据有效性
 
 @return YES表示数据有效
 */
- (BOOL)checkDataInvalid;

@end

