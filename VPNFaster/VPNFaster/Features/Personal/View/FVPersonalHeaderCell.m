//
//  FVPersonalHeaderCell.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/16.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "FVPersonalHeaderCell.h"
#import "RRUser.h"

@interface FVPersonalHeaderCell()

@property(nonatomic,strong) UIView      *userInfoView;
@property(nonatomic,strong) UIImageView *headPicImageView;
@property(nonatomic,strong) UILabel     *userNameLabel;
@property(nonatomic,strong) UILabel     *passwordLabel;
@property(nonatomic,strong) UIImageView *rightArrowImageView;

@end

@implementation FVPersonalHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = LIST_SECTION_BACKGROUND_COLOR;
    
    [self addUserInfoView];
    
    return self;
}

- (void)addUserInfoView {
    _userInfoView = [TPViewUtil viewWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 90) color:LIST_SECTION_BACKGROUND_COLOR];
    [_userInfoView addSubview:self.headPicImageView];
    [_userInfoView addSubview:self.userNameLabel];
    [_userInfoView addSubview:self.passwordLabel];
    [self.contentView addSubview:_userInfoView];
}

- (void)refresh{
    _userNameLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"menu_person_username", nil), [[RRUser sharedInstance] userName]];
    _passwordLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"menu_person_password", nil), [[RRUser sharedInstance] password]];
}

- (UIImageView *)headPicImageView {
    if (!_headPicImageView) {
        _headPicImageView = [TPViewUtil imageViewWithFrame:CGRectMake(20, 15, 60, 60) image:[UIImage imageNamed:@"yuan_196"]];
    }
    return _headPicImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [TPViewUtil labelWithFrame:CGRectMake(96, 18, 200, 24) fontSize:15 color:LIST_MAIN_TEXT_COLOR];
    }
    return _userNameLabel;
}

- (UILabel *)passwordLabel {
    if (!_passwordLabel) {
        _passwordLabel = [TPViewUtil labelWithFrame:CGRectMake(96, 48, 200, 24) fontSize:14 color:LIST_SUB_TEXT_COLOR];
    }
    return _passwordLabel;
}

- (UIImageView *)rightArrowImageView {
    if (!_rightArrowImageView) {
        _rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_view_arrow"]];
        _rightArrowImageView.frame = CGRectMake(APP_SCREEN_WIDTH-_rightArrowImageView.width-20, (96 - _rightArrowImageView.height)/2.f, _rightArrowImageView.width, _rightArrowImageView.height);
    }
    return _rightArrowImageView;
}


@end
