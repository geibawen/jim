//
//  UIScrollView+UITouch.m
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2019/5/9.
//  Copyright © 2019年 sunjianbin. All rights reserved.
//

#import "UIScrollView+UITouch.h"

@implementation UIScrollView (UITouch)

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 选其一即可
    [super touchesBegan:touches withEvent:event];
    //    [[self nextResponder] touchesBegan:touches withEvent:event];
}

@end
