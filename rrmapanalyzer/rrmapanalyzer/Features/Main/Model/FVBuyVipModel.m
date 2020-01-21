//
//  FVBuyVipModel.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/18.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "FVBuyVipModel.h"

@implementation FVBuyVipModel

- (NSComparisonResult)compare:(FVBuyVipModel *)model {
    if (self.sort > model.sort) {
        return NSOrderedDescending;
    } else {
        return NSOrderedAscending;
    }
}

@end
