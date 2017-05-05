//
//  AppDelegate.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "DoorDuMainViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <AddressBook/AddressBook.h>
#import <AVFoundation/AVFoundation.h>
#import "DoorDuDataManager.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        
    }];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
    }];
    [self registerRemoteNotification];

    return YES;
}

- (void)registerRemoteNotification
{
    // 注册通知
    //iOS 10
    if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
                NSLog(@"注册通知成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@", settings);
                }];
            } else {
                //点击不允许
                NSLog(@"注册通知失败");
            }
        }];
        center.delegate = self;
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"%@",settings);
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else{
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            //IOS8，创建UIUserNotificationSettings，并设置消息的显示类类型
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:notiSettings];
        }
    }
}

#pragma mark -- 注册通知成功回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"获取deviceToken成功：%@",deviceToken);
    [DoorDuDataManager registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"获取deviceToken失败：%@",error);
}

//收到远程推送消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}
//收到本地推送消息
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}
/***********iOS10 推送数据处理***********/
#pragma mark- UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    UIApplication * application  = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    } else {
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    UIApplication * application  = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        completionHandler();
    } else {
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
