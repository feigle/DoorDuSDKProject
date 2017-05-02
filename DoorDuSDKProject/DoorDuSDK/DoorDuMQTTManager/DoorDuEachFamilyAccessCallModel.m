//
//  DoorDuAppCallModel.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/11.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuEachFamilyAccessCallModel.h"

@implementation DoorDuEachFamilyAccessCallModel

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"appSipNO"]) {
        self.appCallerNO = value;
    } else if ([key isEqualToString:@"incomingType"]){
        /**来电类型，0:app来电，1:门禁机来电*/
        self.callType = kDoorDuCallNone;
        if ([value integerValue] == 0) {
            self.callType = kDoorDuCallEachFamilyAccess;
        } else if ([value integerValue] == 1){
            self.callType = kDoorDuCallDoor;
        }
    } else if ([key isEqualToString:@"callType"]){
        /**呼叫类型，0语音呼叫，1视频呼叫*/
        self.mediaCallType = kDoorDuMediaCallTypeAudio;
        if ([value integerValue] == 1) {
            self.mediaCallType = kDoorDuMediaCallTypeVideo;
        }
    } else {
        [super setValue:value forKey:key];
    }
}

- (BOOL)checkDataInvalid
{
    if (self.roomID <= 0 ||
        self.appCallerNO.length <= 0 ||
        self.remoteRoomID.length <= 0) {
        
        return NO;
    }
    return YES;
}

@end
