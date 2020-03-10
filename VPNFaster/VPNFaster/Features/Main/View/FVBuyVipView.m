//
//  FVPersonalView.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/16.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "FVBuyVipView.h"

@interface FVBuyVipView() <UITextViewDelegate>

@property(nonatomic, strong) TPWebViewController *webViewController;

@end

@implementation FVBuyVipView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self addUserTableView];
    
    return self;
}

- (void)addUserTableView {
    _userTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
    _userTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _userTableView.allowsSelection = NO;
    _userTableView.backgroundColor = MAIN_BACKGROUND_COLOR;
    _userTableView.scrollEnabled = NO;
    
    TPItemView *signoutItemView = [TPItemView itemViewWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_VISIBLE_HEIGHT - 74 * 5 - 110)];
    signoutItemView.topLine.hidden = YES;
    signoutItemView.bottomLine.hidden = YES;
    
    float detailHeight = APP_VISIBLE_HEIGHT - 74 * 5 - 40;
    float detailMinHeight = 150;
    if (detailHeight < detailMinHeight) {
        detailHeight = detailMinHeight;
    }
    UITextView *detail = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, APP_SCREEN_WIDTH - 40, detailHeight)];
    detail.backgroundColor = MAIN_BACKGROUND_COLOR;
    detail.font = [UIFont systemFontOfSize:16];
    //        detail.textAlignment = NSTextAlignmentCenter;
    detail.delegate = self;
    detail.editable = NO;
    detail.scrollEnabled = YES;
    detail.textColor = HEXCOLOR(0x444444);
    //detail.textContainer.lineFragmentPadding 会看到UItextView左右各有5个点padding，上下各有8个点的inset
    //要把上下的inset设置成0，左右的如果是0的话是表示到边界也就是padding的值，要设置成负的才行
    detail.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
    
    NSString *policy = NSLocalizedString(@"privacy_policy", nil);
    NSString *agreement = NSLocalizedString(@"terms_of_service", nil);
    NSString *detailText = [NSString stringWithFormat:NSLocalizedString(@"main_vip_desc_detail", nil), policy, agreement];
    
    NSMutableAttributedString *myStr = [[NSMutableAttributedString alloc] initWithString:detailText attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    
    NSMutableParagraphStyle *paragraphStyleFirst = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleFirst setLineSpacing:1];
    [paragraphStyleFirst setParagraphSpacing:0];
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
    [signoutItemView addSubview:detail];
    
    _userTableView.tableFooterView = signoutItemView;
    
    [self addSubview:_userTableView];
    _userTableView.tableFooterView.hidden = YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSLog(@"shouldInteractWithURL");
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
    [ViewControllerUtils presentViewController:_webViewController from:self.viewController];
}

-(void)close{
    [_webViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
