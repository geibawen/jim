//
//  FVBuyVipModel.h
//  VPNFaster
//
//  Created by jianbin on 2019/5/18.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FVBuyVipModel : NSObject

@property (nonatomic, strong) NSString     *productId;
@property (nonatomic, strong) NSString     *productName;
@property (nonatomic, strong) NSString     *productDescription;
@property (nonatomic, assign) float        price;
@property (nonatomic, strong) NSString     *priceSymbol;
@property (nonatomic, assign) NSInteger    sort;
@property (nonatomic, assign) BOOL         subscribed;


@end

NS_ASSUME_NONNULL_END
