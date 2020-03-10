//
//  FVPersonalView.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/16.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "FVPersonalViewController.h"

#import "RRUser.h"
#import "ProductModel.h"

#import "TPItemView.h"
#import "FVPersonalView.h"
#import "FVPersonalHeaderCell.h"
#import "UserItemTableViewCell.h"
#import "SeparatorTableViewCell.h"
#import "FVBuyVipViewController.h"
#import "FVShareViewController.h"
#import "FVAboutViewController.h"
#import "FVResetPasswordViewController.h"
#import "FVSwitchAccountViewController.h"


#define UserHeaderTableViewCellIdentifier  @"UserHeaderTableViewCellIdentifier" //暂时不用
#define UserItemTableViewCellIdentifier  @"UserItemTableViewCellIdentifier"
#define SeparatorTableViewCellIdentifier @"SeparatorTableViewCellIdentifier"

@interface FVPersonalViewController ()<UITableViewDataSource,UITableViewDelegate,TPItemViewDelegate,FVResetPasswordViewControllerDelegate,FVSwitchAccountViewControllerDelegate>

@property (nonatomic,strong) NSArray               *dataSource;
@property (nonatomic,strong) FVPersonalView        *userView;

@property (nonatomic,assign) int             hitCount;  //用于隐藏开发者选项

@end

@implementation FVPersonalViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self initDataSource];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)reloadData {
    [_userView.userTableView reloadData];
}

- (void)initView {
    self.centerTitleItem.title = NSLocalizedString(@"menu_me", @"");
    self.topBarView.centerItem = self.centerTitleItem;
    
    [self initUserView];
}

- (void)initUserView {
    _userView = [[FVPersonalView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, APP_SCREEN_WIDTH,APP_VISIBLE_HEIGHT)];
    [_userView.userTableView registerClass:[FVPersonalHeaderCell class] forCellReuseIdentifier:UserHeaderTableViewCellIdentifier];
    [_userView.userTableView registerClass:[UserItemTableViewCell class] forCellReuseIdentifier:UserItemTableViewCellIdentifier];
    [_userView.userTableView registerClass:[SeparatorTableViewCell class] forCellReuseIdentifier:SeparatorTableViewCellIdentifier];
    _userView.userTableView.dataSource = self;
    _userView.userTableView.delegate = self;
    
    [self.view addSubview:_userView];
    
    TPItemView *signoutItemView = [TPItemView itemViewWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 85)];
    signoutItemView.topLine.hidden = YES;
    signoutItemView.bottomLine.hidden = YES;
    signoutItemView.centerLabel.textColor = [UIColor whiteColor];
    signoutItemView.centerLabel.text = NSLocalizedString(@"menu_current_switch_account", @"");
    signoutItemView.delegate = self;
    UIButton *switchAccountButton = [TPViewUtil buttonWithFrame:CGRectMake(20, 20, APP_SCREEN_WIDTH - 40, 48) fontSize:17 bgColor:HEXCOLOR(0x229ff7) textColor:[UIColor whiteColor] borderColor:nil];
    [switchAccountButton setTitle:NSLocalizedString(@"menu_current_switch_account", @"") forState:UIControlStateNormal];
    [switchAccountButton addTarget:self action:@selector(switchAccountButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [switchAccountButton.layer setCornerRadius:8];
    [signoutItemView addSubview:switchAccountButton];
    _userView.userTableView.tableFooterView = signoutItemView;
}

- (void)initDataSource {
    RRUser *user = [RRUser sharedInstance];
    
    NSObject *profileItem = [[NSObject alloc] init];
    
    MenuItem *vipTypeItem = [MenuItem normalItem:[UIImage imageNamed:@"mine_icon_dqtc"] title:NSLocalizedString(@"menu_current_vip_type", nil) action:@selector(gotoBuy) showRightArrow:YES];
    vipTypeItem.rightTitleColor = HEXCOLOR(0xff902e);
    vipTypeItem.height = 65;

    NSString *lowerGroup = [user.userGroup lowercaseString];

    if ([lowerGroup isEqualToString:@"trail"]) {
        NSString *timestapString = [NSString stringWithFormat:@"%ld", (long)user.expireDate/1000];
        NSString *expiredDateString = [TPDate time2String:timestapString format:@"MM-dd HH:mm"];
        vipTypeItem.rightTitle = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"menu_vip_trail_title", nil), expiredDateString];
    } else if ([lowerGroup isEqualToString:@"normal"]) {
        vipTypeItem.rightTitle = [NSString stringWithFormat:@"%@: %ldM", NSLocalizedString(@"menu_vip_normal_title", nil), (user.limit - user.used)];
    }else if (![user.subscribedItem isKindOfClass:[NSNull class]]) {
        for (ProductModel *product in user.products) {
            if (![product.productId isKindOfClass:[NSNull class]] && [product.productId isEqualToString:user.subscribedItem]) {
                vipTypeItem.rightTitle = product.name;
                break;
            }
        }
    }

    MenuItem *changePasswordItem = [MenuItem normalItem:[UIImage imageNamed:@"mine_icon_xgmm"] title:NSLocalizedString(@"menu_current_change_pwd", nil) action:@selector(gotoChangePassword) showRightArrow:YES];
    changePasswordItem.height = 65;
    MenuItem *msgCenterPasswordItem = [MenuItem normalItem:[UIImage imageNamed:@"mine_icon_message"] title:NSLocalizedString(@"menu_current_message_center", nil) action:@selector(gotoChangePassword) showRightArrow:YES];
    msgCenterPasswordItem.height = 65;
    MenuItem *aboutUsItem = [MenuItem normalItem:[UIImage imageNamed:@"mine_icon_gywm"] title:NSLocalizedString(@"menu_current_about_us", nil) action:@selector(gotoAbout) showRightArrow:YES];
    aboutUsItem.height = 65;
    MenuItem *shareItem = [MenuItem normalItem:[UIImage imageNamed:@"mine_icon_share"] title:NSLocalizedString(@"menu_current_share", nil) action:@selector(gotoShare) showRightArrow:YES];
    shareItem.height = 65;
    
    
    
    NSMutableArray *list = [NSMutableArray new];
    [list addObject:profileItem];
    [list addObject:vipTypeItem];
    [list addObject:changePasswordItem];
//    [list addObject:msgCenterPasswordItem];
    [list addObject:aboutUsItem];
    [list addObject:shareItem];
    //    [list addObject:[MenuItem separatorItem:10]];
    
    _dataSource = [NSArray arrayWithArray:list];
}

- (void)gotoChangePassword {
    FVResetPasswordViewController *alertVC = [[FVResetPasswordViewController alloc] init];
    alertVC.delegate = self;
    alertVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alertVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)gotoShare {
    [FVShareViewController showAlertFromViewController:self];
}

- (void)gotoBuy {
    FVBuyVipViewController *vc = [FVBuyVipViewController new];
    TPNavigationController *navi = [[TPNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)gotoAbout {
    FVAboutViewController *alertVC = [[FVAboutViewController alloc] init];
    alertVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alertVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)switchAccountButtonTap {
    FVSwitchAccountViewController *alertVC = [[FVSwitchAccountViewController alloc] init];
    alertVC.delegate = self;
    alertVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alertVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        
        FVPersonalHeaderCell *headerCell = [tableView dequeueReusableCellWithIdentifier:UserHeaderTableViewCellIdentifier forIndexPath:indexPath];
        [headerCell refresh];
        return headerCell;
    } else {
        MenuItem *item = [self dataForIndexPath:indexPath];
        if (item.type == MenuItemTypeSeparator) {
            SeparatorTableViewCell *separatorCell = [tableView dequeueReusableCellWithIdentifier:SeparatorTableViewCellIdentifier forIndexPath:indexPath];
            return separatorCell;
        } else {
            UserItemTableViewCell *userItemCell = [tableView dequeueReusableCellWithIdentifier:UserItemTableViewCellIdentifier forIndexPath:indexPath];
            userItemCell.itemView.tag = indexPath.row;
            
            [userItemCell setUp:item];
            userItemCell.itemView.delegate = self;
            return userItemCell;
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 90;
    } else {
        MenuItem *item = [self dataForIndexPath:indexPath];
        return item.height;
    }
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource objectAtIndex:indexPath.row];
}

#pragma mark  - FVResetPasswordViewControllerDelegate

- (void)onPasswordReseted{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert_reset_password_success_title", nil) message:NSLocalizedString(@"alert_reset_password_success_mssage", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:^(void){
        [self initDataSource];
        [self reloadData];
    }];
}

#pragma mark - FVSwitchAccountViewControllerDelegate

- (void)onAccountSwitched{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert_reset_password_success_title", nil) message:NSLocalizedString(@"alert_reset_password_success_mssage", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:^(void){
        [self initDataSource];
        [self reloadData];
    }];
}

@end
