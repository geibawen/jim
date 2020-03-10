//
//  FVAboutViewController.m
//  VPNFaster
//
//  Created by 何永军 on 2019/5/25.
//  Copyright © 2019 roborock. All rights reserved.
//

#import "FVAboutViewController.h"

@interface FVAboutViewController ()<UITextViewDelegate>

@property(nonatomic, strong) TPWebViewController *webViewController;

@end

@implementation FVAboutViewController

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
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = NSLocalizedString(@"menu_current_about_us", nil);
    
    UIImageView *logoView = [TPViewUtil imageViewWithFrame:CGRectMake((self.view.width - 72 - 60) / 2, titleLable.bottom + 30, 72, 72) imageName:@"yuan_196"];
    
    UILabel *appNameLable = [TPViewUtil labelWithFrame:CGRectMake(0, logoView.bottom + 20, 200, 30) fontSize:21 color:LIST_MAIN_TEXT_COLOR];
    appNameLable.text = APP_ABOUT_NAME;
    UILabel *appVersionLable = [TPViewUtil labelWithFrame:CGRectMake(0, logoView.bottom + 20, 40, 20) fontSize:14 color:HEXCOLOR(0x1f99ef)];
    appVersionLable.text = [NSString stringWithFormat:@"v%@", APP_VERSION];
    
    CGFloat nameWidth =  [appNameLable.text sizeWithAttributes:@{NSFontAttributeName : appNameLable.font}].width;
    CGFloat versionWidth =  [appVersionLable.text sizeWithAttributes:@{NSFontAttributeName : appVersionLable.font}].width;
    appNameLable.frame = CGRectMake((self.view.width - 60 - nameWidth - versionWidth) / 2, logoView.bottom + 20, nameWidth, 30);
    appVersionLable.frame = CGRectMake(appNameLable.right + 10, logoView.bottom + 20 + 7, versionWidth, 20);
    
    UITextView *detail = [[UITextView alloc] initWithFrame:CGRectMake(0, appNameLable.bottom + 56, APP_SCREEN_WIDTH - 60, 30)];
    detail.backgroundColor = MAIN_BACKGROUND_COLOR;
    detail.font = [UIFont systemFontOfSize:16];
    //        detail.textAlignment = NSTextAlignmentCenter;
    detail.delegate = self;
    detail.editable = NO;
    detail.scrollEnabled = NO;
    detail.textAlignment = NSTextAlignmentCenter;
    detail.textColor = HEXCOLOR(0x444444);
    //detail.textContainer.lineFragmentPadding 会看到UItextView左右各有5个点padding，上下各有8个点的inset
    //要把上下的inset设置成0，左右的如果是0的话是表示到边界也就是padding的值，要设置成负的才行
    detail.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
    
    NSString *policy = NSLocalizedString(@"privacy_policy", nil);
    NSString *agreement = NSLocalizedString(@"terms_of_service", nil);
    
    NSString *detailText = [NSString stringWithFormat:@"%@ & %@", policy, agreement];
    NSMutableAttributedString *myStr = [[NSMutableAttributedString alloc] initWithString:detailText attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    
    NSMutableParagraphStyle *paragraphStyleFirst = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleFirst setLineSpacing:9];
    [paragraphStyleFirst setParagraphSpacing:0];
    [paragraphStyleFirst setFirstLineHeadIndent:0.0];
    [paragraphStyleFirst setAlignment:NSTextAlignmentCenter];
    
    //绑定标签跳转
    [myStr addAttribute:NSLinkAttributeName
                  value:@"privacy://"
                  range:[[myStr string] rangeOfString:policy]];
    [myStr addAttribute:NSLinkAttributeName
                  value:@"agreement://"
                  range:[[myStr string] rangeOfString:agreement]];

    [myStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyleFirst range:NSMakeRange(0, detailText.length)];
    
    detail.linkTextAttributes = @{NSForegroundColorAttributeName: HEXCOLOR(0x1f99ef),
                                  NSUnderlineColorAttributeName: [UIColor redColor],
                                  NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
    
    detail.attributedText = myStr;
    
    CGSize maxSize = CGSizeMake(APP_SCREEN_WIDTH - 90, 600);
    CGRect contentRect = [myStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    detail.frame = CGRectMake(detail.frame.origin.x, detail.frame.origin.y, detail.width, contentRect.size.height);
    
    /****分割线****/
    UIView *seperatiorLine = [TPViewUtil viewWithFrame:CGRectMake(0, detail.bottom, self.view.width - 60, 1) color:LIST_SECTION_BACKGROUND_COLOR];
    
    UIButton *confirmButton = [TPViewUtil buttonWithFrame:CGRectMake(0, seperatiorLine.bottom, (self.view.width - 60), 48) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x1f99ef) borderColor:nil];
    [confirmButton setTitle:NSLocalizedString(@"ok", @"") forState:UIControlStateNormal];
    
    [confirmButton addTarget:self action:@selector(confirmButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:contentView];
    [contentView addSubview:titleLable];
    [contentView addSubview:logoView];
    [contentView addSubview:appNameLable];
    [contentView addSubview:appVersionLable];
    [contentView addSubview:detail];
    [contentView addSubview:confirmButton];
    [contentView addSubview:seperatiorLine];
    
    contentView.height = confirmButton.bottom;
    contentView.frame = CGRectMake(30, (APP_SCREEN_HEIGHT - contentView.height) / 2, self.view.width - 60, contentView.height);
    
    // 做动画
    [self readyToAnimate:contentView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentAnimation];
    });
}

-(void)confirmButtonTap{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"privacy"]) {
        NSLog(@"click privacy");
        [self gotoWebViewController:NSLocalizedString(@"privacy_policy", nil) url:PRIVACY_POLICY];
        return NO;
    }
    if ([[URL scheme] isEqualToString:@"agreement"]) {
        NSLog(@"click agreement");
        [self gotoWebViewController:NSLocalizedString(@"terms_of_service", nil) url:TERMS_OF_SERVICE];
        return NO;
    }
    
    return YES;
}

-(void)gotoWebViewController:(NSString *)title url:(NSString *)url{
    _webViewController = [[TPWebViewController alloc] initWithUrlString:url];
    _webViewController.title = title;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close"] style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    _webViewController.navigationItem.rightBarButtonItem = rightButtonItem;
    [ViewControllerUtils presentViewController:_webViewController from:self];
}

-(void)close{
    [_webViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
