//
//  MainView.m
//  TuyaSmart
//
//  Created by jianbin on 15/2/28.
//  Copyright (c) 2019年
//

#define Timeout 5

#import "MainView.h"

@interface MainView()



@end

@implementation MainView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _mapView = [[RRSMapView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self addSubview:_mapView];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(APP_SCREEN_WIDTH);
        make.width.mas_equalTo(self).multipliedBy(1.0);
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self);
    }];
    
    _usageInfoLabel = [TPViewUtil labelWithFrame:CGRectMake(0, 0, 0, 25) fontSize:26 color:LIST_MAIN_TEXT_COLOR];
    _usageInfoLabel.textAlignment = NSTextAlignmentCenter;
    _usageInfoLabel.font = [UIFont systemFontOfSize:18];
    _usageInfoLabel.text = @"请从其他App发送文件到此App";
    [self addSubview:_usageInfoLabel];
    [_usageInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(100);
        make.width.mas_equalTo(self).multipliedBy(0.8);
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(_mapView.mas_bottom).offset(50);
    }];
    
    return self;
}

@end
