//
//  KeyboardButton.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/14.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KeyboardButtonDelegate;

/***KeyboardButton***/
@interface KeyboardButton : UIButton {
    
    NSString *_content;
    UIImage *_normalImage;
    UIImage *_highlightedImage;
}
@property (strong, nonatomic, readwrite) NSString *content;
@property (strong, nonatomic, readwrite) UIImage *normalImage;
@property (strong, nonatomic, readwrite) UIImage *highlightedImage;

@property (weak, nonatomic, readwrite) id <KeyboardButtonDelegate> keyboardButtonDelegate;

@end

/***KeyboardButtonDelegate***/
@protocol KeyboardButtonDelegate <NSObject>

- (void)keyboardButtonPressed:(NSString *)content;

@end
