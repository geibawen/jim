//
//  FVPersonalView.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/16.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "FVBuyVipViewController.h"

#import "RRUser.h"
#import "YQInAppPurchaseTool.h"
#import "ProductModel.h"

#import "TPItemView.h"
#import "FVBuyVipView.h"
#import "FVPersonalHeaderCell.h"
#import "UserItemTableViewCell.h"
#import "SeparatorTableViewCell.h"
#import "FVBuyVipCell.h"

#import <Reachability/Reachability.h>

#define FVBuyVipTableViewCellIdentifier @"FVBuyVipTableViewCellIdentifier"

@interface FVBuyVipViewController ()<UITableViewDataSource,UITableViewDelegate,TPItemViewDelegate,YQInAppPurchaseToolDelegate>

@property (nonatomic,strong) NSArray               *dataSource;
@property (nonatomic,strong) FVBuyVipView          *userView;

@property (nonatomic,strong) YQInAppPurchaseTool          *IAPTool;


@end

@implementation FVBuyVipViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    // 加载数据
    [self requestProducts];
}

- (void) showNetworkErrorAlert{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"network_issue_title", nil) message:NSLocalizedString(@"network_issue_message", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"quit", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"retry", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self requestProducts];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)reloadData {
    [_userView.userTableView reloadData];
}

- (void)initView {
    self.topBarView.leftItem = [TPBarButtonItem titleItem:NSLocalizedString(@"main_vip_title", nil) target:self action:nil];
    
    [self initUserView];
}

- (void)initUserView {
    _userView = [[FVBuyVipView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, APP_SCREEN_WIDTH,APP_VISIBLE_HEIGHT)];
    [_userView.userTableView registerClass:[FVBuyVipCell class] forCellReuseIdentifier:FVBuyVipTableViewCellIdentifier];
    _userView.userTableView.dataSource = self;
    _userView.userTableView.delegate = self;
    _userView.viewController = self;
    
    [self.view addSubview:_userView];
}

- (YQInAppPurchaseTool *)IAPTool {
    if (!_IAPTool) {
        _IAPTool = [YQInAppPurchaseTool defaultTool];
        _IAPTool.delegate = self;
    }
    return _IAPTool;
}

- (void)requestProducts {
    if ([[TPUtils networkType] isEqualToString:@"none"]) {
        [self showNetworkErrorAlert];
    } else {
        [self showProgressView];
        RRUser *user = [RRUser sharedInstance];
        
        NSMutableArray *productIds = [NSMutableArray new];
        for (ProductModel *model in user.products) {
            [productIds addObject:model.productId];
        }
        NSLog(@"will request product:%@", productIds);
        [self.IAPTool requestProductsWithProductArray:productIds];
    }
}

- (void)initDataSource:(NSMutableArray *)products {
    RRUser *user = [RRUser sharedInstance];
    NSMutableArray *list = [NSMutableArray new];
    
    for (SKProduct *product in products) {
        FVBuyVipModel *buyModel = [FVBuyVipModel new];
        buyModel.productId = product.productIdentifier;
        buyModel.price = [product.price floatValue];
        buyModel.priceSymbol = [product.priceLocale objectForKey:NSLocaleCurrencySymbol];
        buyModel.productName = product.localizedTitle;
        buyModel.productDescription = product.localizedDescription;
        for (ProductModel *model in user.products) {
            if ([model.productId isEqualToString:product.productIdentifier]) {
                buyModel.sort = model.sort;
                break;
            }
        }

        if (![user.subscribedItem isKindOfClass:[NSNull class]] && [user.subscribedItem isEqualToString:product.productIdentifier]) {
            buyModel.subscribed = YES;
        }
        NSLog(@"product detail:%f,%@", buyModel.price, buyModel.priceSymbol);
        [list addObject:buyModel];
    }

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES];
    NSArray *tempList = [list sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    _dataSource = tempList;
    [self reloadData];
    self.userView.userTableView.tableFooterView.hidden = NO;
    NSLog(@"Got new datasource:%@", _dataSource);
}

- (UIView *)customViewForRightItem {
    UIView *rightCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    UIImageView *settingImageView = [TPViewUtil imageViewWithFrame:CGRectMake(100 - 22, 10, 24, 24) image:[UIImage imageNamed:@"icon_close"]];
    [rightCustomView addSubview:settingImageView];
    [rightCustomView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(gotoClose)]];
    settingImageView.image = [settingImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    settingImageView.tintColor = TOP_BAR_TEXT_COLOR;
    return rightCustomView;
}

- (void)gotoClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showSubscribedSuccessAlert{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"main_vip_buy_success", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)showSubscribedFailedAlert{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"main_vip_buy_failed", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
    FVBuyVipModel *item = [self dataForIndexPath:indexPath];
    FVBuyVipCell *itemCell = [tableView dequeueReusableCellWithIdentifier:FVBuyVipTableViewCellIdentifier forIndexPath:indexPath];
    itemCell.selectionStyle = UITableViewCellSelectionStyleNone;
    itemCell.tag = indexPath.row;
    
    [itemCell setUp:item];
    return itemCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59 + 15;
}

- (id)dataForIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ProductModel *model = [self dataForIndexPath:indexPath];
    RRUser *user = [RRUser sharedInstance];
    if (user.subscribedItem && ![user.subscribedItem isKindOfClass:[NSNull class]] &&[user.subscribedItem isEqualToString:model.productId]) {
        return;
    }
    [self.IAPTool buyProduct:model.productId];
    [self showProgressView];
}

#pragma mark - YQInAppPurchaseToolDelegate

- (void)IAPToolBeginCheckingdWithProductID:(NSString *)productID {
    NSLog(@"IAPToolBeginCheckingdWithProductID");
}

/***********仅用此回调表示成功购买***********/
- (void)IAPToolBoughtProductSuccessedWithProductID:(NSString *)productID andInfo:(NSDictionary *)infoDic {
    NSLog(@"IAPToolBoughtProductSuccessedWithProductID");
    [self hideProgressView];
    [self showSubscribedSuccessAlert];
}

/***********这个回调目前不使用***********/
-(void)IAPToolBoughtProductSuccessedWithProductID:(NSString *)productID receipt:(NSString *)receipt {
    NSLog(@"IAPToolBoughtProductSuccessedWithProductID receipt");
    
    [[RRUser sharedInstance] postBuyReceipt:receipt success:^(){
        NSLog(@"check receipt ok from server. new expire:%ld", [RRUser sharedInstance].expireDate);
        [self hideProgressView];
        [self showSubscribedSuccessAlert];
    } failure:^(NSError *error){
        NSLog(@"check receip failed");
        [self hideProgressView];
        [self showSubscribedFailedAlert];
    }];
}

- (void)IAPToolCanceldWithProductID:(NSString *)productID {
    NSLog(@"IAPToolCanceldWithProductID");
    [self hideProgressView];
    
    [self showSubscribedFailedAlert];
}

- (void)IAPToolCheckFailedWithProductID:(NSString *)productID andInfo:(NSData *)infoData {
    NSLog(@"IAPToolCheckFailedWithProductID");
    [self hideProgressView];
    
    [self showSubscribedFailedAlert];
}

- (void)IAPToolCheckRedundantWithProductID:(NSString *)productID {
    NSLog(@"IAPToolCheckRedundantWithProductID");
    [self hideProgressView];
}

- (void)IAPToolGotProducts:(NSMutableArray *)products {
    NSLog(@"IAPToolGotProducts, %@", products);
    [self hideProgressView];
    if (products.count == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"network_issue_title", nil) message:NSLocalizedString(@"network_issue_message", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [self initDataSource:products];
}

- (void)IAPToolRestoredProductID:(NSString *)productID {
    NSLog(@"IAPToolRestoredProductID");
    [self hideProgressView];
}

- (void)IAPToolSysWrong {
    NSLog(@"IAPToolSysWrong");
    [TPProgressUtils showError:NSLocalizedString(@"error_occur", nil)];
}

@end
