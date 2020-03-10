//
//  RRProductModel.h
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2019/3/3.
//  Copyright © 2019年 sunjianbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

typedef NS_OPTIONS(NSUInteger, PluginStatus) {
    PluginStatusNotDownloaded             = 0,
    PluginStatusDownloaded      = 1,
    PluginStatusUpgrading       = 2,
    PluginStatusDownloading      = 3,
};

@interface ServerModel : BaseModel

@property (nonatomic, assign) NSInteger    serverId;

@property (nonatomic, strong) NSString *area;

@property (nonatomic, strong) NSString *host;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *psk;

@property (nonatomic, strong) NSString *status;

@property (nonatomic, strong) NSString *icon;

@property (nonatomic, assign) BOOL  vip;

@end
