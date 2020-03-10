//
//  FVResetPasswordViewController.m
//  VPNFaster
//
//  Created by 何永军 on 2019/5/25.
//  Copyright © 2019 roborock. All rights reserved.
//

#import "FVResetPasswordViewController.h"
#import "RRUser.h"

@interface FVResetPasswordViewController ()

@property (nonatomic, strong) TPTextFieldView        *modifyPasswordTextView;

@end

@implementation FVResetPasswordViewController

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
    RRUser *user = [RRUser sharedInstance];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(30, self.view.height - 300, APP_SCREEN_WIDTH - 60, 250)];
    contentView.backgroundColor = MAIN_BACKGROUND_COLOR;
    [contentView.layer setCornerRadius:8.0];
    
    UILabel *titleLable = [TPViewUtil labelWithFrame:CGRectMake(0, 20, APP_SCREEN_WIDTH - 60, 25) fontSize:18 color:LIST_MAIN_TEXT_COLOR];
    titleLable.text = NSLocalizedString(@"menu_current_change_pwd", @"");
    titleLable.textAlignment = NSTextAlignmentCenter;
    
    UILabel *oldPwdLable = [TPViewUtil labelWithFrame:CGRectMake(15, titleLable.bottom + 20, APP_SCREEN_WIDTH - 60 - 30, 30) fontSize:16 color:LIST_MAIN_TEXT_COLOR];
    oldPwdLable.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"personnal_old_password", @""), user.password];
    
    _modifyPasswordTextView = [[TPTextFieldView alloc] initWithFrame:CGRectMake(15, oldPwdLable.bottom + 20, self.view.width - 60 - 30, 48)];
    _modifyPasswordTextView.backgroundColor = LIST_BACKGROUND_COLOR;
    _modifyPasswordTextView.roundCorner = YES;
    _modifyPasswordTextView.topLineHidden = YES;
    _modifyPasswordTextView.bottomLineHidden = YES;
    _modifyPasswordTextView.layer.borderWidth = 1;
    _modifyPasswordTextView.layer.borderColor = [LIST_SECTION_BACKGROUND_COLOR CGColor];
    _modifyPasswordTextView.placeholder = NSLocalizedString(@"personnal_please_input_new", @"");
    _modifyPasswordTextView.textField.keyboardType = UIKeyboardTypeNumberPad;
    
    /****分割线****/
    UIView *seperatiorLine = [TPViewUtil viewWithFrame:CGRectMake(0, _modifyPasswordTextView.bottom + 40, self.view.width - 60, 1) color:LIST_SECTION_BACKGROUND_COLOR];
    UIView *seperatiorLineVertical = [TPViewUtil viewWithFrame:CGRectMake((self.view.width - 60) / 2, seperatiorLine.bottom, 1, 48) color:LIST_SECTION_BACKGROUND_COLOR];
    
    UIButton *cancelButton = [TPViewUtil buttonWithFrame:CGRectMake(0, seperatiorLine.bottom, (self.view.width - 60) / 2, 48) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x444444) borderColor:nil];
    [cancelButton setTitle:NSLocalizedString(@"cancel", @"") forState:UIControlStateNormal];
    UIButton *confirmButton = [TPViewUtil buttonWithFrame:CGRectMake(self.view.width/2 - 30, seperatiorLine.bottom, (self.view.width - 60) / 2, 48) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x1f99ef) borderColor:nil];
    [confirmButton setTitle:NSLocalizedString(@"ok", @"") forState:UIControlStateNormal];
    
    [cancelButton addTarget:self action:@selector(cancelButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton addTarget:self action:@selector(confirmButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:contentView];
    [contentView addSubview:titleLable];
    [contentView addSubview:oldPwdLable];
    [contentView addSubview:_modifyPasswordTextView];
    [contentView addSubview:cancelButton];
    [contentView addSubview:confirmButton];
    [contentView addSubview:seperatiorLine];
    [contentView addSubview:seperatiorLineVertical];
    
    contentView.height = 252;
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
    NSString *newPwd = _modifyPasswordTextView.text;
    if (newPwd == nil || [newPwd isEqualToString:@""]) {
        return;
    } else if ([newPwd rangeOfString:@"\\d{6,6}" options:NSRegularExpressionSearch].location == NSNotFound || newPwd.length != 6) {
        [TPProgressUtils showError:NSLocalizedString(@"modify_password_tip", @"")];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    RRUser *user = [RRUser sharedInstance];
    [[RRUser sharedInstance] resetPassword:user.password newPassword:newPwd success:^() {
        user.password = newPwd;
        [user save];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // TODO
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [self.delegate onPasswordReseted];
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [TPProgressUtils showError:NSLocalizedString(@"network_issue_message", nil)];
        });
    }];
}

@end
