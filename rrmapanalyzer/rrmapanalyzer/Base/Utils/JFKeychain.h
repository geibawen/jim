//
//  JFKeychain.h
//  testvpn
//
//  Created by jianbin on 2019/4/29.
//  Copyright © 2019年 jianbin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFKeychain : NSObject

+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier;
+ (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
