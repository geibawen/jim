//
//  ProductModel.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/15.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "ProductModel.h"

@implementation ProductModel

/*
 items =         (
 {
 discount = 8;
 duration = 1;
 durationUnit = MONTH;
 freeDays = 3;
 id = 1;
 itemId = "VPN_1MONTH";
 price = "9.9";
 sort = 1;
 }
 );
 */
//- (void)encodeWithCoder:(NSCoder *)encoder {
//    [encoder encodeInteger:self.pId forKey:@"pId"];
//    [encoder encodeFloat:self.discount forKey:@"discount"];
//    [encoder encodeInteger:self.duration forKey:@"duration"];
//    [encoder encodeObject:self.durationUnit forKey:@"durationUnit"];
//    [encoder encodeInteger:self.freeDays forKey:@"freeDays"];
//    [encoder encodeObject:self.productId forKey:@"productId"];
//    [encoder encodeObject:self.price forKey:@"price"];
//    [encoder encodeInteger:self.sort forKey:@"sort"];
//}
//
//- (id)initWithCoder:(NSCoder *)decoder {
//    if((self = [super init])) {
//        self.pId = [decoder decodeIntegerForKey:@"pId"];
//        self.discount = [decoder decodeFloatForKey:@"discount"];
//        self.duration = [decoder decodeIntegerForKey:@"duration"];
//        self.durationUnit = [decoder decodeObjectForKey:@"durationUnit"];
//        self.freeDays = [decoder decodeIntegerForKey:@"freeDays"];
//        self.productId = [decoder decodeObjectForKey:@"productId"];
//        self.price = [decoder decodeObjectForKey:@"price"];
//        self.sort = [decoder decodeIntegerForKey:@"sort"];
//    }
//    return self;
//}
- (NSComparisonResult)compare:(ProductModel *)model {
    if (self.sort > model.sort) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

@end
