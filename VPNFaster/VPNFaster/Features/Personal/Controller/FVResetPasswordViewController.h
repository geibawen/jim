//
//  FVResetPasswordViewController.h
//  VPNFaster
//
//  Created by 何永军 on 2019/5/25.
//  Copyright © 2019 roborock. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FVResetPasswordViewController;

@protocol FVResetPasswordViewControllerDelegate <NSObject>

-(void)onPasswordReseted;

@end

@interface FVResetPasswordViewController : UIViewController

@property (nonatomic, weak) id<FVResetPasswordViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
