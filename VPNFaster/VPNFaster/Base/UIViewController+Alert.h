//
//  UIViewController+Alert.h
//  FUNmoji
//
//  Created by Li,Guoqiang on 2018/12/4.
//  Copyright © 2018 Beijing Xiaoxiong Bowang Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Alert)

/**
 系统dialod
 
 @param title 标题
 @param message 子标题
 @param confirmTitle 确认按钮标题
 @param cancelTitle 取消按钮标题
 @param confirmAction 确认按钮点击回调
 @param cancelAction 取消按钮点击回调
 */

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle confirmAction:(void(^)(void))confirmAction cancelAction:(void(^)(void))cancelAction;

@end
