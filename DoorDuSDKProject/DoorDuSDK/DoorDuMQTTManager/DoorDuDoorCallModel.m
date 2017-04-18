//
//  DoorDuDoorCallModel.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/11.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuDoorCallModel.h"

@implementation DoorDuDoorCallModel

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"doorSipNO"]) {
        self.doorCallerNO = value;
    } else if ([key isEqualToString:@"incomingType"]){
        /**来电类型，0:app来电，1:门禁机来电*/
        self.callType = kDoorDuCallNone;
        if ([value isEqualToString:@"0"]) {
            self.callType = kDoorDuCallEachFamilyAccess;
        } else if ([value isEqualToString:@"1"]){
            self.callType = kDoorDuCallDoor;
        }
    } else {
        [super setValue:value forKey:key];
    }
}

- (BOOL)checkDataInvalid
{
    if (self.doorName.length <= 0 ||
        self.doorName.length <= 0 ||
        self.doorCallerNO <= 0 ||
        self.doorGuid.length <= 0 ||
        self.appRoomID.length <= 0) {
        
        return NO;
    }
    return YES;
}

@end
