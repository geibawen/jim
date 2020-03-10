//
//  NSData+RRAES.h
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2019/4/28.
//  Copyright © 2019年 sunjianbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (RRAES)

- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv;

@end
