//
//  KeyboardButton.h
//  DoorDuShijie
//
//  Created by doordu-mac on 15/5/20.
//  Copyright (c) 2015年 DuanRuiying. All rights reserved.
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
