//
//  UIViewController+Alert.m
//  FUNmoji
//
//  Created by Li,Guoqiang on 2018/12/4.
//  Copyright © 2018 Beijing Xiaoxiong Bowang Technology Co., Ltd. All rights reserved.
//

#import "UIViewController+Alert.h"

#define SAFE_BLOCK(block, ...) block ? block(__VA_ARGS__) : nil

@implementation UIViewController (Alert)

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle confirmAction:(void(^)(void))confirmAction cancelAction:(void(^)(void))cancelAction {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelTitle != nil) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            SAFE_BLOCK(cancelAction);
        }];
        [alertVC addAction:cancel];
    }
    if (confirmTitle != nil) {
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SAFE_BLOCK(confirmAction);
        }];
        [alertVC addAction:confirm];
    }
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
