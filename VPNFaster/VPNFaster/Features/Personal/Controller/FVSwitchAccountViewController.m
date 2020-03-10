//
//  FVSwitchAccountViewController.m
//  VPNFaster
//
//  Created by 何永军 on 2019/5/25.
//  Copyright © 2019 roborock. All rights reserved.
//

#import "FVSwitchAccountViewController.h"
#import "RRUser.h"

@interface FVSwitchAccountViewController ()

@property (nonatomic, strong) TPTextFieldView        *switchAccountUserNameView;
@property (nonatomic, strong) TPTextFieldView        *switchAccountPasswordView;

@end

@implementation FVSwitchAccountViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}

- (void)initView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(30, self.view.height - 300, APP_SCREEN_WIDTH - 60, 250)];
    contentView.backgroundColor = MAIN_BACKGROUND_COLOR;
    [contentView.layer setCornerRadius:8.0];
    
    UILabel *titleLable = [TPViewUtil labelWithFrame:CGRectMake(0, 20, APP_SCREEN_WIDTH - 60, 25) fontSize:18 color:LIST_MAIN_TEXT_COLOR];
    titleLable.text = NSLocalizedString(@"menu_current_switch_account", nil);
    titleLable.font = [UIFont systemFontOfSize:18];
    titleLable.textAlignment = NSTextAlignmentCenter;
    
    UIImageView *logoView = [TPViewUtil imageViewWithFrame:CGRectMake((self.view.width - 72 - 60) / 2, titleLable.bottom + 15, 72, 72) imageName:@"yuan_196"];
    
    _switchAccountUserNameView = [[TPTextFieldView alloc] initWithFrame:CGRectMake(10, logoView.bottom + 20, self.view.width - 80, 48)];
    _switchAccountUserNameView.backgroundColor = LIST_BACKGROUND_COLOR;
    _switchAccountUserNameView.roundCorner = YES;
    _switchAccountUserNameView.topLineHidden = YES;
    _switchAccountUserNameView.bottomLineHidden = YES;
    _switchAccountUserNameView.layer.borderWidth = 1;
    _switchAccountUserNameView.layer.borderColor = [HEXCOLOR(0xc8c8c8) CGColor];
    _switchAccountUserNameView.leftImage = [UIImage imageNamed:@"mine_icon_gywm"];
    _switchAccountUserNameView.textField.keyboardType = UIKeyboardTypeNumberPad;
    
    _switchAccountPasswordView = [[TPTextFieldView alloc] initWithFrame:CGRectMake(10, _switchAccountUserNameView.bottom + 10, self.view.width - 80, 48)];
    _switchAccountPasswordView.backgroundColor = LIST_BACKGROUND_COLOR;
    _switchAccountPasswordView.roundCorner = YES;
    _switchAccountPasswordView.topLineHidden = YES;
    _switchAccountPasswordView.bottomLineHidden = YES;
    _switchAccountPasswordView.layer.borderWidth = 1;
    _switchAccountPasswordView.layer.borderColor = [HEXCOLOR(0xc8c8c8) CGColor];
    _switchAccountPasswordView.leftImage = [UIImage imageNamed:@"mine_icon_xgmm"];
    //        _switchAccountUserNameView.placeholder = NSLocalizedString(@"input_telephone_number", @"");
    _switchAccountPasswordView.textField.keyboardType = UIKeyboardTypeNumberPad;
    
    /****分割线****/
    UIView *seperatiorLine = [TPViewUtil viewWithFrame:CGRectMake(0, _switchAccountPasswordView.bottom + 15, self.view.width - 60, 1) color:LIST_SECTION_BACKGROUND_COLOR];
    UIView *seperatiorLineVertical = [TPViewUtil viewWithFrame:CGRectMake((self.view.width - 60) / 2, seperatiorLine.bottom, 1, 48) color:LIST_SECTION_BACKGROUND_COLOR];
    
    UIButton *cancelButton = [TPViewUtil buttonWithFrame:CGRectMake(0, seperatiorLine.bottom, (self.view.width - 60) / 2, 48) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x444444) borderColor:nil];
    [cancelButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    UIButton *confirmButton = [TPViewUtil buttonWithFrame:CGRectMake(self.view.width/2 - 30, seperatiorLine.bottom , (self.view.width - 60) / 2, 48) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x1f99ef) borderColor:nil];
    [confirmButton setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    
    [cancelButton addTarget:self action:@selector(cancelButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton addTarget:self action:@selector(confirmButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:contentView];
    [contentView addSubview:titleLable];
    [contentView addSubview:logoView];
    [contentView addSubview:_switchAccountUserNameView];
    [contentView addSubview:_switchAccountPasswordView];
    [contentView addSubview:cancelButton];
    [contentView addSubview:confirmButton];
    [contentView addSubview:seperatiorLine];
    [contentView addSubview:seperatiorLineVertical];
    
    contentView.height = 322;
    contentView.frame = CGRectMake(30, (APP_SCREEN_HEIGHT - contentView.height) / 2, self.view.width - 60, contentView.height);
    
    // 做动画
    [self readyToAnimate:contentView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentAnimation];
    });
}

-(void)cancelButtonTap{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)confirmButtonTap{
    
    NSString *userName = _switchAccountUserNameView.text;
    NSString *password = _switchAccountPasswordView.text;
    if (userName == nil || [userName isEqualToString:@""] || password == nil || [password isEqualToString:@""]) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[RRUser sharedInstance] getTotalInfo:userName password:password success:^() {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self.delegate onAccountSwitched];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

@end
