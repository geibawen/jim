//
//  MainView.m
//  TuyaSmart
//
//  Created by jianbin on 15/2/28.
//  Copyright (c) 2019年
//

#define Timeout 5

#import "MainView.h"
#import <DACircularProgress/DALabeledCircularProgressView.h>

@interface MainView()

@property (nonatomic, strong) UIImageView                    *topBgView;
@property (nonatomic, strong) UILabel                        *topLabel;

@property (nonatomic, strong) UIImageView                    *onOffImage;
@property (nonatomic, strong) UILabel                        *topButtonLabel;



@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate  *fireDate;

@end

@implementation MainView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self addSubview:self.topBgView];
    [self.topBgView addSubview:self.topLabel];
    [self.topBgView addSubview:self.circularView];
    [self.topBgView addSubview:self.topButtonLabel];
    
    [self.circularView addSubview:self.onOffImage];
    
    [self addSettingTableView];
    
    return self;
}

//- (void)setProgress:(float)progress {
//    _progress = progress;
//    [self.circularView setProgress:progress animated:NO];
//}

- (void)setButtonStatus:(ButtonStatus)buttonStatus {
    _buttonStatus = buttonStatus;
    switch (buttonStatus) {
        case ButtonStatusInitial:
//            [self stopAnimation];
//            self.progress = 0;
            [self.onOffImage setImage:[UIImage imageNamed:@"index_icon_link"]];
            self.topButtonLabel.text = NSLocalizedString(@"click_to_link", nil);
            break;
        case ButtonStatusConnected:
//            [self stopAnimation];
//            self.progress = 1.0;
            [self.onOffImage setImage:[UIImage imageNamed:@"index_icon_dk"]];
            self.topButtonLabel.text = NSLocalizedString(@"click_to_disconnect", nil);
            break;
        case ButtonStatusConnecting:
            [self.onOffImage setImage:[UIImage imageNamed:@"index_icon_link"]];
            self.topButtonLabel.text = NSLocalizedString(@"connecting", nil);
            break;
        case ButtonStatusDisconnecting:
            [self.onOffImage setImage:[UIImage imageNamed:@"index_icon_dk"]];
            self.topButtonLabel.text = NSLocalizedString(@"disconnecting", nil);
            break;
        default:
            break;
    }
}

- (UIImageView *)topBgView {
    if (!_topBgView) {
        _topBgView = [TPViewUtil imageViewWithFrame:CGRectMake(0, 0, self.width, self.width * 0.96 + APP_NOT_SAFE_AREA_TOP) imageName:@"index_bg"];
        _topBgView.userInteractionEnabled = YES;
    }
    return _topBgView;
}

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [TPViewUtil labelWithFrame:CGRectMake((self.width - 250) / 2, 40 + APP_NOT_SAFE_AREA_TOP, 250, 25) fontSize:23 color:[UIColor whiteColor]];
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        _topLabel.text = appName;
        _topLabel.font = [UIFont fontWithName:@"Verdana-BoldItalic" size:26];
        _topLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _topLabel;
}

- (ZZCircleProgress *)circularView {
    if (!_circularView) {
        _circularView = [[ZZCircleProgress alloc] initWithFrame:CGRectMake((self.width - 125) / 2, (self.topBgView.height - 125) / 2, 125, 125)];
//        _circularView.pointImage.image = [UIImage imageNamed:@"test"];//设置小圆点图片
        _circularView.backgroundColor = [UIColor whiteColor];
        _circularView.layer.cornerRadius = 125 / 2;
        _circularView.strokeWidth = 4;
        _circularView.duration = 0.36;//动画时长。默认为1.5
        _circularView.showPoint = NO;//是否显示默认小圆点。默认为YES
        _circularView.showProgressText = NO;//是否显示默认进度文本。默认为YES
        _circularView.increaseFromLast = YES;
        _circularView.pathBackColor = [UIColor whiteColor];
        _circularView.pathFillColor = HEXCOLOR(0x00f1e3);
        _circularView.startAngle = 90;
        _circularView.progress = 0;
        
        _circularView.userInteractionEnabled = YES;
        [_circularView addGestureRecognizer:[TPViewUtil singleFingerClickRecognizer:self sel:@selector(connectButtonTap)]];
        
//        _circularView.progressLabel.font = [UIFont systemFontOfSize:14];
//        _circularView.progressLabel.textColor = MAIN_COLOR;
    }
    return _circularView;
}

- (UIImageView *)onOffImage {
    if (!_onOffImage) {
        _onOffImage = [TPViewUtil imageViewWithFrame:CGRectMake(35, 35, 54, 54) imageName:@"index_icon_link"];
        _onOffImage.userInteractionEnabled = YES;
    }
    return _onOffImage;
}

- (UILabel *)topButtonLabel {
    if (!_topButtonLabel) {
        _topButtonLabel = [TPViewUtil labelWithFrame:CGRectMake(0, self.circularView.bottom + 15, self.width, 25) fontSize:19 color:[UIColor whiteColor]];
        _topButtonLabel.text = NSLocalizedString(@"click_to_link", nil);
        _topButtonLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _topButtonLabel;
}

-(void)addSettingTableView {
    _settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topBgView.bottom, self.width, self.height - self.topBgView.height) style:UITableViewStylePlain];
    _settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _settingTableView.allowsSelection = NO;
    _settingTableView.backgroundColor = MAIN_BACKGROUND_COLOR;
    _settingTableView.scrollEnabled = NO;
    
    [self addSubview:_settingTableView];
}

- (void)connectButtonTap {
    if ([self.delegate respondsToSelector:@selector(mainViewConnectButtonTap:)]) {
        [self.delegate mainViewConnectButtonTap:self];
    }
}

@end
