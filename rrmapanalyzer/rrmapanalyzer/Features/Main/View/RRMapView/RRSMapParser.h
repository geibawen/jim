//
//  RRSMapParser.h
//  rrmapanalyzer
//
//  Created by jianbin on 2020/12/14.
//  Copyright © 2020 jim. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRSMapParser : NSObject

+ (instancetype)sharedInstance;

- (void)parse:(NSURL *)url result:(void (^)(NSDictionary *result))result;

@end

NS_ASSUME_NONNULL_END
