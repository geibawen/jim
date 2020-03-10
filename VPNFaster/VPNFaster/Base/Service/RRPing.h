//
//  RRPing.h
//  VPNFaster
//
//  Created by 何永军 on 2019/5/22.
//  Copyright © 2019 roborock. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RRPing : BaseModel

@property (nonatomic, strong) NSArray  *pings;

/**
 *  单例
 */
+ (instancetype)sharedInstance;

- (void)saveWithServerId:(NSInteger) serverId PingValue:(float) pingValue;

- (float)getPingValueByServerId:(NSInteger) serverId;

@end

NS_ASSUME_NONNULL_END
