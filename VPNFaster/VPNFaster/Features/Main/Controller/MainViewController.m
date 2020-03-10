//
//  UserViewController.m
//  TuyaSmart
//
//  Created by fengyu on 15/2/28.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

@import NetworkExtension;

#import "MainViewController.h"

#import "VPNHelper.h"
#import "RRUser.h"
#import "ServerModel.h"
#import "ProductModel.h"

#import "TPItemView.h"
#import "MainView.h"
#import "UserItemTableViewCell.h"
#import "SeparatorTableViewCell.h"

#import "FVPersonalViewController.h"
#import "FVBuyVipViewController.h"
#import "FVChooseServerViewController.h"
#import "FVShareViewController.h"
#import "FVPolicyViewController.h"

#import <Social/Social.h>


#define UserItemTableViewCellIdentifier  @"UserItemTableViewCellIdentifier"
#define SeparatorTableViewCellIdentifier @"SeparatorTableViewCellIdentifier"

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate,TPItemViewDelegate,MainViewDelegate,FVChooseServerViewControllerDelegate,FVPolicyViewControllerDelegate>

@property (nonatomic,strong) NSArray              *dataSource;
@property (nonatomic,strong) MainView             *mainView;

@property (nonatomic,assign) bool                 notFirstTimeConnect;

@property (nonatomic,assign) bool                 running;

@property (nonatomic,assign) bool                 needReconnect;

@property (nonatomic,assign) double               connectAnimationStartTime;
@property (nonatomic,assign) double               disconnectAnimationStartTime;

@end

@implementation MainViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:NEVPNConfigurationChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStatusChanged) name:NEVPNStatusDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserData) name:NEED_REFRESH_USER_DATA object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEVPNConfigurationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEVPNStatusDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEED_REFRESH_USER_DATA object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self getTotalInfo];
    [self getCurrentVpnStatus];
}

- (void) getTotalInfo{
    if ([RRUser sharedInstance].isLogin == YES) {
        // 先加载缓存
        [self initDataSource];
        [self reloadData];

        // 再加载网络
        [self forceGetTotalInfo];
    } else {
        [self showPolicyAlert];
    }
}

- (void) getUserPlan{
    // 只在已登录情况下执行
    if ([RRUser sharedInstance].isLogin == YES){
        [[RRUser sharedInstance] getUserPlan:^() {
            [self initDataSource];
            [self reloadData];
        } failure:^(NSError *error) {
        }];
    }
}

- (void)reloadData {
    [_mainView.settingTableView reloadData];
}

- (void)viewDidAppearNotAtFirstTime:(BOOL)animated {
    [super viewWillAppear:animated];

    // 每次进入当前页面就刷新一下用户的VIP信息
    [self getUserPlan];
}

- (void)initView {
    [self initMainView];
}

- (void)refreshUserData {
    [self initDataSource];
    [self reloadData];
}

- (void)appWillEnterForegroundNotification {
    // 按Home切换出去后回来
    [self getUserPlan];
}

- (void)getCurrentVpnStatus {
    VPNHelper *helper = [VPNHelper sharedInstance];
    [helper getStatus:^(NEVPNStatus status) {
        if (status == NEVPNStatusConnected) {
            self.mainView.circularView.duration = 0;
            self.mainView.circularView.progress = 1.0;
            self.mainView.buttonStatus = ButtonStatusConnected;
        } else if (status == NEVPNStatusConnected) {
            self.mainView.circularView.duration = 0;
            self.mainView.circularView.progress = 0;
            self.mainView.buttonStatus = ButtonStatusInitial;
        }
    }];
}

- (void)initDataSource {
    RRUser *user = [RRUser sharedInstance];
    
    MenuItem *chooseServerItem = [MenuItem normalItem:[UIImage imageNamed:@"index_icon_jiedian"] title:NSLocalizedString(@"menu_change_server", nil) action:@selector(gotoChooseVPNServer) showRightArrow:YES];
    chooseServerItem.height = 65;
    ServerModel *selectedServer = [self getSelectedServer:user.selectedServerId];
    if (selectedServer != nil) {
        chooseServerItem.subTitle = selectedServer.name;
        chooseServerItem.iconRightUrl = selectedServer.icon;
    } else {
        ServerModel *findServer = [self findOneFreeServer];
        if (findServer != nil) {
            chooseServerItem.subTitle = findServer.name;
            chooseServerItem.iconRightUrl = findServer.icon;
        }
    }

    MenuItem *buyVipItem = [MenuItem normalItem:[UIImage imageNamed:@"index_icon_vip"] title:NSLocalizedString(@"menu_buy_vip", nil) action:@selector(gotoBuy) showRightArrow:YES];
    buyVipItem.height = 65;
    
    NSString *lowerGroup = [user.userGroup lowercaseString];
    if ([lowerGroup isEqualToString:@"trail"]) {
        buyVipItem.subTitle = NSLocalizedString(@"menu_vip_trail_title", nil);
        NSString *timestapString = [NSString stringWithFormat:@"%ld", (long)user.expireDate/1000];
        NSString *expiredDateString = [TPDate time2String:timestapString format:@"MM-dd HH:mm"];
        buyVipItem.rightTitle = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"menu_vip_expire_time", nil), expiredDateString];
    } else if ([lowerGroup isEqualToString:@"normal"]) {
        buyVipItem.subTitle = NSLocalizedString(@"menu_vip_normal_title", nil);
        buyVipItem.rightTitle = [NSString stringWithFormat:@"%@: %ldM", NSLocalizedString(@"menu_vip_expire_m", nil), (user.limit - user.used)];
    }

    MenuItem *meItem = [MenuItem normalItem:[UIImage imageNamed:@"index_icon_mine"] title:NSLocalizedString(@"menu_me", nil) action:@selector(gotoPersonalViewController) showRightArrow:YES];
    meItem.height = 65;
    if (user.userName && user.password) {
        meItem.rightTitle = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"menu_person_username", nil), [[RRUser sharedInstance] userName]];
        meItem.rightSubTitle = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"menu_person_password", nil), [[RRUser sharedInstance] password]];
    }
    
    MenuItem *shareItem = [MenuItem normalItem:[UIImage imageNamed:@"index_icon_share"] title:NSLocalizedString(@"menu_share", nil) action:@selector(gotoShare) showRightArrow:YES];
    NSArray *iconArray = @[@"share_appicon_whatsapp", @"share_appicon_messenger", @"share_appicon_facebook"];
    shareItem.iconRightArray = [NSArray arrayWithArray:iconArray];
    shareItem.height = 65;
    
    NSMutableArray *list = [NSMutableArray new];
    [list addObject:chooseServerItem];
    if (user.subscribedItem != nil && ![user.subscribedItem isKindOfClass:[NSNull class]] && ![user.subscribedItem isEqualToString:@""]) {
        //已购买vip不再显示购买vip条目
    } else {
        [list addObject:buyVipItem];
    }
    [list addObject:meItem];
    [list addObject:shareItem];
//    [list addObject:[MenuItem separatorItem:10]];
    
    _dataSource = [NSArray arrayWithArray:list];
}

- (void)initMainView {
    _mainView = [[MainView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT)];
    [_mainView.settingTableView registerClass:[UserItemTableViewCell class] forCellReuseIdentifier:UserItemTableViewCellIdentifier];
    [_mainView.settingTableView registerClass:[SeparatorTableViewCell class] forCellReuseIdentifier:SeparatorTableViewCellIdentifier];
    _mainView.settingTableView.dataSource = self;
    _mainView.settingTableView.delegate = self;
    
    _mainView.delegate = self;
    
    [self.view addSubview:_mainView];
}

- (ServerModel *)getSelectedServer:(NSInteger)serverId {
    RRUser *user = [RRUser sharedInstance];
    if (user.servers && user.servers.count != 0) {
        for (ServerModel *server in user.servers) {
            if (server.serverId == serverId) {
                if ([[user.userGroup lowercaseString] isEqualToString:@"normal"] && server.vip == YES) { //Normal用户清楚掉已选vip节点
                    user.selectedServerId = 0;
                    [user save];
                    return nil;
                }
                return server;
            }
        }
        return nil;
    }
    return nil;
}

- (ServerModel *)findOneFreeServer {
    RRUser *user = [RRUser sharedInstance];
    if (user.servers && user.servers.count != 0) {
        for (ServerModel *server in user.servers) {
            if (server.vip != YES) {
                user.selectedServerId = server.serverId;
                [user save];
                return server;
            }
        }
        return nil;
    }
    return nil;
}

- (void)gotoChooseVPNServer {
    NSLog(@"choose");
    FVChooseServerViewController *vc = [FVChooseServerViewController new];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoBuy {
    NSLog(@"choose1");
    FVBuyVipViewController *vc = [FVBuyVipViewController new];
    TPNavigationController *navi = [[TPNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)gotoPersonalViewController {
    NSLog(@"choose2");
    FVPersonalViewController *vc = [FVPersonalViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoShare {
    NSLog(@"choose3");
    [FVShareViewController showAlertFromViewController:self];
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error_occur", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self gotoBuy];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) getConnectPassword{
    [[RRUser sharedInstance] getConnectPassword:^() {
        NSLog(@"user connect password:%@", [RRUser sharedInstance].connectPassword);
        NSLog(@"user connect password:%@", [RRUser sharedInstance].userName);
        
        [self connect];
    } failure:^(NSError *error) {
        self.running = NO;
        self.mainView.circularView.progress = 0;
        self.mainView.buttonStatus = ButtonStatusInitial;
        if (error.code == 7001) {
            [self showConnectFailedAlertWithMessage:NSLocalizedString(@"alert_no_transfer", nil)];
        } else if (error.code == 5025) {
            [self showConnectFailedAlertWithMessage:NSLocalizedString(@"alert_vip_server", nil)];
        } else {
            [self showConnectFailedAlert];
            [self getTotalInfo];
        }
    }];
}

- (void)connect {
//    [self.mainView startAnimation];
    self.mainView.circularView.duration = 6.33;
    self.mainView.circularView.progress = 0.75;
    self.connectAnimationStartTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.mainView.buttonStatus = ButtonStatusConnecting;
    VPNHelper *helper = [VPNHelper sharedInstance];
    
    NSInteger serverId = [RRUser sharedInstance].selectedServerId;
    ServerModel *serverModel = [[RRUser sharedInstance] getServerById:serverId];
    NSString *ip = serverModel.host;
    NSString *psk = serverModel.psk;
    NSString *userName = [RRUser sharedInstance].userName;
    NSString *password = [RRUser sharedInstance].connectPassword;
    [helper createPreferenceWithIp:ip psk:psk account:userName password:password completion:^(NSError *error) {
        if (error) {
            self.running = NO;
            self.mainView.circularView.progress = 0;
            self.mainView.buttonStatus = ButtonStatusInitial;
            [self showConnectFailedAlert];
        } else {
            [helper connect:^(NSError *error) {
                if (error) {
                    self.running = NO;
                    self.mainView.circularView.progress = 0;
                    self.mainView.buttonStatus = ButtonStatusInitial;
                    [self showConnectFailedAlert];
                }
            }];
        }
    }];
}

- (void)disconnect {
    VPNHelper *helper = [VPNHelper sharedInstance];
    [helper disconnect];
    self.mainView.circularView.duration = 3.33;
    self.mainView.circularView.progress = 0.25;
    self.disconnectAnimationStartTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.mainView.buttonStatus = ButtonStatusDisconnecting;
}

- (void)connectionStatusChanged {
    NSLog(@"connection status did changed");
    if (!self.notFirstTimeConnect) {
        self.notFirstTimeConnect = YES;
        NSLog(@"connection status did changed, it's first time connect ignore it:%ld", (long)[VPNHelper sharedInstance].manager.connection.status);
        return;
    }
    
    VPNHelper *helper = [VPNHelper sharedInstance];
    switch (helper.manager.connection.status) {
        case NEVPNStatusConnected:
            self.needReconnect = NO;
            if (YES) {
                [NSObject bk_performBlock:^(){
                    self.running = NO;
                    self.mainView.buttonStatus = ButtonStatusConnected;
                } afterDelay:0.5];
            }
            double now = [[NSDate date] timeIntervalSince1970] * 1000;
            double timePassed = now - self.connectAnimationStartTime;
            float currProgress = timePassed / 3300;
            if (currProgress > 0.75) {
                currProgress = 0.75;
            }
            self.mainView.circularView.duration = 0.01;
            self.mainView.circularView.progress = currProgress;
            if (YES) {
                [NSObject bk_performBlock:^(){
                    self.mainView.circularView.duration = 0.5;
                    self.mainView.circularView.progress = 1.0;
                } afterDelay:0.01];
            }
            NSLog(@"connection status did changed: connected");
            break;
        case NEVPNStatusDisconnected:
            if (YES) {
                [NSObject bk_performBlock:^(){
                    self.running = NO;
                    self.mainView.buttonStatus = ButtonStatusInitial;
                    if (self.needReconnect == YES) {
                        self.running = YES;
                        [self getConnectPassword];
                    }
                } afterDelay:0.55];
            }
            double now1 = [[NSDate date] timeIntervalSince1970] * 1000;
            double timePassed1 = now1 - self.disconnectAnimationStartTime;
            float currProgress1 = timePassed1 / 3300;
            if (currProgress1 > 0.75) {
                currProgress1 = 0.75;
            }
            self.mainView.circularView.duration = 0.01;
            self.mainView.circularView.progress = 1 - currProgress1;
            if (YES) {
                [NSObject bk_performBlock:^(){
                    self.mainView.circularView.duration = 0.5;
                    self.mainView.circularView.progress = 0;
                } afterDelay:0.01];
            }
            NSLog(@"connection status did changed: disconnected");
            break;
        case NEVPNStatusInvalid:
            self.running = NO;
            self.mainView.circularView.progress = 0;
            self.mainView.buttonStatus = ButtonStatusInitial;
            NSLog(@"connection status did changed: invalid");
            break;
        case NEVPNStatusConnecting:
            self.mainView.buttonStatus = ButtonStatusConnecting;
            NSLog(@"connection status did changed: connecting");
            break;
        case NEVPNStatusDisconnecting:
            self.mainView.buttonStatus = ButtonStatusDisconnecting;
            self.mainView.circularView.duration = 0.36;
            self.mainView.circularView.progress = 0.25;
            NSLog(@"connection status did changed: disconnecting");
            break;
        default:
            NSLog(@"connection status did changed: unknown");
            break;
    }
}

-(void)showPolicyAlert{
    FVPolicyViewController *alertVC = [[FVPolicyViewController alloc] init];
    alertVC.delegate = self;
    alertVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alertVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark TPItemViewDelegate

- (void)itemViewTap:(TPItemView *)itemView {
    
    MenuItem *item = [_dataSource objectAtIndex:itemView.tag];
    
    SEL action = item.action;
    if ([self respondsToSelector:action]) {
        
        ((void (*)(id, SEL))[self methodForSelector:action])(self, action);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"tableview count is %lu", (unsigned long)_dataSource.count);
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItem *item = [self dataForIndexPath:indexPath];
    if (item.type == MenuItemTypeSeparator) {
        SeparatorTableViewCell *separatorCell = [tableView dequeueReusableCellWithIdentifier:SeparatorTableViewCellIdentifier forIndexPath:indexPath];
        return separatorCell;
    } else {
//        UserItemTableViewCell *userItemCell = [tableView dequeueReusableCellWithIdentifier:UserItemTableViewCellIdentifier forIndexPath:indexPath];
        UserItemTableViewCell *userItemCell = [tableView cellForRowAtIndexPath:indexPath];
        if (!userItemCell) {
            userItemCell = [[UserItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserItemTableViewCellIdentifier];
        }
        userItemCell.itemView.tag = indexPath.row;
        userItemCell.itemView.delegate = self;
        [userItemCell setUp:item];
        
        return userItemCell;
    }
}

- (void) forceGetTotalInfo{
    [self showProgressView];
    [[RRUser sharedInstance] getTotalInfo:nil password:nil success:^() {
        [self initDataSource];
        [self reloadData];
        
        [self hideProgressView];
    } failure:^(NSError *error) {
        [self hideProgressView];
        [self showAlertAndExit];
    }];
}

- (void)showAlertAndExit {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"network_issue_title", nil) message:NSLocalizedString(@"network_issue_message", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"quit", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [RRUtilCommon exitApplication];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"retry", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self forceGetTotalInfo];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItem *item = [self dataForIndexPath:indexPath];
    return item.height;
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource objectAtIndex:indexPath.row];
}

#pragma mark - MainViewDelegate

- (void)mainViewConnectButtonTap:(nonnull MainView *)mainView {
    
    if (self.running == YES) {
        return;
    } else {
        self.running = YES;
    }
    if (self.mainView.buttonStatus == ButtonStatusInitial) {
        [self getConnectPassword];
    } else if (self.mainView.buttonStatus == ButtonStatusConnected) {
        [self disconnect];
    }
}

#pragma mark - FVPolicyViewControllerDelegate
- (void)onRejectButtonTap{
    [RRUtilCommon exitApplication];
}

- (void)onAgreeButtonTap{
    // 这是首次安装后打开app，数据如果拉取不成功，要么退出app，要么一直拉
    [self forceGetTotalInfo];
}

#pragma mark - FVChooseServerViewControllerDelegate

- (void)chooseServerViewControllerItemTap:(nonnull FVChooseServerViewController *)chooseServer serverId:(NSInteger)serverId {
    RRUser *user = [RRUser sharedInstance];
    user.selectedServerId = serverId;
    [user save];
    [self initDataSource];
    [self reloadData];
    
    VPNHelper *helper = [VPNHelper sharedInstance];
    if (helper.manager.connection.status == NEVPNStatusConnected) {
        self.running = YES;
        self.needReconnect = YES;
        [self disconnect];
    }
}

@end
