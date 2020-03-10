//
//  RRUtilCommon.m
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2018/10/12.
//  Copyright © 2018年 xuchengcheng. All rights reserved.
//
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "RRUtilCommon.h"

@implementation RRUtilCommon

+ (NSString*)getCurrentLanguage{
    // User settings take precedence
    NSString* userLocale = [RRUtilCommon getUserLocale];
    if (userLocale) {
        NSArray *langs = [userLocale componentsSeparatedByString:@"-"];
        if ([langs[0] isEqualToString:@"zh"]) {
            if (langs.count == 3) {
                NSString *result = [NSString stringWithFormat:@"%@-%@", langs[0], langs[1]];
                return result;
            } else {
                return userLocale;
            }
        } else {
            if (langs.count == 1) {
                return userLocale;
            } else {
                NSString * result = [NSString stringWithFormat:@"%@", langs[0]];
                return result;
            }
        }
        return userLocale;
    }
    
    // Device locale
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        NSLocale* currentLocale = [NSLocale currentLocale];
        //return [NSString stringWithFormat:@"%@-%@", currentLocale.languageCode, currentLocale.countryCode];
        return [NSString stringWithFormat:@"%@", currentLocale.languageCode];
    }
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString*)getUserLocale {
    NSArray* locales = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if (locales == nil ) { return nil; }
    if ([locales count] == 0) { return nil; }
    
    NSString* userLocale = locales[0];
    return userLocale;
}

+ (NSString *)hexStringFromString:(NSString *)string {
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i < [myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i]];///16进制数
        if([newHexStr length]==1) {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        } else {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}

//获得重复子字符串的数量
//利用替换先把重复元素替换掉,再根据length长度做判断
+ (NSInteger )getDuplicateSubStrCountInCompleteStr:(NSString *)completeStr withSubStr:(NSString *)subStr {
    NSInteger subStrCount = [completeStr length] - [[completeStr stringByReplacingOccurrencesOfString:subStr withString:@""] length];
    return subStrCount / [subStr length];
}

//获得重复子字符串的位置
//利用切分先得数组,再根据索引计算
+ (NSMutableArray *)getDuplicateSubStrLocInCompleteStr:(NSString *)completeStr withSubStr:(NSString *)subStr {
    NSArray * separatedStrArr = [completeStr componentsSeparatedByString:subStr];
    NSMutableArray * locMuArr = [[NSMutableArray alloc]init];
    
    NSInteger index = 0;
    for (NSInteger i = 0; i<separatedStrArr.count-1; i++) {
        NSString * separatedStr = separatedStrArr[i];
        index = index + separatedStr.length;
        NSNumber * loc_num = [NSNumber numberWithInteger:index];
        [locMuArr addObject:loc_num];
        index = index+subStr.length;
    }
    return locMuArr;
}

+ (void)exitApplication {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self performSelector:@selector(notExistCall)];
    abort();
#pragma clang diagnostic pop
}

+ (NSDictionary *)getDictFromBase64:(NSString *)base64String {
    NSData *encodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *decodedData = [encodedData AES128DecryptWithKey:AES_KEY iv:nil];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    NSInteger length = decodedString.length;
    while (![[decodedString substringWithRange:NSMakeRange([decodedString length] - 1, 1)] isEqualToString:@"}"]) {
        decodedString = [decodedString substringWithRange:NSMakeRange(0, [decodedString length] - 1)];
    }
    NSData *prepareData = [decodedString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:prepareData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end

