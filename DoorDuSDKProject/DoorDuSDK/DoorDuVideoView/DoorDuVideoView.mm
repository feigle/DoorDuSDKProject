//
//  DoorDuVideoView.m
//  DoorDuSDK
//
//  Created by Doordu on 2017/3/29.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "DoorDuVideoView.h"
#import <SipEngineSDK/RTCEAGLVideoView.h>

#pragma mark - 视频通话渲染控件
@implementation DoorDuVideoView

#pragma mark -
#pragma mark (重新布局self的subviews)
- (void)layoutSubviews {
    [super layoutSubviews];
    /*
    NSEnumerator *subviewsArray = [self.subviews objectEnumerator];
    UIView *subview;
    while (subview = [subviewsArray nextObject]) {
        
        if ([subview isKindOfClass:[RTCEAGLVideoView class]]) {
            
            CGRect rect = CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height);
            subview.frame = rect;
            [subview layoutIfNeeded];
        }
    }*/
}

@end
