//
//  FVChooseServerViewController.h
//  VPNFaster
//
//  Created by jianbin on 2019/5/17.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "TPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class FVChooseServerViewController;

@protocol FVChooseServerViewControllerDelegate <NSObject>

- (void)chooseServerViewControllerItemTap:(FVChooseServerViewController *)chooseServer serverId:(NSInteger)serverId;


@end

@interface FVChooseServerViewController : TPBaseViewController

@property (nonatomic, weak) id<FVChooseServerViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
