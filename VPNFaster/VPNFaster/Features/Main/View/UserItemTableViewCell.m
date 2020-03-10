//
//  UserItemTableViewCell.m
//  TuyaSmart
//
//  Created by fengyu on 15/2/28.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

#import "UserItemTableViewCell.h"
#import "TPItemView.h"

@implementation UserItemTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = MAIN_BACKGROUND_COLOR;
    
    _itemView = [TPItemView itemViewWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 65)];
    //    _itemView.leftLabel.frame = CGRectMake(60, 6, 200, 32);
    _itemView.leftLabel.left = 20;
    _itemView.leftLabel.textColor = LIST_MAIN_TEXT_COLOR;
    _itemView.leftLabel.font = [UIFont systemFontOfSize:17];
    [_itemView showRightArrow];
    [self addSubview:_itemView];
    
    return self;
}

-(void)setUp:(MenuItem *)item {
    _itemView.rightArrow.hidden = !item.showRightArrow;
    if (item.height) {
        _itemView.height = item.height;
    }
//    _itemView.leftImage = item.icon;
    if (item.icon) {
        _itemView.leftLabel.left = 55;
        _itemView.leftImage = item.icon;
    }
    if (item.iconUrl) {
        _itemView.leftLabel.left = 55;
        _itemView.leftImage = [UIImage imageNamed:@"mine_icon_share"];
        [_itemView.leftImageView sd_setImageWithURL:[NSURL URLWithString:item.iconUrl]];
        _itemView.leftLabel.font = [UIFont systemFontOfSize:16];
    }
    _itemView.leftLabel.text = item.title;
    if (item.subTitle) {
        _itemView.leftSubLabel.left = 20;
        if (item.icon) {
            _itemView.leftSubLabel.left = 55;
        }
        _itemView.leftSubLabel.text = item.subTitle;
    }
    if (item.rightTitle) {
        _itemView.rightLabel.text = item.rightTitle;
    }
    if (item.rightSubTitle) {
        _itemView.rightSubLabel.text = item.rightSubTitle;
    }
    if (item.rightTitleColor) {
        _itemView.rightLabel.textColor = item.rightTitleColor;
    }
    if (item.iconCenter) {
        _itemView.centerImage = item.iconCenter;
    }
    if (item.iconRight) {
        _itemView.rightImage = item.iconRight;
    }
    if (item.iconRightUrl) {
        _itemView.rightImageUrl = item.iconRightUrl;
    }
    if (item.iconRightArray) {
        _itemView.rightImageArray = item.iconRightArray;
    }
    

    switch (item.type) {
        case MenuItemTypeFirst:{
            _itemView.topLine.hidden    = NO;
            _itemView.middleLine.hidden = NO;
            _itemView.bottomLine.hidden = YES;
            break;
        }
        case MenuItemTypeLast: {
            _itemView.topLine.hidden    = YES;
            _itemView.middleLine.hidden = YES;
            _itemView.bottomLine.hidden = NO;
            break;
        }
        default: {
            _itemView.topLine.hidden    = YES;
            _itemView.middleLine.hidden = NO;
            _itemView.bottomLine.hidden = YES;
            break;
        }
    }
}

@end
