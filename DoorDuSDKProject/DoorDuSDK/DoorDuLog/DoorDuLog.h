//
//  DoorDuLog.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DoorDuLogVerbose(frmt, ...)\
if ([DoorDuLog isLogEnable]) {\
NSLog(@"[DoorDuSDK Verbose]: %@", [NSString stringWithFormat:(frmt), ##__VA_ARGS__]);\
}

#define DoorDuLogDebug(frmt, ...)\
if ([DoorDuLog isLogEnable]) {\
NSLog(@"[DoorDuSDK Debug]: %@", [NSString stringWithFormat:(frmt), ##__VA_ARGS__]);\
}

#define DoorDuLogError(frmt, ...)\
if ([DoorDuLog isLogEnable]) {\
NSLog(@"[DoorDuSDK Error]: %@", [NSString stringWithFormat:(frmt), ##__VA_ARGS__]);\
}

@interface DoorDuLog : NSObject
+ (void)enableLog;
+ (void)disableLog;
+ (BOOL)isLogEnable;
@end
