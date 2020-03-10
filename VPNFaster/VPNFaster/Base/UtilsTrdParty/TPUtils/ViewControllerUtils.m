//
//  ViewControllerUtils.m
//  TuyaSmart
//
//  Created by fengyu on 15/4/10.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

#import "ViewControllerUtils.h"
#import "TPWebViewController.h"
#import "TPNavigationController.h"

@implementation ViewControllerUtils

+ (void)gotoWebViewController:(NSString *)title url:(NSString *)url from:(UIViewController *)from {
    TPWebViewController *webViewController = [[TPWebViewController alloc] initWithUrlString:url];
    webViewController.title = title;
    [self pushViewController:webViewController from:from];
}

+ (void)presentViewController:(UIViewController *)toController from:(UIViewController *)fromController {
    if (fromController == nil) {
        fromController = tp_topMostViewController();
    }
    
    TPNavigationController *navigationController = [[TPNavigationController alloc] initWithRootViewController:toController];
    [fromController presentViewController:navigationController animated:YES completion:nil];
}

+ (void)presentViewController:(UIViewController *)toController from:(UIViewController *)fromController withNavi:(BOOL)withNavi {
    if (fromController == nil) {
        fromController = tp_topMostViewController();
    }
    
    TPNavigationController *navigationController = [[TPNavigationController alloc] initWithRootViewController:toController];
    [fromController presentViewController:(withNavi == YES ? navigationController : toController) animated:YES completion:nil];
}


+ (void)pushViewController:(UIViewController *)toController from:(UIViewController *)fromController {
    if (fromController == nil) {
        fromController = tp_topMostViewController();
    }
    
    [fromController.navigationController pushViewController:toController animated:YES];
}

@end
