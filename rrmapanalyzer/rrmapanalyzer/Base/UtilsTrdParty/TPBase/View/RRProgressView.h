//
//  RRProgressView.h
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2019/4/23.
//  Copyright © 2019年 sunjianbin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RRProgressView;

@protocol RRProgressViewDelegate <NSObject>

- (void)progressViewCancelButtonTap:(RRProgressView *)progressView;

@end

@interface RRProgressView : UIView

@property (nonatomic, weak) id<RRProgressViewDelegate> delegate;

@property (nonatomic, strong) NSString                 *cancelButtonText;
@property (nonatomic, strong) NSString                 *titleText;
@property (nonatomic, assign) double                   progress;

- (void)hideAnimated:(BOOL)animated;
- (void)showAnimated:(BOOL)animated;

- (instancetype)initWithTitle:(NSString *)titleText cancelButtonText:(NSString *)cancelButtonText;

@end

NS_ASSUME_NONNULL_END
