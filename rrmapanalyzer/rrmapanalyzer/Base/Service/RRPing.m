//
//  RRPing.m
//  VPNFaster
//
//  Created by 何永军 on 2019/5/22.
//  Copyright © 2019 roborock. All rights reserved.
//

#import "RRPing.h"
#import "PingModel.h"

@implementation RRPing

static RRPing* _instance = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        
        NSData *encodeData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_PING];
        if (!encodeData) {
            _instance = nil;
        }else{
            _instance = [NSKeyedUnarchiver unarchiveObjectWithData:encodeData];
        }
        
        if (!_instance) {
            _instance = [[super allocWithZone:NULL] init];
        }
    }) ;
    
    return _instance ;
}

- (void)saveWithServerId:(NSInteger)serverId PingValue:(float)pingValue{
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", USER_DEFAULT_KEY_PING, [NSNumber numberWithInteger:serverId]];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:pingValue] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)getPingValueByServerId:(NSInteger)serverId{
    NSString *key = [NSString stringWithFormat:@"%@_%@", USER_DEFAULT_KEY_PING, [NSNumber numberWithInteger:serverId]];
    
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (number == nil) {
        return 100;
    }
    return number.floatValue;
}

@end
