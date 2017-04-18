//
//  AppHelp.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/17.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppHelp : NSObject

+ (void)jumpToSystemSetting;

+ (BOOL)checkMediaAndAudioAuthStateWithParentViewController:(UIViewController *)parentVC;

@end
