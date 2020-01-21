//
//  MapDetailView.m
//  rrmapanalyzer
//
//  Created by jianbin on 2020/1/21.
//  Copyright © 2020 jim. All rights reserved.
//

#import "MapDetailView.h"

@interface MapDetailView()

@property (nonatomic, strong) UIScrollView                 *scrollView;

@end

@implementation MapDetailView

-(id)initWithFrame:(CGRect)frame withDict:(NSDictionary *)dict {
    self = [super initWithFrame:frame];
    
    [self initView];
    
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor whiteColor];
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(0, 8, self.width, self.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.bounces = YES;
    _scrollView.alwaysBounceVertical = YES;
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).mas_equalTo(0);
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
}

- (void)initContentViewsWithDict:(NSDictionary *)dict {
    UIStackView *wrapperStackView = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    wrapperStackView.axis = UILayoutConstraintAxisVertical;
    wrapperStackView.alignment = UIStackViewAlignmentCenter;
    wrapperStackView.distribution = UIStackViewDistributionFill;
    wrapperStackView.spacing = DEVICE_ITEM_MARGIN;
    [self.scrollView addSubview:wrapperStackView];
    [wrapperStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_topAnimationView.mas_bottom).offset(DEVICE_ITEM_MARGIN);
        make.left.mas_equalTo(self.scrollView);
        make.width.mas_equalTo(self.scrollView);
        make.bottom.mas_equalTo(self.scrollView).offset(-DEVICE_ITEM_MARGIN);
    }];
    
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionFill;
    [wrapperView addArrangedSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(DEVICE_ITEM_HEIGHT);
        make.width.mas_equalTo(self);
    }];
    //左边间隔view
    UIView *startPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_ITEM_MARGIN, 10)];
    startPaddingView.backgroundColor = [UIColor clearColor];
    [stackView addArrangedSubview:startPaddingView];
    [startPaddingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(DEVICE_ITEM_MARGIN);
    }];
    
    RRDeviceListEmptyView *addDeviceView = [[RRDeviceListEmptyView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    addDeviceView.delegate = self;
    [stackView addArrangedSubview:addDeviceView];
    [addDeviceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(DEVICE_ITEM_HEIGHT);
        make.width.mas_equalTo(DEVICE_ITEM_WIDTH);
    }];
    UIView *deviceView2 = [UIView new];
    [stackView addArrangedSubview:deviceView2];
}

@end
