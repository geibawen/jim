//
//  UIViewController+AlertAnimation.h
//  FUNmoji
//
//  Created by Li,Guoqiang on 2018/12/17.
//  Copyright © 2018 Beijing Xiaoxiong Bowang Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 自定义Alert的通用弹出动画
 */
@interface UIViewController (AlertAnimation)

- (void)readyToAnimate:(UIView *)animateView;
- (void)presentAnimation;

@end

NS_ASSUME_NONNULL_END
