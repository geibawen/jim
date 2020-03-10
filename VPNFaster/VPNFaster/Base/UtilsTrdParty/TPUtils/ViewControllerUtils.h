//
//  ViewControllerUtils.h
//  TuyaSmart
//
//  Created by fengyu on 15/4/10.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewControllerUtils : NSObject

+ (void)gotoWebViewController:(NSString *)title url:(NSString *)url from:(UIViewController *)from;
+ (void)presentViewController:(UIViewController *)toController from:(UIViewController *)fromController;
+ (void)presentViewController:(UIViewController *)toController from:(UIViewController *)fromController withNavi:(BOOL)withNavi;
+ (void)pushViewController:(UIViewController *)toController from:(UIViewController *)fromController;


@end
