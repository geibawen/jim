//
//  BaseModel.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/16.
//  Copyright © 2019年 roborock. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

// 获取所有属性列表
- (NSArray *)properties {
    NSMutableArray *properties = [NSMutableArray array];
    unsigned int count = 0;
    Ivar *propertyArr = class_copyIvarList([self class], &count);
    objc_property_t *propertyArray = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar property = propertyArr[i];
        const char *propertyNameC = ivar_getName(property);
        NSString *propertyNameOC = [[NSString alloc] initWithCString:propertyNameC encoding:NSUTF8StringEncoding];
        [properties addObject:propertyNameOC];
    }
    free(propertyArray);
    return properties;
}

// 把所有属性归档
- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray *propertyArray = [self properties];
    for (NSString *property in propertyArray) {
        [aCoder encodeObject:[self valueForKey:property] forKey:property];
    }
}

// 对所有属性解档
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        for (NSString *property in [self properties]) {
            [self setValue:[aDecoder decodeObjectForKey:property] forKey:property];
        }
    }
    return self;
}

@end
