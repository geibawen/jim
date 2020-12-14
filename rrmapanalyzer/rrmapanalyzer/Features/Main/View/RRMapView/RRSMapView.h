//
//  RRSMapView.h
//  rrmapanalyzer
//
//  Created by jianbin on 2020/12/10.
//  Copyright © 2020 jim. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRSMapView : UIView

@property (nonatomic, strong) UIImageView                     *mapImageView;

/**
*  设置地图文件Url
*
*  @param url 地图文件Url
*/
- (void)setMapFileUrl:(NSURL *)url;

/**
*  设置路径文件Url
*
*  @param url 路径文件Url
*/
- (void)setPathFileUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
