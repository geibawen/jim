//
//  RRProgressView.m
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2019/4/23.
//  Copyright © 2019年 sunjianbin. All rights reserved.
//

#import "RRProgressView.h"

@interface RRProgressView()

@property (nonatomic, strong) UIView          *maskAlertView;
@property (nonatomic, strong) UIView          *contentView;
@property (nonatomic, strong) UILabel         *titleLable;
@property (nonatomic, strong) UIProgressView  *progressView;
@property (nonatomic, strong) UIButton        *cancelButton;

@end

@implementation RRProgressView

- (instancetype)initWithTitle:(NSString *)titleText cancelButtonText:(NSString *)cancelButtonText {
    self = [super initWithFrame:CGRectMake(0, 0, 1, 1)];
    if (self) {
        _titleText = titleText;
        _cancelButtonText = cancelButtonText;
        
        [self.maskAlertView addSubview:self.contentView];
        [self.contentView addSubview:self.titleLable];
        [self.contentView addSubview:self.progressView];
        [self.contentView addSubview:self.cancelButton];
    }
    return self;
}

- (UIView *)maskAlertView {
    if (!_maskAlertView) {
        _maskAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT)];
        _maskAlertView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _maskAlertView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(15, APP_SCREEN_HEIGHT - 17 - 144, APP_SCREEN_WIDTH - 30, 144)];
        _contentView.backgroundColor = MAIN_BACKGROUND_COLOR;
        [_contentView.layer setCornerRadius:4.0];
    }
    return _contentView;
}

- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [TPViewUtil labelWithFrame:CGRectMake(15, 23, self.contentView.width - 30, 18) fontSize:14 color:LIST_LIGHT_TEXT_COLOR];
        _titleLable.text = self.titleText;
        _titleLable.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLable;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(15, self.titleLable.bottom + 15, self.contentView.width - 30, 6)];
        _progressView.layer.cornerRadius = 2;
        _progressView.clipsToBounds = YES;
        _progressView.tintColor = [UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0];
        _progressView.trackTintColor = LIST_SECTION_BACKGROUND_COLOR;
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 3.0f);
        for (UIImageView * imageview in _progressView.subviews) {
            imageview.layer.cornerRadius = 2;
            imageview.clipsToBounds = YES;
        }
    }
    return _progressView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [TPViewUtil buttonWithFrame:CGRectMake((self.contentView.width - 120) / 2, self.progressView.bottom + 31, 120, 34) fontSize:16 bgColor:nil textColor:BUTTON_BACKGROUND_COLOR borderColor:BUTTON_BACKGROUND_COLOR];
        [_cancelButton setTitle:self.cancelButtonText forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(void)cancelButtonTap {
    if ([self.delegate respondsToSelector:@selector(progressViewCancelButtonTap:)]) {
        [self.delegate progressViewCancelButtonTap:self];
    }
}

- (void)setProgress:(double)progress {
    _progress = progress;
    self.progressView.progress = progress;
    self.titleLable.text = [NSString stringWithFormat:@"%@ %.0f％", _titleText, _progress * 100];
}

- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;
    self.titleLable.text = [NSString stringWithFormat:@"%@ %.0f％", _titleText, _progress * 100];
}

- (void)setCancelButtonText:(NSString *)cancelButtonText {
    self.cancelButtonText = cancelButtonText;
    self.cancelButton.titleLabel.text = cancelButtonText;
}

- (void)hideAnimated:(BOOL)animated {
    self.progress = 0;
    [self.maskAlertView removeFromSuperview];
}

- (void)showAnimated:(BOOL)animated {
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskAlertView];
}


@end
