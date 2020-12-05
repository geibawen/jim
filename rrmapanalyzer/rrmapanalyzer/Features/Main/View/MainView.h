//
//  MainView.h
//  VPNFaster
//
//  Created by jianbin on 2019/5/11.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MainView;

@protocol MainViewDelegate <NSObject>

- (void)mainViewConnectButtonTap:(MainView *)mainView;

@end

@interface MainView : UIView

@property (nonatomic, weak) id<MainViewDelegate> delegate;

@property (nonatomic, strong) UILabel                     *usageInfoLabel;
@property (nonatomic, strong) UIImageView                 *mapImageView;

@end

NS_ASSUME_NONNULL_END
