//
//  SeparatorTableViewCell.m
//  TuyaSmart
//
//  Created by fengyu on 15/2/28.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

#import "SeparatorTableViewCell.h"

@implementation SeparatorTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = LIST_SECTION_BACKGROUND_COLOR;
    
    return self;
}

-(void)setTitle:(NSString *)title {
    _itemView = [TPItemView itemViewWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 44)];
    _itemView.leftLabel.frame = CGRectMake(20, 19, 200, 20);
    _itemView.leftLabel.textColor = LIST_SUB_TEXT_COLOR;
    _itemView.leftLabel.font = [UIFont systemFontOfSize:14];
    _itemView.leftLabel.text = title;
    _itemView.backgroundColor = LIST_SECTION_BACKGROUND_COLOR;
    
//    [_itemView showRightArrow];

    [self addSubview:_itemView];
    
//    _itemView.topLine.hidden    = YES;
//    _itemView.middleLine.hidden = YES;
//    _itemView.bottomLine.hidden = YES;
}

@end
