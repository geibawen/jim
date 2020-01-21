//
//  UIView+gesture.h
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2019/5/6.
//  Copyright © 2019年 sunjianbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (gesture)
- (void)setTapActionWithBlock:(void (^)(void))block;

- (void)setLongPressActionWithBlock:(void (^)(void))block;
@end
