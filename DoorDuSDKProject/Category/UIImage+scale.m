//
//  UIImage+scale.m
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/17.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import "UIImage+scale.h"

@implementation UIImage (scale)

+ (UIImage *)scaleImageToScale:(float)scale image:(UIImage *)image {
    
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    UIGraphicsBeginImageContext(CGSizeMake(w * scale, h * scale));
    [image drawInRect:CGRectMake(0, 0, w * scale, h * scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
