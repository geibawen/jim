//
//  FVPolicyViewController.m
//  VPNFaster
//
//  Created by 何永军 on 2019/5/25.
//  Copyright © 2019 roborock. All rights reserved.
//

#import "FVPolicyViewController.h"

@interface FVPolicyViewController ()<UITextViewDelegate>

@property(nonatomic, strong) TPWebViewController *webViewController;

@end

@implementation FVPolicyViewController


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
    
    UILabel *titleLable = [TPViewUtil labelWithFrame:CGRectMake(50, 20, 200, 25) fontSize:20 color:LIST_MAIN_TEXT_COLOR];
    titleLable.text = NSLocalizedString(@"agreement_title", @"");
    
    UITextView *detail = [[UITextView alloc] initWithFrame:CGRectMake(15, titleLable.bottom + 15, APP_SCREEN_WIDTH - 90, 30)];
    detail.backgroundColor = MAIN_BACKGROUND_COLOR;
    detail.font = [UIFont systemFontOfSize:16];
    //        detail.textAlignment = NSTextAlignmentCenter;
    detail.delegate = self;
    detail.editable = NO;
    detail.scrollEnabled = NO;
    detail.textColor = HEXCOLOR(0x444444);
    //detail.textContainer.lineFragmentPadding 会看到UItextView左右各有5个点padding，上下各有8个点的inset
    //要把上下的inset设置成0，左右的如果是0的话是表示到边界也就是padding的值，要设置成负的才行
    detail.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
    
    NSString *policy = NSLocalizedString(@"privacy_policy", nil);
    NSString *agreement = NSLocalizedString(@"terms_of_service", nil);
    NSString *agree = NSLocalizedString(@"agreement_button_agree", nil);
    NSString *agreement_detail1 = [NSString stringWithFormat:NSLocalizedString(@"agreement_detail1", nil), policy, agreement, agree];
    
    NSString *detailText = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"agreement_detail", nil), agreement_detail1];
    NSMutableAttributedString *myStr = [[NSMutableAttributedString alloc] initWithString:detailText attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    
    NSMutableParagraphStyle *paragraphStyleFirst = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleFirst setLineSpacing:3];
    [paragraphStyleFirst setParagraphSpacing:10];
    [paragraphStyleFirst setFirstLineHeadIndent:0.0];
    [paragraphStyleFirst setAlignment:NSTextAlignmentJustified];

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
    
    
    UIButton *cancelButton = [TPViewUtil buttonWithFrame:CGRectMake(0, detail.bottom + 30, (self.view.width - 60) / 2, 25) fontSize:20 bgColor:nil textColor:HEXCOLOR(0x444444) borderColor:nil];
    [cancelButton setTitle:NSLocalizedString(@"agreement_button_cancel", @"") forState:UIControlStateNormal];
    UIButton *confirmButton = [TPViewUtil buttonWithFrame:CGRectMake(self.view.width/2 - 30, detail.bottom + 30, (self.view.width - 60) / 2, 25) fontSize:20 bgColor:nil textColor:HEXCOLOR(0x1f99ef) borderColor:nil];
    [confirmButton setTitle:NSLocalizedString(@"agreement_button_agree", @"") forState:UIControlStateNormal];
    
    [cancelButton addTarget:self action:@selector(cancelAgreeButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton addTarget:self action:@selector(agreeButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    /****分割线****/
    UIView *seperatiorLine = [TPViewUtil viewWithFrame:CGRectMake(0, detail.bottom + 15, self.view.width - 60, 1) color:LIST_SECTION_BACKGROUND_COLOR];
    UIView *seperatiorLineVertical = [TPViewUtil viewWithFrame:CGRectMake((self.view.width - 60) / 2, detail.bottom + 15, 1, 55) color:LIST_SECTION_BACKGROUND_COLOR];
    
    [self.view addSubview:contentView];
    [contentView addSubview:titleLable];
    [contentView addSubview:detail];
    [contentView addSubview:cancelButton];
    [contentView addSubview:confirmButton];
    [contentView addSubview:seperatiorLine];
    [contentView addSubview:seperatiorLineVertical];
    
    CGFloat titleWidth =  [titleLable.text sizeWithAttributes:@{NSFontAttributeName : titleLable.font}].width;
    double titleMaxWidth = APP_CONTENT_WIDTH - 120;
    titleWidth = titleWidth > titleMaxWidth ? titleMaxWidth : titleWidth;
    titleLable.frame = CGRectMake((self.view.width - 60 - titleWidth)/2, 20, titleWidth, 25);
    
    contentView.height = 60 + 30 + 15 + 25 + detail.height;
    contentView.frame = CGRectMake(30, (APP_SCREEN_HEIGHT - contentView.height) / 2, self.view.width - 60, contentView.height);
    
    // 做动画
    [self readyToAnimate:contentView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentAnimation];
    });
}

-(void)cancelAgreeButtonTap{
//    [self dismissViewControllerAnimated:self completion:nil];
    [self.delegate onRejectButtonTap];
}

-(void)agreeButtonTap{
    [self dismissViewControllerAnimated:self completion:nil];
    [self.delegate onAgreeButtonTap];
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
