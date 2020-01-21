//
//  VPNHelper.m
//  VPNFaster
//
//  Created by jianbin on 2019/5/12.
//  Copyright © 2019年 roborock. All rights reserved.
//

#define KEY_CHAIN_KEY_PWD @"com.roborock.VPNFaster.vpnServerNamePwd"
#define KEY_CHAIN_KEY_PSK @"com.roborock.VPNFaster.vpnServerNamePsk"

@import NetworkExtension;

#import "VPNHelper.h"
#import "JFKeychain.h"

@interface VPNHelper ()

@end

@implementation VPNHelper

TP_DEF_SINGLETON(VPNHelper)

- (NEVPNManager *)manager {
    if (!_manager) {
        _manager = [NEVPNManager sharedManager];
    }
    return _manager;
}

- (void)createPreferenceWithIp:(NSString *)ip psk:(NSString *)psk account:(NSString *)account password:(NSString *)password completion:(void (^)(NSError *error))completion {
    [JFKeychain createKeychainValue:password forIdentifier:KEY_CHAIN_KEY_PWD];
    [JFKeychain createKeychainValue:psk forIdentifier:KEY_CHAIN_KEY_PSK];
    
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            completion(error);
        } else {
            NEVPNProtocolIPSec *conf = [[NEVPNProtocolIPSec alloc] init];
            conf.serverAddress = ip;
            conf.username = account;
            conf.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;//共享密钥方式
            
//            conf.identityData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"client.cert" ofType:@"p12"]];
//            conf.identityDataPassword = @"123456";
            conf.sharedSecretReference = [JFKeychain searchKeychainCopyMatching:KEY_CHAIN_KEY_PSK];//从keychain中获取共享密钥
            conf.passwordReference = [JFKeychain searchKeychainCopyMatching:KEY_CHAIN_KEY_PWD];//从keychain中获取密码
            
            //本地id
            conf.localIdentifier = @"";
            conf.remoteIdentifier = ip;//远程服务器的ID，该参数可以在自己服务器的VPN配置文件查询得到
            conf.useExtendedAuthentication = YES;
            conf.disconnectOnSleep = NO;//进入后台时是否断开VPN连接
            
            /***** Ikvev2 方式 *****/
            NEVPNProtocolIKEv2* ikev = [[NEVPNProtocolIKEv2 alloc] init];
            ikev.certificateType = NEVPNIKEv2CertificateTypeECDSA256;
            ikev.authenticationMethod = NEVPNIKEAuthenticationMethodCertificate;
            ikev.useExtendedAuthentication = YES;
            
            ikev.username = account;
            ikev.passwordReference = [JFKeychain searchKeychainCopyMatching:KEY_CHAIN_KEY_PWD];
            ikev.serverAddress = ip;
            ikev.remoteIdentifier = ip;
            ikev.identityData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"client.cert" ofType:@"p12"]];
            ikev.identityDataPassword = @"123456";
            /***********************/
            
            //按需连接，仅在wifi情况下连接，可以设置多种连接规则
            NSMutableArray *rules = [[NSMutableArray alloc] init];
            NEOnDemandRuleConnect *connectRule = [[NEOnDemandRuleConnect alloc] init];
            connectRule.interfaceTypeMatch = NEOnDemandRuleInterfaceTypeWiFi;
            [rules addObject:connectRule];
            self.manager.onDemandRules = rules;
            self.manager.onDemandEnabled = NO;//按需连接不可用
            
            [self.manager setProtocolConfiguration:conf];
//            [self.manager setOnDemandEnabled:conf];
            self.manager.localizedDescription = @"VPNFaster";
            self.manager.enabled = true;
            
            ///保存VPN配置
            [self.manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"save preference error: %@", error);
                    completion(error);
                } else {
                    NSLog(@"saved preference");
                    completion(nil);
                }
            }];
        }
    }];
}

- (void)connect:(void (^)(NSError *error))completion {
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        NSError *startError;
        
        [self.manager.connection startVPNTunnelAndReturnError:&startError];
        if (startError) {
            NSLog(@"start error %@", error.localizedDescription);
            completion(startError);
        }else{
            NSLog(@"Connection established");
            completion(nil);
        }
    }];
}

- (void)disconnect {
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        [self.manager.connection stopVPNTunnel];
        NSLog(@"disconnect error:%@", error);
        NSLog(@"Connection stoped");
    }];
}

- (void)getStatus:(void (^)(NEVPNStatus status))callback {
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"loaded");
        if (callback) {
            callback(self.manager.connection.status);
        }
    }];
}

@end
