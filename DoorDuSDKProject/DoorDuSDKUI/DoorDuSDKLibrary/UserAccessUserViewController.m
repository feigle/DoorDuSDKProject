//
//  UserAccessUserViewController.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/19.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "UserAccessUserViewController.h"
#import "UserAccessUserChatViewController.h"
#import "KeyboardButton.h"

#import "DoorDuClient.h"

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
    
    //设置roomNumberLabel
    self.roomNumberLabel.text = @"";
    self.deleteButton.hidden = YES;
    
    //初始化键盘按钮
    [self initKeyboardButton];
}

#pragma mark -
#pragma mark (键盘按钮)
- (void)initKeyboardButton {
    
    self.keyButton_0.content = @"0";
    self.keyButton_0.normalImage = [UIImage imageNamed:@"FaceToFace_num0"];
    self.keyButton_0.highlightedImage = [UIImage imageNamed:@"FaceToFace_num0_on"];
    self.keyButton_0.keyboardButtonDelegate = self;
    
    self.keyButton_1.content = @"1";
    self.keyButton_1.normalImage = [UIImage imageNamed:@"FaceToFace_num1"];
    self.keyButton_1.highlightedImage = [UIImage imageNamed:@"FaceToFace_num1_on"];
    self.keyButton_1.keyboardButtonDelegate = self;
    
    self.keyButton_2.content = @"2";
    self.keyButton_2.normalImage = [UIImage imageNamed:@"FaceToFace_num2"];
    self.keyButton_2.highlightedImage = [UIImage imageNamed:@"FaceToFace_num2_on"];
    self.keyButton_2.keyboardButtonDelegate = self;
    
    self.keyButton_3.content = @"3";
    self.keyButton_3.normalImage = [UIImage imageNamed:@"FaceToFace_num3"];
    self.keyButton_3.highlightedImage = [UIImage imageNamed:@"FaceToFace_num3_on"];
    self.keyButton_3.keyboardButtonDelegate = self;
    
    self.keyButton_4.content = @"4";
    self.keyButton_4.normalImage = [UIImage imageNamed:@"FaceToFace_num4"];
    self.keyButton_4.highlightedImage = [UIImage imageNamed:@"FaceToFace_num4_on"];
    self.keyButton_4.keyboardButtonDelegate = self;
    
    self.keyButton_5.content = @"5";
    self.keyButton_5.normalImage = [UIImage imageNamed:@"FaceToFace_num5"];
    self.keyButton_5.highlightedImage = [UIImage imageNamed:@"FaceToFace_num5_on"];
    self.keyButton_5.keyboardButtonDelegate = self;
    
    self.keyButton_6.content = @"6";
    self.keyButton_6.normalImage = [UIImage imageNamed:@"FaceToFace_num6"];
    self.keyButton_6.highlightedImage = [UIImage imageNamed:@"FaceToFace_num6_on"];
    self.keyButton_6.keyboardButtonDelegate = self;
    
    self.keyButton_7.content = @"7";
    self.keyButton_7.normalImage = [UIImage imageNamed:@"FaceToFace_num7"];
    self.keyButton_7.highlightedImage = [UIImage imageNamed:@"FaceToFace_num7_on"];
    self.keyButton_7.keyboardButtonDelegate = self;
    
    self.keyButton_8.content = @"8";
    self.keyButton_8.normalImage = [UIImage imageNamed:@"FaceToFace_num8"];
    self.keyButton_8.highlightedImage = [UIImage imageNamed:@"FaceToFace_num8_on"];
    self.keyButton_8.keyboardButtonDelegate = self;
    
    self.keyButton_9.content = @"9";
    self.keyButton_9.normalImage = [UIImage imageNamed:@"FaceToFace_num9"];
    self.keyButton_9.highlightedImage = [UIImage imageNamed:@"FaceToFace_num9_on"];
    self.keyButton_9.keyboardButtonDelegate = self;
    
    self.keyButton_xin.content = @"*";
    self.keyButton_xin.normalImage = [UIImage imageNamed:@"FaceToFace_num*"];
    self.keyButton_xin.highlightedImage = [UIImage imageNamed:@"FaceToFace_num*_on"];
    self.keyButton_xin.keyboardButtonDelegate = self;
    
    self.keyButton_jin.content = @"#";
    self.keyButton_jin.normalImage = [UIImage imageNamed:@"FaceToFace_num#"];
    self.keyButton_jin.highlightedImage = [UIImage imageNamed:@"FaceToFace_num#_on"];
    self.keyButton_jin.keyboardButtonDelegate = self;
}

#pragma mark -
#pragma mark (调整键盘按钮布局)
- (void)layoutKeyboardButton {
    
    [self setControlLayout:self.keyButton_0];
    [self setControlLayout:self.keyButton_1];
    [self setControlLayout:self.keyButton_2];
    [self setControlLayout:self.keyButton_3];
    [self setControlLayout:self.keyButton_4];
    [self setControlLayout:self.keyButton_5];
    [self setControlLayout:self.keyButton_6];
    [self setControlLayout:self.keyButton_7];
    [self setControlLayout:self.keyButton_8];
    [self setControlLayout:self.keyButton_9];
    [self setControlLayout:self.keyButton_xin];
    [self setControlLayout:self.keyButton_jin];
    
    [self setControlLayout:self.startButton];
}

- (void)setControlLayout:(UIButton *)button {
    
    CGFloat w = 0.f;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IPHONE4_MODE) {
            w = width / 6.f;
            self.roomNumberLabel.font = [UIFont systemFontOfSize:21.f];
        }else {
            w = width / 5.f;
        }
    }else {
        w = width / 4.f;
    }
    
    NSLayoutConstraint *targetConstraint_w = nil;
    NSLayoutConstraint *targetConstraint_h = nil;
    NSArray *constraintsArray = button.constraints;
    for (NSLayoutConstraint *contraint in constraintsArray) {
        
        if ([contraint.firstItem isEqual:button]
            && (contraint.firstAttribute == NSLayoutAttributeWidth)
            && (contraint.relation == NSLayoutRelationEqual)) {
            targetConstraint_w = contraint;
            break;
        }
    }
    
    for (NSLayoutConstraint *contraint in constraintsArray) {
        if ([contraint.firstItem isEqual:button]
            && (contraint.firstAttribute == NSLayoutAttributeHeight)
            && (contraint.relation == NSLayoutRelationEqual)) {
            targetConstraint_h = contraint;
            break;
        }
    }
    
    targetConstraint_w.constant = w;
    targetConstraint_h.constant = w;
}

#pragma mark -
#pragma mark (KeyboardButtonDelegate)
- (void)keyboardButtonPressed:(NSString *)content {
    
    if (content && ![content isEqualToString:@""]) {
        NSString *pre = self.roomNumberLabel.text;
        NSString *current = [NSString stringWithFormat:@"%@%@", pre, content];
        self.roomNumberLabel.text = current;
    }
    
    if ([self.roomNumberLabel.text isEqualToString:@""]) {
        self.deleteButton.hidden = YES;
    }else {
        self.deleteButton.hidden = NO;
    }
}

#pragma mark -
#pragma mark (删除按钮动作)
- (IBAction)deleteButtonAction:(id)sender {
    
    NSString *pre = self.roomNumberLabel.text;
    NSString *cutted;
    if ([pre length] > 0) {
        cutted = [pre substringToIndex:([pre length] - 1)];
    }else {
        cutted = pre;
    }
    self.roomNumberLabel.text = cutted;
    if ([self.roomNumberLabel.text isEqualToString:@""]) {
        self.deleteButton.hidden = YES;
    }else {
        self.deleteButton.hidden = NO;
    }
}

#pragma mark -
#pragma mark (呼叫按钮动作)
- (IBAction)startButtonAction:(id)sender {
    
    //获取被叫房号
    NSString *toRoomNO = self.roomNumberLabel.text;
    NSString *temp = [toRoomNO stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!toRoomNO || [temp isEqualToString:@""]) {
        
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"被叫房号不能为空" message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        
        [alertView addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alertView animated:YES completion:nil];
        return;
    }
    
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    WeakSelf
    UIAlertAction *audioAction = [UIAlertAction actionWithTitle:@"语音呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //语音呼叫
        [weakSelf presentUserAccessUserChatViewController:kDoorDuMediaCallTypeAudio andRoomNO:temp];
    }];
    
    UIAlertAction *videoAction = [UIAlertAction actionWithTitle:@"视频呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //视频呼叫
        [weakSelf presentUserAccessUserChatViewController:kDoorDuMediaCallTypeVideo andRoomNO:temp];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertView addAction:audioAction];
    [alertView addAction:videoAction];
    [alertView addAction:cancelAction];
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)presentUserAccessUserChatViewController:(DoorDuMediaCallType)type andRoomNO:(NSString *)roomNo
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserAccessUserChatViewController *userAccessUserVC = [sb instantiateViewControllerWithIdentifier:@"UserAccessUserChatID"];
    
    userAccessUserVC.type = type;
    userAccessUserVC.toRoomNO = roomNo;
    
    userAccessUserVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    userAccessUserVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:userAccessUserVC animated:YES completion:nil];
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
