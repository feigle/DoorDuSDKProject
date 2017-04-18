//
//  BaseViewController.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/13.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

@interface BaseViewController : UIViewController

/**
 显示加载框
 */
- (void)show;

- (void)showWithTitle:(NSString *)title;

- (void)showSuccessWithTitle:(NSString *)title;

- (void)showErrWithTitle:(NSString *)title;

/**
 隐藏加载框
 */
- (void)dismiss;

@end
