//
//  RRUser.h
//
//  Created by fengyu on 19/1/1.
//  Copyright (c) 2019年 RR. All rights reserved.
//

#ifndef RR_RRUser
#define RR_RRUser

typedef enum : NSUInteger {
    SendCodeRegister,
    SendCodeLogin,
    SendCodeGetPassword,
}RRSendCodeType;

typedef enum : NSUInteger {
    ResourceHtmlAboutUs = 1,
    ResourceHtmlAgreement = 2,
    ResourceHtmlPrivacy = 3,
    ResourceHtmlFrequencyQuestions = 4,
}RRResourceHtmlType;

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseModel.h"
#import "ServerModel.h"

/// 用户相关功能
@interface RRUser : BaseModel

/**
 *  单例
 */
+ (instancetype)sharedInstance;

/// 用户唯一ID

@property (nonatomic, assign) NSInteger createTime;

@property (nonatomic, strong) NSString *deviceId;

@property (nonatomic, assign) NSInteger expireDate;

@property (nonatomic, assign) NSInteger uid;

@property (nonatomic, assign) NSInteger lastLoginTime;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *status;

@property (nonatomic, strong) NSString *subscribedItem;

@property (nonatomic, strong) NSString *token;

@property (nonatomic, strong) NSString *userGroup;

@property (nonatomic, strong) NSString *userName;

@property (nonatomic, assign) NSInteger limit; //流量单位M
@property (nonatomic, assign) NSInteger used;  //流量单位M

@property (nonatomic, strong) NSArray  *products;
@property (nonatomic, strong) NSArray  *servers;

@property (nonatomic, strong) NSString *connectPassword;

@property (nonatomic, assign) NSInteger selectedServerId;

@property (nonatomic, assign) BOOL isLogin;

@property (nonatomic, assign) BOOL hasPing;

/**
 *  总接口
 *
 *  @param success     操作成功回调
 *  @param failure     操作失败回调
 */
- (void)getTotalInfo:(NSString *)userName password:(NSString *)password success:(RRSuccessHandler)success
             failure:(RRFailureError)failure;

- (void)postBuyReceipt:(NSString *)receipt success:(RRSuccessHandler)success
               failure:(RRFailureError)failure;

- (void)resetPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(RRSuccessHandler)success
              failure:(RRFailureError)failure;

- (void)getConnectPassword:(RRSuccessHandler)success
                   failure:(RRFailureError)failure;


- (void)getUserPlan:(RRSuccessHandler)success
           failure:(RRFailureError)failure;

- (void)registerDevicePush:(NSString *)token success:(RRSuccessHandler)success
                   failure:(RRFailureError)failure;

- (ServerModel *)getServerById:(NSInteger) serverId;

/**
 *  登出
 *
 *  @param success 操作成功回调
 *  @param failure 操作失败回调
 */
- (void)loginOut:(RRSuccessHandler)success
         failure:(RRFailureError)failure;

- (void)save;
+ (RRUser *)read;
+ (void)remove;

@end

#endif

