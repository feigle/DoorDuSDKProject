//
//  KeyboardButton.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/14.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "KeyboardButton.h"

@implementation KeyboardButton

@synthesize content = _content;
@synthesize normalImage = _normalImage;
@synthesize highlightedImage = _highlightedImage;

#pragma mark -
#pragma mark (重载基类)
- (void)awakeFromNib {
    [super awakeFromNib];
    //重载按钮点击事件
    [self addTarget:self action:@selector(press) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    
    self.content = nil;
    self.normalImage = nil;
    self.highlightedImage = nil;
    
    //重载按钮点击事件
    [self removeTarget:self action:@selector(press) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
#pragma mark (重载content)
- (NSString *)content {
    
    return _content;
}

- (void)setContent:(NSString *)content {
    
    _content = content;
}

#pragma mark -
#pragma mark (重载normalImage)
- (UIImage *)normalImage {
    
    return _normalImage;
}

- (void)setNormalImage:(UIImage *)normalImage {
    
    _normalImage = normalImage;
    
    [self setBackgroundImage:_normalImage forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark (重载highlightedImage)
- (UIImage *)highlightedImage {
    
    return _normalImage;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    
    _highlightedImage = highlightedImage;
    
    [self setBackgroundImage:_highlightedImage forState:UIControlStateHighlighted];
}

#pragma mark -
#pragma mark (重载按钮点击事件)
- (void)press {
    
    if (self.content && ![self.content isEqualToString:@""]) {
        
        [self.keyboardButtonDelegate keyboardButtonPressed:self.content];
    }
}

@end
