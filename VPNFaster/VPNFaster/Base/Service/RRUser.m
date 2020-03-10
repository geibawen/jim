//
//  RRUser.m
//  TuyaSmartHomeKit_Example
//
//  Created by jianbin on 2019/1/4.
//  Copyright © 2019年 xuchengcheng. All rights reserved.
//

#import "RRUser.h"
#import "IGHttpRequestManager.h"
#import "OpenUDID.h"
#import "ServerModel.h"
#import "ProductModel.h"

@implementation RRUser

static RRUser* _instance = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
//        _instance = [[super allocWithZone:NULL] init];
//        [_instance readFromUserDefault];
//        [self remove];
        _instance = [self read];
        _instance.hasPing = NO;
        if (!_instance) {
            _instance = [[super allocWithZone:NULL] init];
        }
    }) ;
    
    return _instance ;
}

/*
{
    message =     {
        code = 200;
        messageInfo = ok;
        serverTime = 1558172763572;
    };
    result =     {
        items =         (
                         {
                             discount = 8;
                             duration = 1;
                             durationUnit = MONTH;
                             freeDays = 3;
                             id = 1;
                             itemId = "VPN_1MONTH";
                             name = "VIP_1_MONTH";
                             sort = 1;
                         }
                         );
        servers =         (
                           {
                               area = HK;
                               host = "47.91.246.135";
                               id = 1;
                               name = "HONGKONG TEST";
                               psk = testtest;
                               status = NORMAL;
                               vip = 0;
                           }
                           );
        user =         {
            id = 4;
            password = 107091;
            token = 9e192c5e7ac24302da956a07fd24bc57;
            userName = 92455797;
            vipPlan =             {
                expiredDate = 1558181328952;
                limit = 200M;
                subscribedItem = "vpn_1month";
                used = 0M;
                userGroup = trail;
            };
        };
    };
}
*/
- (void)getTotalInfo:(NSString *)userName password:(NSString *)password success:(RRSuccessHandler)success
      failure:(RRFailureError)failure {
    
    NSDictionary *params = @{
                             @"UUID": [OpenUDID value],
                             @"token": self.token ? self.token : @"",
                             @"pkg": @"com.vpnfaster.ios",
                             @"os": @"iOS",
                             @"version": APP_BUILD,
                             @"lang": [RRUtilCommon getCurrentLanguage],
                             @"userName": userName!= nil ? userName : @"",
                             @"password": password!= nil ? password : @"",
                             @"change": userName!= nil ? @YES : @NO
                             };
    
    NSString *postUrl = [RRHOST_URL stringByAppendingString:RR_API_TOTAL];
    
    NSLog(@"RRLog - RRUser will send params in getTotalInfo:%@",params);
    
    IGHttpRequestManager *manager = [IGHttpRequestManager postRequestWithUrl:postUrl parameters:params isJSON:NO cachePath:nil withSuccessBlock:^(id responseObject) {
        NSLog(@"RRLog - RRUser recieve response in getTotalInfo:%@",responseObject);
        NSInteger returnCode = [[[responseObject objectForKey:@"message"] objectForKey:@"code"] integerValue];
//        NSDictionary *result = [[NSDictionary dictionaryWithDictionary:responseObject] objectForKey:@"data"];
        
        if (returnCode == 200) {
            NSLog(@"RRLog - RRUser code is 200 in getTotalInfo:%@", responseObject);
            NSDictionary *dictResult = nil;
            if ([NEED_DECRYPT  isEqual: [NSNumber numberWithBool:YES]]) {
                dictResult = [RRUtilCommon getDictFromBase64:[responseObject objectForKey:@"result"]];
            } else {
                dictResult = [responseObject objectForKey:@"result"];
            }
            NSLog(@"RRLog - RRUser dictResult after decry:%@", dictResult);
            NSDictionary *dictUser = [dictResult objectForKey:@"user"];
            NSArray *serversArray = [dictResult objectForKey:@"servers"];
            NSArray *productsArray = [dictResult objectForKey:@"items"];
            RRUser *rrUser = [RRUser sharedInstance];
            rrUser.createTime = [[dictUser objectForKey:@"createTime"] integerValue];
            rrUser.deviceId = [dictUser objectForKey:@"deviceId"];
            
            rrUser.uid = [[dictUser objectForKey:@"id"] integerValue];
            rrUser.lastLoginTime = [[dictUser objectForKey:@"lastLoginTime"] integerValue];
            rrUser.password = [dictUser objectForKey:@"password"];
            rrUser.status = [dictUser objectForKey:@"status"];
            rrUser.token = [dictUser objectForKey:@"token"];
            rrUser.userName = [dictUser objectForKey:@"userName"];
            
            NSDictionary *dictUserVipPlan = [dictUser objectForKey:@"vipPlan"];
            rrUser.subscribedItem = [dictUserVipPlan objectForKey:@"subscribedItem"];
            rrUser.userGroup = [dictUserVipPlan objectForKey:@"userGroup"];
            rrUser.expireDate = [[dictUserVipPlan objectForKey:@"expiredDate"] integerValue];
            rrUser.limit = [[dictUserVipPlan objectForKey:@"limit"] integerValue];
            rrUser.used = [[dictUserVipPlan objectForKey:@"used"] integerValue];
            
            /*****创建servers Model****/
            NSMutableArray *servers = [NSMutableArray new];
            for (NSDictionary *serverDict in serversArray) {
                ServerModel *server = [ServerModel new];
                server.area = [serverDict objectForKey:@"area"];
                server.host = [serverDict objectForKey:@"host"];
                server.serverId = [[serverDict objectForKey:@"id"] integerValue];
                server.name = [serverDict objectForKey:@"name"];
                server.psk = [serverDict objectForKey:@"psk"];
                server.status = [serverDict objectForKey:@"status"];
                server.icon = [serverDict objectForKey:@"icon"];
                server.vip = [[serverDict objectForKey:@"vip"] boolValue];
                [servers addObject:server];
            }
            rrUser.servers = [NSArray arrayWithArray:servers];
            
            /*****创建products Model****/
            NSMutableArray *products = [NSMutableArray new];
            for (NSDictionary *productDict in productsArray) {
                ProductModel *product = [ProductModel new];
                product.productId = [productDict objectForKey:@"itemId"];
                product.name = [productDict objectForKey:@"name"];
                product.pId = [[productDict objectForKey:@"id"] integerValue];
                product.sort = [[productDict objectForKey:@"sort"] integerValue];
                [products addObject:product];
            }
            rrUser.products = [NSArray arrayWithArray:products];
            
            if (rrUser.isLogin == YES) {
                
            } else {
                rrUser.isLogin = YES;
                rrUser.selectedServerId = 0;
            }
            
            [rrUser save];
            
            if (success) {
                success();
            }
        } else {
            NSLog(@"RRLog - RRUser code not 200 in getTotalInfo:%@", responseObject);
            if (failure) {
                NSString *localizedStringKey = [NSString stringWithFormat:@"%@%d", @"error", returnCode];
                NSError *error = [NSError errorWithDomain:@"com.vpnfaster.ios"
                                                     code:returnCode
                                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"error_occur", nil)}];
                failure(error);
            }
        }
    } withFailBlock:^(NSError *error) {
        NSLog(@"RRLog - RRUser recieve response failed in getTotalInfo:%@", error);
        if (failure) {
            failure(error);
        }
    } withWaitingBlock:nil];
    
    [manager loadData];
}

- (void)postBuyReceipt:(NSString *)receipt success:(RRSuccessHandler)success
             failure:(RRFailureError)failure {
    
    NSDictionary *params = @{
                             @"UUID": [OpenUDID value],
                             @"token": self.token ? self.token : @"",
                             @"pkg": @"com.vpnfaster.ios",
                             @"os": @"iOS",
                             @"version": APP_BUILD,
                             @"lang": [RRUtilCommon getCurrentLanguage],
                             @"transactionreceipt": receipt
                             };
    
    NSString *postUrl = [RRHOST_URL stringByAppendingString:RR_API_PAY_VALIDATE];
    
    IGHttpRequestManager *manager = [IGHttpRequestManager postRequestWithUrl:postUrl parameters:params isJSON:NO cachePath:nil withSuccessBlock:^(id responseObject) {
        NSLog(@"RRLog - RRUser recieve response in postBuyReceipt:%@",responseObject);
        NSInteger returnCode = [[[responseObject objectForKey:@"message"] objectForKey:@"code"] integerValue];
        //        NSDictionary *result = [[NSDictionary dictionaryWithDictionary:responseObject] objectForKey:@"data"];
        
        if (returnCode == 200) {
            NSLog(@"RRLog - RRUser code is 200 in postBuyReceipt:%@", responseObject);
            NSDictionary *dictUser = [responseObject objectForKey:@"result"];
            
            RRUser *rrUser = [RRUser sharedInstance];
            
            rrUser.subscribedItem = [dictUser objectForKey:@"subscribedItem"];
            rrUser.userGroup = [dictUser objectForKey:@"userGroup"];
            rrUser.expireDate = [[dictUser objectForKey:@"expiredDate"] integerValue];
            rrUser.limit = [[dictUser objectForKey:@"limit"] integerValue];
            rrUser.used = [[dictUser objectForKey:@"used"] integerValue];
            
            [rrUser save];
            
//            NSNotification *notification =[NSNotification notificationWithName:NEED_REFRESH_USER_DATA object:nil userInfo:nil];
//            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            if (success) {
                success();
            }
        } else {
            NSLog(@"RRLog - RRUser code not 200 in postBuyReceipt:%@", responseObject);
            if (failure) {
                NSString *localizedStringKey = [NSString stringWithFormat:@"%@%d", @"error", returnCode];
                NSError *error = [NSError errorWithDomain:@"com.vpnfaster.ios"
                                                     code:returnCode
                                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"error_occur", nil)}];
                failure(error);
            }
        }
    } withFailBlock:^(NSError *error) {
        NSLog(@"RRLog - RRUser recieve response failed in postBuyReceipt:%@", error);
        failure(error);
    } withWaitingBlock:nil];
    
    [manager loadData];
}

- (void)resetPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(RRSuccessHandler)success
               failure:(RRFailureError)failure {
    
    NSDictionary *params = @{
                             @"UUID": [OpenUDID value],
                             @"token": self.token ? self.token : @"",
                             @"pkg": @"com.vpnfaster.ios",
                             @"os": @"iOS",
                             @"version": APP_BUILD,
                             @"lang": [RRUtilCommon getCurrentLanguage],
                             @"oldPassword": oldPassword,
                             @"newPassword": newPassword
                             };
    
    NSString *postUrl = [RRHOST_URL stringByAppendingString:RR_API_RESET_PWD];
    
    NSLog(@"RRLog - RRUser will send params in resetPassword:%@",params);
    
    IGHttpRequestManager *manager = [IGHttpRequestManager postRequestWithUrl:postUrl parameters:params isJSON:NO cachePath:nil withSuccessBlock:^(id responseObject) {
        NSLog(@"RRLog - RRUser recieve response in resetPassword:%@",responseObject);
        NSInteger returnCode = [[[responseObject objectForKey:@"message"] objectForKey:@"code"] integerValue];
        //        NSDictionary *result = [[NSDictionary dictionaryWithDictionary:responseObject] objectForKey:@"data"];
        
        if (returnCode == 200) {
            NSLog(@"RRLog - RRUser code is 200 in resetPassword:%@", responseObject);
            NSDictionary *dictUser = [responseObject objectForKey:@"result"];
            
            //            RRUser *rrUser = [RRUser sharedInstance];
            //
            //            rrUser.subscribedItem = [dictUser objectForKey:@"subscribedItem"];
            //            rrUser.userGroup = [dictUser objectForKey:@"userGroup"];
            //            rrUser.expireDate = [[dictUser objectForKey:@"expireDate"] integerValue];
            //            rrUser.limit = [[dictUser objectForKey:@"limit"] integerValue];
            //            rrUser.used = [[dictUser objectForKey:@"used"] integerValue];
            //
            //            [rrUser save];
            
            //            NSNotification *notification =[NSNotification notificationWithName:NEED_REFRESH_USER_DATA object:nil userInfo:nil];
            //            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            if (success) {
                success();
            }
        } else {
            NSLog(@"RRLog - RRUser code not 200 in resetPassword:%@", responseObject);
            if (failure) {
                NSString *localizedStringKey = [NSString stringWithFormat:@"%@%d", @"error", returnCode];
                NSError *error = [NSError errorWithDomain:@"com.vpnfaster.ios"
                                                     code:returnCode
                                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"error_occur", nil)}];
                failure(error);
            }
        }
    } withFailBlock:^(NSError *error) {
        NSLog(@"RRLog - RRUser recieve response failed in resetPassword:%@", error);
        failure(error);
    } withWaitingBlock:nil];
    
    [manager loadData];
}

- (void)getUserPlan:(RRSuccessHandler)success
              failure:(RRFailureError)failure {
    
    NSDictionary *params = @{
                             @"UUID": [OpenUDID value]
                             };
    
    NSString *postUrl = [RRHOST_URL stringByAppendingString:RR_API_GET_PLAN];
    
    IGHttpRequestManager *manager = [IGHttpRequestManager postRequestWithUrl:postUrl parameters:params isJSON:NO cachePath:nil withSuccessBlock:^(id responseObject) {
        NSLog(@"RRLog - RRUser recieve response in getNewPlan:%@",responseObject);
        NSInteger returnCode = [[[responseObject objectForKey:@"message"] objectForKey:@"code"] integerValue];
        //        NSDictionary *result = [[NSDictionary dictionaryWithDictionary:responseObject] objectForKey:@"data"];
        
        if (returnCode == 200) {
            NSLog(@"RRLog - RRUser code is 200 in getNewPlan:%@", responseObject);
            NSDictionary *dictUser = [responseObject objectForKey:@"result"];
            
            RRUser *rrUser = [RRUser sharedInstance];
            
            rrUser.subscribedItem = [dictUser objectForKey:@"subscribedItem"];
            rrUser.userGroup = [dictUser objectForKey:@"userGroup"];
            rrUser.expireDate = [[dictUser objectForKey:@"expiredDate"] integerValue];
            rrUser.limit = [[dictUser objectForKey:@"limit"] integerValue];
            rrUser.used = [[dictUser objectForKey:@"used"] integerValue];
            
            [rrUser save];
            
            //            NSNotification *notification =[NSNotification notificationWithName:NEED_REFRESH_USER_DATA object:nil userInfo:nil];
            //            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            if (success) {
                success();
            }
        } else {
            NSLog(@"RRLog - RRUser code not 200 in getNewPlan:%@", responseObject);
            if (failure) {
                NSString *localizedStringKey = [NSString stringWithFormat:@"%@%d", @"error", returnCode];
                NSError *error = [NSError errorWithDomain:@"com.vpnfaster.ios"
                                                     code:returnCode
                                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"error_occur", nil)}];
                failure(error);
            }
        }
    } withFailBlock:^(NSError *error) {
        NSLog(@"RRLog - RRUser recieve response failed in getNewPlan:%@", error);
        failure(error);
    } withWaitingBlock:nil];
    
    [manager loadData];
}

- (void)getConnectPassword:(RRSuccessHandler)success
           failure:(RRFailureError)failure {
    
    NSDictionary *params = @{
                             @"UUID": [OpenUDID value],
                             @"serverId": [NSNumber numberWithInteger:[RRUser sharedInstance].selectedServerId],
                             };
    
    NSString *postUrl = [RRHOST_URL stringByAppendingString:RR_API_GET_CONNECT_PASSWORD];
    
    IGHttpRequestManager *manager = [IGHttpRequestManager postRequestWithUrl:postUrl parameters:params isJSON:NO cachePath:nil withSuccessBlock:^(id responseObject) {
        NSLog(@"RRLog - RRUser recieve response in getConnectPassword:%@",responseObject);
        NSInteger returnCode = [[[responseObject objectForKey:@"message"] objectForKey:@"code"] integerValue];
        //        NSDictionary *result = [[NSDictionary dictionaryWithDictionary:responseObject] objectForKey:@"data"];
        
        if (returnCode == 200) {
            NSLog(@"RRLog - RRUser code is 200 in getConnectPassword:%@", responseObject);
            NSDictionary *dictResult = nil;
            if ([NEED_DECRYPT  isEqual: [NSNumber numberWithBool:YES]]) {
                dictResult = [RRUtilCommon getDictFromBase64:[responseObject objectForKey:@"result"]];
            } else {
                dictResult = [responseObject objectForKey:@"result"];
            }
            NSLog(@"RRLog - RRUser code is 200 in getConnectPassword dictResult:%@", dictResult);
            NSDictionary *dictUser = dictResult;
            
            RRUser *rrUser = [RRUser sharedInstance];
            
            rrUser.userName = [dictUser objectForKey:@"userName"];
            rrUser.connectPassword = [dictUser objectForKey:@"connectPass"];
            
            [rrUser save];
            
            //            NSNotification *notification =[NSNotification notificationWithName:NEED_REFRESH_USER_DATA object:nil userInfo:nil];
            //            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            if (success) {
                success();
            }
        } else {
            NSLog(@"RRLog - RRUser code not 200 in getConnectPassword:%@", responseObject);
            if (failure) {
                NSString *localizedStringKey = [NSString stringWithFormat:@"%@%d", @"error", returnCode];
                NSError *error = [NSError errorWithDomain:@"com.vpnfaster.ios"
                                                     code:returnCode
                                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"error_occur", nil)}];
                failure(error);
            }
        }
    } withFailBlock:^(NSError *error) {
        NSLog(@"RRLog - RRUser recieve response failed in getConnectPassword:%@", error);
        failure(error);
    } withWaitingBlock:nil];
    
    [manager loadData];
}

/* 注册push */
- (void)registerDevicePush:(NSString *)token success:(RRSuccessHandler)success
             failure:(RRFailureError)failure {
    
    NSDictionary *params = @{
                             @"UUID": [OpenUDID value],
                             @"token": token,
                             @"pkg": @"com.vpnfaster.ios",
                             @"os": @"iOS",
                             @"version": APP_BUILD,
                             @"lang": [RRUtilCommon getCurrentLanguage],
                             @"timeZone": [TPUtils timeZoneName]
                             };
    
    NSString *postUrl = [RRHOST_URL stringByAppendingString:RR_API_GET_REGISTER_PUSH];
    
    NSLog(@"RRLog - RRUser will send params in registerDevicePush:%@",params);
    
    IGHttpRequestManager *manager = [IGHttpRequestManager postRequestWithUrl:postUrl parameters:params isJSON:NO cachePath:nil withSuccessBlock:^(id responseObject) {
        NSLog(@"RRLog - RRUser recieve response in registerDevicePush:%@",responseObject);
        NSInteger returnCode = [[[responseObject objectForKey:@"message"] objectForKey:@"code"] integerValue];
        //        NSDictionary *result = [[NSDictionary dictionaryWithDictionary:responseObject] objectForKey:@"data"];
        
        if (returnCode == 200) {
            NSLog(@"RRLog - RRUser code is 200 in registerDevicePush:%@", responseObject);
            
            if (success) {
                success();
            }
        } else {
            NSLog(@"RRLog - RRUser code not 200 in registerDevicePush:%@", responseObject);
            if (failure) {
                NSString *localizedStringKey = [NSString stringWithFormat:@"%@%d", @"error", returnCode];
                NSError *error = [NSError errorWithDomain:@"com.vpnfaster.ios"
                                                     code:returnCode
                                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"error_occur", nil)}];
                failure(error);
            }
        }
    } withFailBlock:^(NSError *error) {
        NSLog(@"RRLog - RRUser recieve response failed in registerDevicePush:%@", error);
        failure(error);
    } withWaitingBlock:nil];
    
    [manager loadData];
}

- (ServerModel *)getServerById:(NSInteger)serverId{
    for(ServerModel *model in [RRUser sharedInstance].servers){
        if (serverId == model.serverId) {
            return model;
        }
    }
    return nil;
}

//- (void)encodeWithCoder:(NSCoder *)encoder {
//    [encoder encodeInteger:self.createTime forKey:@"createTime"];
//    [encoder encodeObject:self.deviceId forKey:@"deviceId"];
//    [encoder encodeInteger:self.expireDate forKey:@"expireDate"];
//    [encoder encodeInteger:self.uid forKey:@"uid"];
//    [encoder encodeInteger:self.lastLoginTime forKey:@"lastLoginTime"];
//    [encoder encodeObject:self.password forKey:@"password"];
//    [encoder encodeObject:self.status forKey:@"status"];
//    [encoder encodeObject:self.subscribedItem forKey:@"subscribedItem"];
//    [encoder encodeObject:self.token forKey:@"token"];
//    [encoder encodeObject:self.userGroup forKey:@"userGroup"];
//    [encoder encodeObject:self.userName forKey:@"userName"];
//}
//
//- (id)initWithCoder:(NSCoder *)decoder {
//    if((self = [super init])) {
//        self.createTime = [decoder decodeIntegerForKey:@"createTime"];
//        self.deviceId = [decoder decodeObjectForKey:@"deviceId"];
//        self.expireDate = [decoder decodeIntegerForKey:@"expireDate"];
//        self.uid = [decoder decodeIntegerForKey:@"uid"];
//        self.lastLoginTime = [decoder decodeIntegerForKey:@"lastLoginTime"];
//        self.password = [decoder decodeObjectForKey:@"password"];
//        self.status = [decoder decodeObjectForKey:@"status"];
//        self.subscribedItem = [decoder decodeObjectForKey:@"subscribedItem"];
//        self.token = [decoder decodeObjectForKey:@"token"];
//        self.userGroup = [decoder decodeObjectForKey:@"userGroup"];
//        self.userName = [decoder decodeObjectForKey:@"userName"];
//    }
//    return self;
//}

- (void)save {
    NSData *encodeData = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:encodeData forKey:USER_DEFAULT_KEY_USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (RRUser *)read {
    NSData *encodeData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER];
    if (!encodeData) {
        return nil;
    }
    RRUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:encodeData];
    return user;
}

+ (void)remove {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)readFromUserDefault{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER];
    
    NSLog(@"RRLog - RRUser readFromUserDefault user:%@", dict);
    
//    if (dict && [dict objectForKey:@"uid"]) {
//        _uid = [dict objectForKey:@"uid"];
//    }
//    if (dict && [dict objectForKey:@"headIconUrl"]) {
//        _headIconUrl = [dict objectForKey:@"headIconUrl"];
//    }
//    if (dict && [dict objectForKey:@"nickname"]) {
//        _nickname = [dict objectForKey:@"nickname"];
//    }
//    if (dict && [dict objectForKey:@"userName"]) {
//        _userName = [dict objectForKey:@"userName"];
//    }
//    if (dict && [dict objectForKey:@"phoneNumber"]) {
//        _phoneNumber = [dict objectForKey:@"phoneNumber"];
//    }
//    if (dict && [dict objectForKey:@"email"]) {
//        _email = [dict objectForKey:@"email"];
//    }
//    if (dict && [dict objectForKey:@"countryCode"]) {
//        _countryCode = [dict objectForKey:@"countryCode"];
//    }
//    if (dict && [dict objectForKey:@"countryAbb"]) {
//        _countryAbb = [dict objectForKey:@"countryAbb"];
//    }
//    if (dict && [dict objectForKey:@"isLogin"]) {
//        _isLogin = [[dict objectForKey:@"isLogin"] boolValue];
//    }
//    if (dict && [dict objectForKey:@"regionCode"]) {
//        _regionCode = [dict objectForKey:@"regionCode"];
//    }
//    if (dict && [dict objectForKey:@"hostUrl"]) {
//        _hostUrl = [dict objectForKey:@"hostUrl"];
//    }
//    if (dict && [dict objectForKey:@"isDeveloper"]) {
//        _isDeveloper = [[dict objectForKey:@"isDeveloper"] boolValue];
//    }
//    if (dict && [dict objectForKey:@"token"]) {
//        _token = [dict objectForKey:@"token"];
//    }
//    if (dict && [dict objectForKey:@"tokenType"]) {
//        _tokenType = [dict objectForKey:@"tokenType"];
//    }
    
}

- (void)saveToUserDefault{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//
//    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
//
//    if (_uid) {
//        [dict setObject:_uid forKey:@"uid"];
//    }
//    if (_headIconUrl) {
//        [dict setObject:_headIconUrl forKey:@"headIconUrl"];
//    }
//    if (_nickname) {
//        [dict setObject:_nickname forKey:@"nickname"];
//    }
//    if (_userName) {
//        [dict setObject:_userName forKey:@"userName"];
//    }
//    if (_phoneNumber) {
//        [dict setObject:_phoneNumber forKey:@"phoneNumber"];
//    }
//    if (_email) {
//        [dict setObject:_email forKey:@"email"];
//    }
//    if (_countryCode) {
//        [dict setObject:_countryCode forKey:@"countryCode"];
//    }
//    if (_countryAbb) {
//        [dict setObject:_countryAbb forKey:@"countryAbb"];
//    }
//    if (_isLogin) {
//        [dict setObject:[NSNumber numberWithBool:_isLogin] forKey:@"isLogin"];
//    }
//    if (_regionCode) {
//        [dict setObject:_regionCode forKey:@"regionCode"];
//    }
//    if (_hostUrl) {
//        [dict setObject:_hostUrl forKey:@"hostUrl"];
//    }
//    if (_isDeveloper) {
//        [dict setObject:[NSNumber numberWithBool:_isDeveloper] forKey:@"isDeveloper"];
//    }
//    if (_token) {
//        [dict setObject:_token forKey:@"token"];
//    }
//    if (_tokenType) {
//        [dict setObject:_tokenType forKey:@"tokenType"];
//    }
//    [userDefaults setObject:dict forKey:USER_DEFAULT_KEY_USER];
//    [userDefaults synchronize];
}

- (void)clearUserInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_KEY_USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)doLoginActionsWithHeadIconUrl:(NSString *)url
                                  uid:(NSString *)uid
                             userName:(NSString *)userName
                          phoneNumber:(NSString *)phoneNumber
                          countryCode:(NSString *)countryCode
                           countryAbb:(NSString *)countryAbb
                           regionCode:(NSString *)regionCode
                          isDeveloper:(BOOL)isDeveloper
                                token:(NSString *)token
                            tokenType:(NSString *)tokenType{
//    _uid = uid;
//    _headIconUrl = url;
//    _userName = userName;
//    _phoneNumber = phoneNumber;
//    _countryCode = countryCode;
//    _countryAbb = countryAbb;
//    _regionCode = regionCode;
//    _token = token;
//    _tokenType = tokenType;
//
//    _isLogin = YES;
//
//    [self saveToUserDefault];
}

- (void)loginOut:(RRSuccessHandler)success
         failure:(RRFailureError)failure {
//    _isLogin = NO;
//    _token = nil;
//    _tokenType = nil;
//    [self clearUserInfo];
////    [self saveToUserDefault];
}

@end
