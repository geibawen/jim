//
//  UserViewController.m
//  TuyaSmart
//
//  Created by fengyu on 15/2/28.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

@import NetworkExtension;

#import "MainViewController.h"
#import "MainView.h"
#import "MapDetailViewController.h"

@interface MainViewController ()<MainViewDelegate>

@property (nonatomic,strong) MainView             *mainView;


@end

@implementation MainViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];

}

- (void)initView {
    _mainView = [[MainView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT)];
    
    _mainView.delegate = self;
    
    [self.view addSubview:_mainView];
}

- (void)appWillEnterForegroundNotification {
}

- (void)gotoChooseVPNServer {
//    FVChooseServerViewController *vc = [FVChooseServerViewController new];
//    vc.delegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)showConnectFailedAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"network_issue_title", nil) message:NSLocalizedString(@"network_issue_message", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showConnectFailedAlertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - MainViewDelegate

- (void)mainViewConnectButtonTap:(nonnull MainView *)mainView {
    
}

@end
