//
//  VPNHelper.h
//  VPNFaster
//
//  Created by jianbin on 2019/5/12.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VPNHelper : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NEVPNManager    *manager;

- (void)createPreferenceWithIp:(NSString *)ip psk:(NSString *)psk account:(NSString *)account password:(NSString *)password completion:(void (^)(NSError *error))completion;

- (void)connect:(void (^)(NSError *error))completion;

- (void)disconnect;

- (void)getStatus:(void (^)(NEVPNStatus status))callback;

@end

NS_ASSUME_NONNULL_END
