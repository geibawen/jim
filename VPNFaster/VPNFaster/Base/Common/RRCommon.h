//
//  RRCommon.h
//  TuyaSmartHomeKit
//
//  Created by jianbin on 2018/10/18.
//  Copyright © 2018年 xuchengcheng. All rights reserved.
//

#ifndef RRCommon_h
#define RRCommon_h

#define APP_ABOUT_NAME @"VPNFaster-iOS"
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_NAME    [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"]
#define APP_BUILD @1

#define TERMS_OF_SERVICE @"https://fastervpn.oss-cn-hongkong.aliyuncs.com/User%20Agreement.html"
#define PRIVACY_POLICY @"https://fastervpn.oss-cn-hongkong.aliyuncs.com/Privacy%20Policy.html"

/* RR Api Urls */
//#define RRHOST_URL @"http://47.91.246.135f:8045"
#define RRHOST_URL @"http://fq.vpn.nsbird.com"
#define RRHOST_ROOT @"/"
#define RR_API_TOTAL @"/api/total"
#define RR_API_RESET_PWD @"/api/user/resetPassword"
#define RR_API_ORDERS @"/api/user/orders"
#define RR_API_PAY_VALIDATE @"/api/pay/receipt/validate"
#define RR_API_GET_PLAN @"/api/user/plan"
#define RR_API_GET_CONNECT_PASSWORD @"/api/user/connect"
#define RR_API_GET_REGISTER_PUSH @"/api/user/token"

/* 通知 */
#define NEED_REFRESH_USER_DATA @"NeedRefeshUserData"

/* 链接 */
#define SHARE_LINK @"http://support.vpn.nsbird.com/share.html"

/* AES */
#define NEED_DECRYPT @YES
#define AES_KEY @"EtOyxIgYnV2vUrgh"

/* User Default Keys */
#define USER_DEFAULT_KEY_USER @"UserDefaultKeyUserModel"
#define USER_DEFAULT_KEY_PRODUCT_LIST @"UserDefaultKeyProductModelList"
#define USER_DEFAULT_KEY_DEVELOPER_PARAMS @"UserDefaultKeyDeveloperParams"
#define USER_DEFAULT_KEY_DEVELOPER_FEATURE @"UserDefaultKeyDeveloperFeature"
#define USER_DEFAULT_KEY_PING @"UserDefaultKeyPingModel"


#endif /* RRCommon_h */
