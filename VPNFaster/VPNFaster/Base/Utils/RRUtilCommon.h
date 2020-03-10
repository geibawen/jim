//
//  RRUtilCommon.h
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2018/10/12.
//  Copyright © 2018年 xuchengcheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRUtilCommon : NSObject

+ (NSString*)getCurrentLanguage;
+ (NSString *)hexStringFromString:(NSString *)string;

+ (NSInteger )getDuplicateSubStrCountInCompleteStr:(NSString *)completeStr withSubStr:(NSString *)subStr;
+ (NSMutableArray *)getDuplicateSubStrLocInCompleteStr:(NSString *)completeStr withSubStr:(NSString *)subStr;

+ (void)exitApplication;

+ (NSDictionary *)getDictFromBase64:(NSString *)base64String;

@end

NS_ASSUME_NONNULL_END
