//
//  UIViewController+AlertAnimation.m
//  FUNmoji
//
//  Created by Li,Guoqiang on 2018/12/17.
//  Copyright © 2018 Beijing Xiaoxiong Bowang Technology Co., Ltd. All rights reserved.
//

#import "UIViewController+AlertAnimation.h"
#import <objc/runtime.h>

static void *kAnimateViewKey = &kAnimateViewKey;

@interface UIViewController (AlertAnimationInternal)

@property (nonatomic, strong) UIView *animateView;

@end

@implementation UIViewController (AlertAnimation)

- (void)setAnimateView:(UIView *)animateView {
    objc_setAssociatedObject(self, kAnimateViewKey, animateView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)animateView {
    return objc_getAssociatedObject(self, kAnimateViewKey);
}

- (void)readyToAnimate:(UIView *)animateView {
    self.animateView = animateView;
    self.animateView.hidden = YES;
}

- (void)presentAnimation {
    if (self.animateView == nil) {
        return;
    }
    self.animateView.hidden = NO;
    [self addAlertAnima];
}

- (void)dismissAnimation {
    if (self.animateView == nil) {
        return;
    }
}


#pragma mark - animation

#define kAlertViewScalefault 1.0
#define kAlertViewScaleSmaller 0.9
#define kAlertViewScaleBigger 1.1
#define kAlertViewKeyTimesPointFirst 0.5
#define kAlertViewKeyTimesPointSecond 0.8
#define kAlertViewDurationTotal 0.5

static NSString * const kAlertAnimaKey = @"kAlertAnimaKey";

- (void)addAlertAnima {
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CAKeyframeAnimation *alertAnima = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    alertAnima.values = @[@(0),
                         @(kAlertViewScaleBigger),
                         @(kAlertViewScaleSmaller),
                         @(kAlertViewScalefault)
                         ];
    alertAnima.keyTimes = @[@(0.0), @(kAlertViewKeyTimesPointFirst), @(kAlertViewKeyTimesPointSecond), @1.0];
    
    //add timing function
    CAMediaTimingFunction *fn0 = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    CAMediaTimingFunction *fn1 = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    CAMediaTimingFunction *fn2 = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    alertAnima.timingFunctions = @[fn0, fn1, fn2];
    alertAnima.duration = kAlertViewDurationTotal;
    alertAnima.repeatCount = 1;
//    alertAnima.delegate = self;

    [CATransaction commit];
    
    [self.animateView.layer addAnimation:alertAnima forKey:kAlertAnimaKey];
}

@end
