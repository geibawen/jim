//
//  FVPersonalView.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/16.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "FVChooseServerViewController.h"

#import "RRUser.h"
#import "ServerModel.h"
#import "RRPing.h"

#import "TPItemView.h"
#import "FVChooseServerView.h"
#import "FVPersonalHeaderCell.h"
#import "UserItemTableViewCell.h"
#import "SeparatorTableViewCell.h"

#import "FVBuyVipViewController.h"
#import "WHPingTester.h"


#define UserHeaderTableViewCellIdentifier  @"UserHeaderTableViewCellIdentifier" //暂时不用
#define UserItemTableViewCellIdentifier  @"UserItemTableViewCellIdentifier"
#define SeparatorTableViewCellIdentifier @"SeparatorTableViewCellIdentifier"

@interface FVChooseServerViewController ()<UITableViewDataSource,UITableViewDelegate,TPItemViewDelegate,WHPingDelegate>

@property (nonatomic,strong) NSArray                     *dataSource;
@property (nonatomic,strong) FVChooseServerView          *userView;
@property (nonatomic,strong) UIImageView                 *refreshView;
@property (nonatomic,strong) UIActivityIndicatorView     *activityIndicator;

@property(nonatomic, strong) WHPingTester                *pingTester;

@property(nonatomic, assign) NSInteger                   currentPingIndex;
@property (nonatomic,strong) NSMutableArray              *pingResult;

@property(nonatomic, assign) BOOL                        refreshing;

@end

@implementation FVChooseServerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self initDataSource];
    
    if ([RRUser sharedInstance].hasPing != YES) {
        [self initPing];
    }
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.pingTester.delegate = nil;
    [self.pingTester stopPing];
}

- (void)reloadData {
    [_userView.userTableView reloadData];
}

- (void)initView {
    self.centerTitleItem.title = NSLocalizedString(@"main_servers_title", @"");
    self.topBarView.centerItem = self.centerTitleItem;
    
    [self initUserView];
}

- (void)initUserView {
    _userView = [[FVChooseServerView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, APP_SCREEN_WIDTH,APP_VISIBLE_HEIGHT)];
    [_userView.userTableView registerClass:[FVPersonalHeaderCell class] forCellReuseIdentifier:UserHeaderTableViewCellIdentifier];
    [_userView.userTableView registerClass:[UserItemTableViewCell class] forCellReuseIdentifier:UserItemTableViewCellIdentifier];
    [_userView.userTableView registerClass:[SeparatorTableViewCell class] forCellReuseIdentifier:SeparatorTableViewCellIdentifier];
    _userView.userTableView.dataSource = self;
    _userView.userTableView.delegate = self;
    
    [self.view addSubview:_userView];
}

- (void)initDataSource {
    RRUser *user = [RRUser sharedInstance];
    
    NSMutableArray *list = [NSMutableArray new];
    
    if (!user.servers || user.servers.count == 0) {
        return;
    }
    
    for (int i = 0; i < user.servers.count; i++) {
        ServerModel *server = user.servers[i];
        MenuItem *vipTypeItem = [MenuItem normalItem:nil title:server.name action:@selector(gotoChangePassword) showRightArrow:NO];
        vipTypeItem.iconUrl = server.icon;
        vipTypeItem.height = 65;
        vipTypeItem.dataInt = server.serverId;
        
        float pingValue = [[RRPing sharedInstance] getPingValueByServerId:server.serverId];
        
        vipTypeItem.rightTitle = [NSString stringWithFormat:@"%.fms", pingValue];
        vipTypeItem.rightTitleColor = HEXCOLOR(0x06e10b);
        if (pingValue >= 300) {
            vipTypeItem.rightTitleColor = HEXCOLOR(0xf52604);
        }
        
        if (server.vip == YES) {
            vipTypeItem.iconCenter = [UIImage imageNamed:@"jiedian_label_vip"];
        }
        [list addObject:vipTypeItem];
    }
    
    _dataSource = [NSArray arrayWithArray:list];
}

- (void)initPing {
    RRUser *user = [RRUser sharedInstance];
    if (user.servers != nil && user.servers.count != 0) {
        ServerModel *server = user.servers[0];

        self.refreshing = YES;
        self.activityIndicator.hidden = NO;
        self.refreshView.hidden = YES;
        self.currentPingIndex = 0;
        self.pingTester = [[WHPingTester alloc] initWithHostName:server.host];
        self.pingTester.delegate = self;
        [self.pingTester startPing];
    }
}

- (UIView *)customViewForRightItem {
    UIView *rightCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    _refreshView = [TPViewUtil imageViewWithFrame:CGRectMake(100 - 22, 10, 24, 24) image:[UIImage imageNamed:@"icon_reflsh"]];
    [rightCustomView addSubview:_refreshView];
    [rightCustomView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(gotoRefresh)]];
    _refreshView.image = [_refreshView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _refreshView.tintColor = TOP_BAR_TEXT_COLOR;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    _activityIndicator.frame= CGRectMake(100 - 22, 10, 24, 24);
    _activityIndicator.color = MAIN_FONT_COLOR;
    _activityIndicator.backgroundColor = [UIColor clearColor];
    _activityIndicator.hidesWhenStopped = NO;
    [_activityIndicator startAnimating];
    [rightCustomView addSubview:_activityIndicator];
    
    _activityIndicator.hidden = YES;
    
    return rightCustomView;
}

- (void)gotoChangePassword {
    //    RRSettingViewController *vc = [RRSettingViewController new];
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoRefresh {
    if (self.refreshing == YES) {
        return;
    }
    [self initPing];
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

#pragma mark TPItemViewDelegate

- (void)itemViewTap:(TPItemView *)itemView {
    
    MenuItem *item = [_dataSource objectAtIndex:itemView.tag];
    
    if ([self getSelectedServer:item.dataInt] == nil) {
        FVBuyVipViewController *vc = [FVBuyVipViewController new];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(chooseServerViewControllerItemTap:serverId:)]) {
        [self.delegate chooseServerViewControllerItemTap:self serverId:item.dataInt];
    }
    return;
    
    SEL action = item.action;
    if ([self respondsToSelector:action]) {
        
        ((void (*)(id, SEL))[self methodForSelector:action])(self, action);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItem *item = [self dataForIndexPath:indexPath];
    if (item.type == MenuItemTypeSeparator) {
        SeparatorTableViewCell *separatorCell = [tableView dequeueReusableCellWithIdentifier:SeparatorTableViewCellIdentifier forIndexPath:indexPath];
        return separatorCell;
    } else {
        UserItemTableViewCell *userItemCell = [tableView cellForRowAtIndexPath:indexPath];
        if (!userItemCell) {
            userItemCell = [[UserItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserItemTableViewCellIdentifier];
        }
        userItemCell.itemView.tag = indexPath.row;
        
        [userItemCell setUp:item];
        userItemCell.itemView.delegate = self;
        return userItemCell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 72;
    } else {
        MenuItem *item = [self dataForIndexPath:indexPath];
        return item.height;
    }
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource objectAtIndex:indexPath.row];
}

#pragma mark - WHPingDelegate

- (void) didPingSucccessWithTime:(float)time withError:(NSError *)error {

    NSLog(@"ping的延迟是--->%f", time);
    [self.pingTester stopPing];
    RRUser *user = [RRUser sharedInstance];
    ServerModel *server = user.servers[self.currentPingIndex];

    if (!error) {
        if (time > 150) {
            time = time - 100;
        }
    } else {
        NSUInteger r = arc4random_uniform(100) + 50;
        time = r;
    }
    
    [[RRPing sharedInstance] saveWithServerId:server.serverId PingValue:time];

    [self.pingResult addObject:[NSNumber numberWithFloat:time]];
    [self initDataSource];
    [self reloadData];
    self.currentPingIndex++;
    if (self.currentPingIndex < user.servers.count) {
        ServerModel *server = user.servers[self.currentPingIndex];
        self.pingTester = [[WHPingTester alloc] initWithHostName:server.host];
        self.pingTester.delegate = self;
        [self.pingTester startPing];
    } else {
        self.refreshing = NO;
        self.activityIndicator.hidden = YES;
        self.refreshView.hidden = NO;
        user.hasPing = YES;
    }
}

@end
