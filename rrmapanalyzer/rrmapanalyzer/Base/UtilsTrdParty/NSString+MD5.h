//
//  NSString+MD5.h
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2019/3/16.
//  Copyright © 2019年 sunjianbin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MD5)

// MD5的32位小写加密
- (NSString*)MD5_32BitLower;

// MD5的32位大写加密
- (NSString*)MD5_32BitUpper;

@end

NS_ASSUME_NONNULL_END
