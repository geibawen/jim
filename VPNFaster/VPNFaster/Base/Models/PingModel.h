//
//  PingModel.h
//  VPNFaster
//
//  Created by 何永军 on 2019/5/22.
//  Copyright © 2019 roborock. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PingModel : BaseModel

@property (nonatomic, assign) NSInteger serverId;

@property (nonatomic, assign) float pingValue;

@end

NS_ASSUME_NONNULL_END
