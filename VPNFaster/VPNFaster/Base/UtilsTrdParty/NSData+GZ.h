//
//  NSData+GZ.h
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2018/10/25.
//  Copyright © 2018年 xuchengcheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (GZ)

// gzip compression utilities
- (NSData *)gzipInflate;
- (NSData *)gzipDeflate;

@end
