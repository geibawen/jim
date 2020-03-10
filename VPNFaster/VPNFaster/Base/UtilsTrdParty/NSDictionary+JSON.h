//
//  NSDictionary+JSON.h
//  JuCaiShengHuo
//
//  Created by ideago on 16/4/18.
//  Copyright © 2016年 ideago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

- (NSString *)toJSONString;

+ (NSDictionary *)dictionaryWithJson:(NSString *)json;

@end
