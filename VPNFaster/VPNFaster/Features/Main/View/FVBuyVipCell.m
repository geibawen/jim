//
//  UserItemTableViewCell.m
//  TuyaSmart
//
//  Created by fengyu on 15/2/28.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

#import "FVBuyVipCell.h"
#import "TPItemView.h"

@interface FVBuyVipCell()

@property (nonatomic, strong) UIView                     *bgView;
@property (nonatomic, strong) UILabel                    *nameLabel;
@property (nonatomic, strong) UILabel                    *descriptionLabel;
@property (nonatomic, strong) UILabel                    *priceLabel;

@end

@implementation FVBuyVipCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = MAIN_BACKGROUND_COLOR;
    
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.descriptionLabel];
    [self.bgView addSubview:self.priceLabel];
    
    return self;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(20, 15, APP_SCREEN_WIDTH - 40, 59)];
        _bgView.backgroundColor = HEXCOLOR(0x229ff7);
        [_bgView.layer setCornerRadius:8.0];
    }
    return _bgView;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [TPViewUtil labelWithFrame:CGRectMake(15, 6, 250, 25) fontSize:18 color:[UIColor whiteColor]];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}
- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [TPViewUtil labelWithFrame:CGRectMake(15, 30, 250, 25) fontSize:14 color:[UIColor whiteColor]];
        _descriptionLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _descriptionLabel;
}
- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [TPViewUtil labelWithFrame:CGRectMake(APP_SCREEN_WIDTH - 40 - 15 - 85, 15, 85, 29) fontSize:18 color:HEXCOLOR(0x229ff7)];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.backgroundColor = [UIColor whiteColor];
        _priceLabel.layer.cornerRadius = 8;
        _priceLabel.adjustsFontSizeToFitWidth=YES;
        _priceLabel.clipsToBounds = YES;
    }
    return _priceLabel;
}

-(void)setUp:(FVBuyVipModel *)item {
    self.nameLabel.text = item.productName;
    self.descriptionLabel.text = item.productDescription;
    if (item.subscribed == YES) {
        self.priceLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"subscribed", nil)];
    } else {
        self.priceLabel.text = [NSString stringWithFormat:@"%@%.2f", item.priceSymbol, item.price];
    }
}

@end
