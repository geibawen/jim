//
//  FVShareViewController.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/22.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "FVShareViewController.h"
#import "FVShareView.h"

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface FVShareViewController () <FVShareViewDelegate,MFMessageComposeViewControllerDelegate, FBSDKSharingDelegate>

@end

@implementation FVShareViewController

+ (void)showAlertFromViewController:(UIViewController *)fromVC{
    FVShareViewController *alertVC = [[FVShareViewController alloc] init];
    alertVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alertVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [fromVC presentViewController:alertVC animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];

    [self initView];
}

- (void)initView {
    FVShareView *shareView = [[FVShareView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT)];
    shareView.delegate = self;
    shareView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:shareView];

    [self readyToAnimate:shareView.contentView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentAnimation];
    });
}

- (void)backgroundButtonTap:(nonnull FVShareView *)shareView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)copyButtonTap:(nonnull FVShareView *)shareView {
    NSLog(@"share copy");
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = SHARE_LINK;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"share_copy_pastboard_success", nil);
    hud.mode = MBProgressHUDModeText;
    [hud hideAnimated:YES afterDelay:1.5];
}

- (void)facebookButtonTap:(nonnull FVShareView *)shareView {
    NSLog(@"share fb");
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:SHARE_LINK];
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:self];
}

- (void)messengerButtonTap:(nonnull FVShareView *)shareView {
    FBSDKShareMessengerURLActionButton *urlButton = [[FBSDKShareMessengerURLActionButton alloc] init];
    urlButton.title = NSLocalizedString(@"app_name", nil);
    urlButton.url = [NSURL URLWithString:SHARE_LINK];
    
    FBSDKShareMessengerGenericTemplateElement *element = [[FBSDKShareMessengerGenericTemplateElement alloc] init];
    element.title = NSLocalizedString(@"app_name", nil);
    element.subtitle = NSLocalizedString(@"app_slogan", nil);
    element.imageURL = [NSURL URLWithString:@"https://fastervpn.oss-cn-hongkong.aliyuncs.com/gp_1200.png"];
    element.button = urlButton;
    
    FBSDKShareMessengerGenericTemplateContent *content = [[FBSDKShareMessengerGenericTemplateContent alloc] init];
    // TODO: Your page ID, required for attribution
    content.pageID = @"668522903600843";
    content.element = element;
    
    FBSDKMessageDialog *messageDialog = [[FBSDKMessageDialog alloc] init];
    messageDialog.shareContent = content;
    
    if ([messageDialog canShow]) {
        [messageDialog show];
    }else{
        [self openMorePanel];
    }
}

- (void)moreButtonTap:(nonnull FVShareView *)shareView {
    NSLog(@"share more");
    [self openMorePanel];
}

- (void)openMorePanel{
    NSString *textToShare = NSLocalizedString(@"app_slogan", nil);
    //分享的图片
    //    UIImage *imageToShare = [UIImage imageNamed:@"312.jpg"];
    //分享的url
    NSURL *urlToShare = [NSURL URLWithString:SHARE_LINK];
    //在这里呢 如果想分享图片 就把图片添加进去  文字什么的通上
    NSArray *activityItems = @[textToShare, urlToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    //不出现在活动项目
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityVC animated:YES completion:nil];
    // 分享之后的回调
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            NSLog(@"completed");
            //分享 成功
        } else  {
            NSLog(@"cancled");
            //分享 取消
        }
    };
}

- (void)msgButtonTap:(nonnull FVShareView *)shareView {
    NSLog(@"share msg");
    if( [MFMessageComposeViewController canSendText] ) {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        //接收人,可以有很多,放入数组
        //controller.recipients = [NSArray arrayWithObject:@"10000"];
        controller.body = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"app_slogan", nil), SHARE_LINK];
        controller.view.frame=CGRectMake(0, 0, 320, 640);
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        NSLog(@"cannot send text");
        [self openMorePanel];
    }
}

- (void)whatsappButtonTap:(nonnull FVShareView *)shareView {
    NSLog(@"share whatsapp");
    NSString *msg = SHARE_LINK;
    NSString *url = [NSString stringWithFormat:@"whatsapp://send?text=%@", [msg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    NSURL *whatsappURL = [NSURL URLWithString: url];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        NSLog(@"Cannot open whatsapp");
        [self openMorePanel];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [tp_topMostViewController() dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FBSDKSharingDelegate

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary<NSString *,id> *)results{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"share_success", nil);
    hud.mode = MBProgressHUDModeText;
    [hud hideAnimated:YES afterDelay:1.5];
}
-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"share_fail", nil);
    hud.mode = MBProgressHUDModeText;
    [hud hideAnimated:YES afterDelay:1.5];
}
-(void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"share_fail", nil);
    hud.mode = MBProgressHUDModeText;
    hud.mode = MBProgressHUDModeText;
    [hud hideAnimated:YES afterDelay:1.5];
}

@end
