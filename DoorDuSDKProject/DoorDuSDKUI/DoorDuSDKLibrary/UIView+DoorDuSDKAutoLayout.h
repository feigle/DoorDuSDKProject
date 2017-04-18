//
//  UIView+DoorDuSDKAutoLayout.h
//  DoorDuSDKProject
//
//  Created by Doordu on 2017/4/13.
//  Copyright © 2017年 深圳市多度科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DoorDuSDKAutoLayout)
// height
- (NSLayoutConstraint *)constraintHeight:(CGFloat)height;
- (NSLayoutConstraint *)constraintHeightEqualToView:(UIView *)view;

// width
- (NSLayoutConstraint *)constraintWidth:(CGFloat)width;
- (NSLayoutConstraint *)constraintWidthEqualToView:(UIView *)view;

// center
- (NSLayoutConstraint *)constraintCenterXEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintCenterYEqualToView:(UIView *)view;

// top, bottom, left, right
- (NSArray *)constraintsTop:(CGFloat)top FromView:(UIView *)view;
- (NSArray *)constraintsBottom:(CGFloat)bottom FromView:(UIView *)view;
- (NSArray *)constraintsLeft:(CGFloat)left FromView:(UIView *)view;
- (NSArray *)constraintsRight:(CGFloat)right FromView:(UIView *)view;

- (NSArray *)constraintsTopInContainer:(CGFloat)top;
- (NSArray *)constraintsBottomInContainer:(CGFloat)bottom;
- (NSArray *)constraintsLeftInContainer:(CGFloat)left;
- (NSArray *)constraintsRightInContainer:(CGFloat)right;

- (NSLayoutConstraint *)constraintTopEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintBottomEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintLeftEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintRightEqualToView:(UIView *)view;

// size
- (NSArray *)constraintsSize:(CGSize)size;
- (NSArray *)constraintsSizeEqualToView:(UIView *)view;

// imbue
- (NSArray *)constraintsFillWidth;
- (NSArray *)constraintsFillHeight;
- (NSArray *)constraintsFill;

// assign
- (NSArray *)constraintsAssignLeft;
- (NSArray *)constraintsAssignRight;
- (NSArray *)constraintsAssignTop;
- (NSArray *)constraintsAssignBottom;

@end
/**
 [self.view addConstraint:[self.tableView constraintCenterXEqualToView:self.view]];
 [self.view addConstraint:[self.tableView constraintWidthEqualToView:self.view]];
 
 [self.view addConstraints:[self.nextStepButton constraintsSize:CGSizeMake(300.0f, 40.0f)]];
 [self.view addConstraint:[self.nextStepButton constraintCenterXEqualToView:self.view]];
 */
