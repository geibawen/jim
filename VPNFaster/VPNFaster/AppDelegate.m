//
//  AppDelegate.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/11.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "AppDelegate.h"
#import "TestViewController.h"
#import "MainViewController.h"
#import "TPNavigationController.h"
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>
#import <UserNotifications/UserNotifications.h>
#import <StoreKit/StoreKit.h>

#import "RRUser.h"
#import "YQInAppPurchaseTool.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate,SKPaymentTransactionObserver>

@property (nonatomic,strong) YQInAppPurchaseTool          *IAPTool;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [MobClick setAutoPageEnabled:YES];
    [UMConfigure setEncryptEnabled:YES];
    [UMConfigure setLogEnabled:YES];
    [UMConfigure initWithAppkey:@"5ce36c414ca357f80e00006e" channel:@"App Store"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    TPNavigationController *navigationController = [[TPNavigationController alloc] initWithRootViewController:[MainViewController new]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    navigationController.navigationBarHidden = YES;
    
    /* 注册苹果推送 */
    [application registerForRemoteNotifications];
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    
    if (@available(iOS 10.0, *)) {
        //iOS10需要加下面这段代码。
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNAuthorizationOptions types10 = UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
        [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
            } else {
                //点击不允许
            }
        }];
    }
    
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    _IAPTool = [YQInAppPurchaseTool defaultTool];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    
    NSString *pushId = [[[[deviceToken description]
                          stringByReplacingOccurrencesOfString:@" " withString:@""]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@"pushId is %@",pushId);
    
    [[RRUser sharedInstance] registerDevicePush:pushId success:^() {
        NSLog(@"registerDevicePush success");
    } failure:^(NSError *error) {
        NSLog(@"registerDevicePush failed");
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing: // 0
                NSLog(@"receied purchasing when start");
                break;
            case SKPaymentTransactionStatePurchased: // 1
                //订阅特殊处理
                if(transaction.originalTransaction){
                    //如果是自动续费的订单originalTransaction会有内容
                    NSLog(@"^^^^^^^^^original transaction:%@", transaction.originalTransaction.transactionIdentifier);
                    NSLog(@"^^^^^^^^^current transaction:%@",transaction.transactionIdentifier);
                    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
                    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
                    
                    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                    NSLog(@"got receipt when start app:%@", encodeStr);
                    [[RRUser sharedInstance] postBuyReceipt:encodeStr success:^(){
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        
                        // 通知Main UI刷新
                        NSNotification *notification =[NSNotification notificationWithName:NEED_REFRESH_USER_DATA object:nil userInfo:nil];
                        [[NSNotificationCenter defaultCenter] postNotification:notification];
                    } failure:^(NSError *error){
                        NSLog(@"check receip failed when start");
                    }];
                }else{
                    //普通购买，以及 第一次购买 自动订阅
                }
                break;
            case SKPaymentTransactionStateFailed: // 2
                NSLog(@"receied state failed when start");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored: // 3
                NSLog(@"receied restored when start");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                
                break;
        }
    }
}


@end
