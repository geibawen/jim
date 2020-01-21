//
//  MenuItem.h
//  TuyaSmart
//
//  Created by fengyu on 15/2/28.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, MenuItemType) {
    MenuItemTypeNormal      = 0,
    MenuItemTypeFirst       = 1,
    MenuItemTypeLast        = 2,
    MenuItemTypeSeparator   = 3,
    MenuItemTypeSignOut     = 4,
    MenuItemTypeSeparatorWithTitle = 5
};

@interface MenuItem : NSObject

@property (nonatomic, assign) MenuItemType type;
@property (nonatomic, assign) float        height;
@property (nonatomic, strong) UIImage      *icon;
@property (nonatomic, strong) NSString     *iconUrl;
@property (nonatomic, strong) UIImage      *iconCenter;
@property (nonatomic, strong) UIImage      *iconRight;
@property (nonatomic, strong) NSString     *iconRightUrl;
@property (nonatomic, strong) NSArray      *iconRightArray;
@property (nonatomic, strong) NSString     *title;
@property (nonatomic, strong) NSString     *subTitle;
@property (nonatomic, strong) NSString     *rightTitle;
@property (nonatomic, strong) NSString     *rightSubTitle;
@property (nonatomic, strong) UIColor      *rightTitleColor;
@property (nonatomic, assign) SEL          action;

@property (nonatomic, assign) BOOL         showRightArrow;

@property (nonatomic, assign) NSInteger    dataInt;
@property (nonatomic, strong) NSString     *dataString;

+ (MenuItem *)normalItem:(UIImage *)icon title:(NSString *)title action:(SEL)action showRightArrow:(BOOL)showRightArrow;
+ (MenuItem *)firstItem:(UIImage *)icon title:(NSString *)title action:(SEL)action showRightArrow:(BOOL)showRightArrow;
+ (MenuItem *)lastItem:(UIImage *)icon title:(NSString *)title action:(SEL)action showRightArrow:(BOOL)showRightArrow;
+ (MenuItem *)separatorItem:(float)height;
+ (MenuItem *)signOutItem;
+ (MenuItem *)separatorItem:(float)height title:(NSString *)title;

@end
