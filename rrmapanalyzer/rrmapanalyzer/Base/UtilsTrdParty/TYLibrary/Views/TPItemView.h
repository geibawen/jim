//
//  TPItemView.h
//  TuyaSmart
//
//  Created by fengyu on 15/9/6.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPItemView;

@protocol TPItemViewDelegate <NSObject>

@optional

- (void)itemViewTap:(TPItemView *)itemView;

- (void)itemViewLeftLabelTap:(TPItemView *)itemView;
- (void)itemViewCenterLabelTap:(TPItemView *)itemView;
- (void)itemViewRightLabelTap:(TPItemView *)itemView;

- (void)itemViewLeftImageTap:(TPItemView *)itemView;
- (void)itemViewCenterImageTap:(TPItemView *)itemView;
- (void)itemViewRightImageTap:(TPItemView *)itemView;

@end

@interface TPItemView : UIView

@property (nonatomic, weak) id<TPItemViewDelegate> delegate;

@property(nonatomic,strong) UIImageView *leftImageView;
@property(nonatomic,strong) UIImageView *centerImageView;
@property(nonatomic,strong) UIImageView *rightImageView;

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *leftSubLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UILabel *rightSubLabel;
@property (nonatomic, strong) UILabel *centerLabel;

@property (nonatomic, strong) UIImage *leftImage;
@property (nonatomic, strong) UIImage *centerImage;
@property (nonatomic, strong) UIImage *rightImage;
@property (nonatomic, strong) NSString *rightImageUrl;

@property (nonatomic, strong) NSArray *rightImageArray;//三张图

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *middleLine;
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, strong) UIImageView *rightArrow;

@property (nonatomic, strong) UISwitch *switchBtn;

+ (TPItemView *)itemViewWithFrame:(CGRect)frame;

- (void)showTopLine;
- (void)showMiddleLine;
- (void)showBottomLine;

- (void)showRightArrow;
- (void)showSwitchBtn;

- (void)setRightLabelWidth:(float)width;

@end
