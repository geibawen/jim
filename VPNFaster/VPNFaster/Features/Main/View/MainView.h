//
//  MainView.h
//  VPNFaster
//
//  Created by jianbin on 2019/5/11.
//  Copyright © 2019年 roborock. All rights reserved.
//

typedef NS_OPTIONS(NSUInteger, ButtonStatus) {
    ButtonStatusInitial             = 0,
    ButtonStatusConnecting          = 1,
    ButtonStatusConnected           = 2,
    ButtonStatusDisconnecting       = 3,
    ButtonStatusDisconnected        = 4,
};

#import <UIKit/UIKit.h>
#import "ZZCircleProgress.h"

NS_ASSUME_NONNULL_BEGIN

@class MainView;

@protocol MainViewDelegate <NSObject>

- (void)mainViewConnectButtonTap:(MainView *)mainView;

@end

@interface MainView : UIView

@property(nonatomic,strong) UITableView *settingTableView;

@property (nonatomic, weak) id<MainViewDelegate> delegate;

@property (nonatomic, assign) ButtonStatus                        buttonStatus;
@property (nonatomic, assign) float                        progress;

@property (nonatomic, strong) ZZCircleProgress               *circularView;

//- (void)startAnimation;
//- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
