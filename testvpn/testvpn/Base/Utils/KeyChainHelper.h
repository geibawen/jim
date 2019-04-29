//
//  KeyChainHelper.h
//  testvpn
//
//  Created by jianbin on 2019/4/29.
//  Copyright © 2019年 jianbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainHelper : NSObject
+ (OSStatus)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (OSStatus)delete:(NSString *)service;
@end
