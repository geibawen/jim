//
//  ProductModel.h
//  VPNFaster
//
//  Created by jianbin on 2019/5/15.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductModel : BaseModel

@property (nonatomic, assign) NSInteger    pId;

//@property (nonatomic, assign) float         discount;
//@property (nonatomic, assign) NSInteger     duration;
//@property (nonatomic, strong) NSString      *durationUnit;
//@property (nonatomic, assign) NSInteger     freeDays;
@property (nonatomic, strong) NSString      *productId;
@property (nonatomic, strong) NSString      *name;
@property (nonatomic, assign) NSInteger     sort;

@end

NS_ASSUME_NONNULL_END
