//
//  MapDetailView.h
//  rrmapanalyzer
//
//  Created by jianbin on 2020/1/21.
//  Copyright © 2020 jim. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MapDetailView;

@protocol MapDetailViewDelegate <NSObject>

- (void)mainViewConnectButtonTap:(MapDetailView *)mainView;

@end

@interface MapDetailView : UIView

-(id)initWithFrame:(CGRect)frame withDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
