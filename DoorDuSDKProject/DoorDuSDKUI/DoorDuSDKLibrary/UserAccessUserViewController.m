//
//  UserAccessUserViewController.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/19.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "UserAccessUserViewController.h"
#import "KeyboardButton.h"

@interface UserAccessUserViewController ()

@property (weak, nonatomic, readwrite) IBOutlet UILabel *roomNumberLabel;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic, readwrite) IBOutlet UIButton *startButton;

@property (weak, nonatomic, readwrite) IBOutlet UIView *layoutView;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_1;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_2;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_3;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_4;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_5;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_6;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_7;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_8;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_9;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_xin;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_0;
@property (weak, nonatomic, readwrite) IBOutlet KeyboardButton *keyButton_jin;

@end

@implementation UserAccessUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"户户通";
    self.navigationItem.leftBarButtonItem = [];
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
