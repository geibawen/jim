//
//  RRConstantsTypeDefs.h
//  TuyaSmartHomeKit
//
//  Created by jianbin on 2019/1/4.
//  Copyright © 2019年 jianbin. All rights reserved.
//

#ifndef RRConstantsTypeDefs_h
#define RRConstantsTypeDefs_h

#import <Foundation/Foundation.h>

typedef void (^RRSuccessHandler)(void);
typedef void (^RRSuccessDict)(NSDictionary *dict);
typedef void (^RRSuccessString)(NSString *result);
typedef void (^RRSuccessList)(NSArray *list);
typedef void (^RRSuccessBOOL)(BOOL result);
typedef void (^RRSuccessID)(id result);
typedef void (^RRSuccessInt)(int result);
typedef void (^RRSuccessLongLong)(long long result);
typedef void (^RRSuccessData)(NSData *data);

typedef void (^RRFailureHandler)(void);
typedef void (^RRFailureError)(NSError *error);

#endif /* RRConstantsTypeDefs_h */
