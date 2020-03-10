//
//  FVShareView.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/22.
//  Copyright © 2019年 roborock. All rights reserved.
//

#define BANNER_WIDTH (self.width - 60)
#define BANNER_HEIGHT (BANNER_WIDTH * 0.488)
#define ITEM_WIDTH ((BANNER_WIDTH - 60)/5)

#import "FVShareView.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

@interface FVShareView() <MFMessageComposeViewControllerDelegate>

@end

@implementation FVShareView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView{
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(30, self.height - 300, APP_SCREEN_WIDTH - 60, 250)];
    _contentView.backgroundColor = MAIN_BACKGROUND_COLOR;
    [_contentView.layer setCornerRadius:8.0];
    _contentView.clipsToBounds = YES;
    
    UIImageView *bannerView = [TPViewUtil imageViewWithFrame:CGRectMake(0, 0, BANNER_WIDTH, BANNER_HEIGHT) imageName:@"share_banner"];
    
    UILabel *titleLable = [TPViewUtil labelWithFrame:CGRectMake(0, bannerView.bottom + 20, APP_SCREEN_WIDTH - 60, 25) fontSize:18 color:LIST_MAIN_TEXT_COLOR];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = NSLocalizedString(@"menu_current_share", nil);
    
    UITextView *detail = [[UITextView alloc] initWithFrame:CGRectMake(15, titleLable.bottom + 15, APP_SCREEN_WIDTH - 90, 30)];
    detail.backgroundColor = MAIN_BACKGROUND_COLOR;
    detail.font = [UIFont systemFontOfSize:16];
    detail.editable = NO;
    detail.scrollEnabled = NO;
    detail.textColor = HEXCOLOR(0x444444);
    //detail.textContainer.lineFragmentPadding 会看到UItextView左右各有5个点padding，上下各有8个点的inset
    //要把上下的inset设置成0，左右的如果是0的话是表示到边界也就是padding的值，要设置成负的才行
    detail.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
    
    NSString *detailText = NSLocalizedString(@"menu_current_share_detail", nil);
    NSMutableAttributedString *myStr = [[NSMutableAttributedString alloc] initWithString:detailText attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    
    NSMutableParagraphStyle *paragraphStyleFirst = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleFirst setLineSpacing:4];
    [paragraphStyleFirst setParagraphSpacing:0];
    [paragraphStyleFirst setFirstLineHeadIndent:0.0];
    [paragraphStyleFirst setAlignment:NSTextAlignmentJustified];
    
    [myStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyleFirst range:NSMakeRange(0, detailText.length)];
    
    detail.attributedText = myStr;
    
    CGSize maxSize = CGSizeMake(APP_SCREEN_WIDTH - 90, 600);
    CGRect contentRect = [myStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    detail.frame = CGRectMake(detail.frame.origin.x, detail.frame.origin.y, detail.width, contentRect.size.height);
    
    /****分割线****/
    /****Facebook****/
    UIButton *facebookButton = [TPViewUtil buttonWithFrame:CGRectMake(30, detail.bottom + 20, ITEM_WIDTH, ITEM_WIDTH) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x1f99ef) borderColor:nil];
    [facebookButton setImage:[UIImage imageNamed:@"share_appicon_facebook"] forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(facebookButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *fbLable = [TPViewUtil labelWithFrame:CGRectMake(0, facebookButton.bottom, 100, 20) fontSize:15 color:LIST_MAIN_TEXT_COLOR];
    fbLable.centerX = facebookButton.centerX;
    fbLable.textAlignment = NSTextAlignmentCenter;
    fbLable.text = @"Facebook";
    
    /****Messenger****/
    UIButton *messengerButton = [TPViewUtil buttonWithFrame:CGRectMake(30 + ITEM_WIDTH * 2, detail.bottom + 20, ITEM_WIDTH, ITEM_WIDTH) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x1f99ef) borderColor:nil];
    [messengerButton setImage:[UIImage imageNamed:@"share_appicon_messenger"] forState:UIControlStateNormal];
    [messengerButton addTarget:self action:@selector(messengerButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *messengerLable = [TPViewUtil labelWithFrame:CGRectMake(0, facebookButton.bottom, 100, 20) fontSize:15 color:LIST_MAIN_TEXT_COLOR];
    messengerLable.centerX = messengerButton.centerX;
    messengerLable.textAlignment = NSTextAlignmentCenter;
    messengerLable.text = @"Messenger";
    
    /****Whatsapp****/
    UIButton *whatsappButton = [TPViewUtil buttonWithFrame:CGRectMake(30 + ITEM_WIDTH * 4, detail.bottom + 20, ITEM_WIDTH, ITEM_WIDTH) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x1f99ef) borderColor:nil];
    [whatsappButton setImage:[UIImage imageNamed:@"share_appicon_whatsapp"] forState:UIControlStateNormal];
    [whatsappButton addTarget:self action:@selector(whatsappButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *whatsappLable = [TPViewUtil labelWithFrame:CGRectMake(0, whatsappButton.bottom, 100, 20) fontSize:15 color:LIST_MAIN_TEXT_COLOR];
    whatsappLable.centerX = whatsappButton.centerX;
    whatsappLable.textAlignment = NSTextAlignmentCenter;
    whatsappLable.text = @"Whatsapp";
    
    /****Msg****/
    UIButton *msgButton = [TPViewUtil buttonWithFrame:CGRectMake(30, fbLable.bottom + 15, ITEM_WIDTH, ITEM_WIDTH) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x1f99ef) borderColor:nil];
    [msgButton setImage:[UIImage imageNamed:@"share_appicon_xinxi"] forState:UIControlStateNormal];
    [msgButton addTarget:self action:@selector(msgButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *msgLable = [TPViewUtil labelWithFrame:CGRectMake(0, msgButton.bottom, 100, 20) fontSize:15 color:LIST_MAIN_TEXT_COLOR];
    msgLable.centerX = msgButton.centerX;
    msgLable.textAlignment = NSTextAlignmentCenter;
    msgLable.text = NSLocalizedString(@"menu_current_share_msg", nil);
    
    /****Copy****/
    UIButton *copyButton = [TPViewUtil buttonWithFrame:CGRectMake(30 + ITEM_WIDTH * 2, messengerLable.bottom + 15, ITEM_WIDTH, ITEM_WIDTH) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x1f99ef) borderColor:nil];
    [copyButton setImage:[UIImage imageNamed:@"share_appicon_fuzhi"] forState:UIControlStateNormal];
    [copyButton addTarget:self action:@selector(copyButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *copyLable = [TPViewUtil labelWithFrame:CGRectMake(0, copyButton.bottom, 100, 20) fontSize:15 color:LIST_MAIN_TEXT_COLOR];
    copyLable.centerX = copyButton.centerX;
    copyLable.textAlignment = NSTextAlignmentCenter;
    copyLable.text = NSLocalizedString(@"menu_current_share_copy", nil);
    
    /****More****/
    UIButton *moreButton = [TPViewUtil buttonWithFrame:CGRectMake(30 + ITEM_WIDTH * 4, whatsappLable.bottom + 15, ITEM_WIDTH, ITEM_WIDTH) fontSize:18 bgColor:nil textColor:HEXCOLOR(0x1f99ef) borderColor:nil];
    [moreButton setImage:[UIImage imageNamed:@"share_appicon_more"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *moreLable = [TPViewUtil labelWithFrame:CGRectMake(0, moreButton.bottom, 100, 20) fontSize:15 color:LIST_MAIN_TEXT_COLOR];
    moreLable.centerX = moreButton.centerX;
    moreLable.textAlignment = NSTextAlignmentCenter;
    moreLable.text = NSLocalizedString(@"menu_current_share_more", nil);
    
    [self addSubview:_contentView];
    [_contentView addSubview:bannerView];
    [_contentView addSubview:titleLable];
    [_contentView addSubview:detail];
    [_contentView addSubview:facebookButton];
    [_contentView addSubview:fbLable];
    [_contentView addSubview:messengerButton];
    [_contentView addSubview:messengerLable];
    [_contentView addSubview:whatsappButton];
    [_contentView addSubview:whatsappLable];
    [_contentView addSubview:msgButton];
    [_contentView addSubview:msgLable];
    [_contentView addSubview:copyButton];
    [_contentView addSubview:copyLable];
    [_contentView addSubview:moreButton];
    [_contentView addSubview:moreLable];
    
    _contentView.height = moreLable.bottom + 20;
    _contentView.frame = CGRectMake(30, (APP_SCREEN_HEIGHT - _contentView.height) / 2, self.width - 60, _contentView.height);
    
    [_contentView bk_whenTapped:^(){
    }];
    [self bk_whenTapped:^(){
        [self close];
    }];
}

- (void)close {
    if ([self.delegate respondsToSelector:@selector(backgroundButtonTap:)]) {
        [self.delegate backgroundButtonTap:self];
    }
}

- (void)facebookButtonTap {
    if ([self.delegate respondsToSelector:@selector(facebookButtonTap:)]) {
        [self.delegate facebookButtonTap:self];
    }
}

- (void)messengerButtonTap {
    NSLog(@"share messenger");
    if ([self.delegate respondsToSelector:@selector(messengerButtonTap:)]) {
        [self.delegate messengerButtonTap:self];
    }
}

- (void)whatsappButtonTap {
    if ([self.delegate respondsToSelector:@selector(whatsappButtonTap:)]) {
        [self.delegate whatsappButtonTap:self];
    }
}

- (void)msgButtonTap {
    if ([self.delegate respondsToSelector:@selector(msgButtonTap:)]) {
        [self.delegate msgButtonTap:self];
    }
}

- (void)copyButtonTap {
    if ([self.delegate respondsToSelector:@selector(copyButtonTap:)]) {
        [self.delegate copyButtonTap:self];
    }
}

- (void)moreButtonTap {
    if ([self.delegate respondsToSelector:@selector(moreButtonTap:)]) {
        [self.delegate moreButtonTap:self];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [tp_topMostViewController() dismissViewControllerAnimated:YES completion:nil];

}

@end
