//
//  FVPolicyViewController.h
//  VPNFaster
//
//  Created by 何永军 on 2019/5/25.
//  Copyright © 2019 roborock. All rights reserved.
//

#import "TPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN


@protocol FVPolicyViewControllerDelegate <NSObject>

- (void)onRejectButtonTap;
- (void)onAgreeButtonTap;

@end

@interface FVPolicyViewController : UIViewController

@property (nonatomic, weak) id<FVPolicyViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
