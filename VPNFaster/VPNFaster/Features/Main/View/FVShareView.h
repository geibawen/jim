//
//  FVShareView.h
//  VPNFaster
//
//  Created by jianbin on 2019/5/22.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FVShareView;

@protocol FVShareViewDelegate <NSObject>

- (void)facebookButtonTap:(FVShareView *)shareView;
- (void)messengerButtonTap:(FVShareView *)shareView;
- (void)whatsappButtonTap:(FVShareView *)shareView;
- (void)msgButtonTap:(FVShareView *)shareView;
- (void)copyButtonTap:(FVShareView *)shareView;
- (void)moreButtonTap:(FVShareView *)shareView;

- (void)backgroundButtonTap:(FVShareView *)shareView;

@end

@interface FVShareView : UIView

@property (nonatomic, weak) id<FVShareViewDelegate> delegate;

@property (nonatomic, strong) UIView                         *contentView;

@end

NS_ASSUME_NONNULL_END
