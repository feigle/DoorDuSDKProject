//
//  BaseViewController.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/13.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "BaseViewController.h"
#import "YYModel.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)showWithTitle:(NSString *)title
{
    [SVProgressHUD showWithStatus:title maskType:SVProgressHUDMaskTypeClear];
}

- (void)showSuccessWithTitle:(NSString *)title
{
    [SVProgressHUD showSuccessWithStatus:title];
}

- (void)showErrWithTitle:(NSString *)title
{
    [SVProgressHUD showErrorWithStatus:title];
}

- (void)show
{
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)dismiss
{
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
