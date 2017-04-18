//
//  AppHelp.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/17.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "AppHelp.h"

#import <AddressBook/AddressBook.h>
#import <AVFoundation/AVFoundation.h>

@implementation AppHelp

+ (void)jumpToSystemSetting {
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        
        NSURL *url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (BOOL)checkMediaAndAudioAuthStateWithParentViewController:(UIViewController *)parentVC;
{
    //检查相机权限
    AVAuthorizationStatus mediaAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    //检查麦克风权限
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (mediaAuthStatus != AVAuthorizationStatusAuthorized ||
        audioAuthStatus != AVAuthorizationStatusAuthorized) {
        
        UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"无法访问相机或麦克风" message:@"前往设置开启相机或麦克风权限？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [parentVC dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //跳转到应用设置
            [AppHelp jumpToSystemSetting];
        }];
        
        [alertViewController addAction:cancelAction];
        [alertViewController addAction:setAction];
        
        [parentVC presentViewController:alertViewController animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

@end
