//

//  ViewController.m

//  testvpn

//

//  Created by jianbin on 2019/4/27.

//  Copyright © 2019年 roborock. All rights reserved.

//



@import NetworkExtension;



#import "TestViewController.h"
#import <Security/Security.h>
#import "JFKeychain.h"

#import "RRUser.h"


@interface TestViewController ()



@property (nonatomic, strong) UIButton        *createButton;
@property (nonatomic, strong) UIButton        *connectButton;
@property (nonatomic, strong) UIButton        *disconnectButton;

@property (nonatomic, strong) NSString        *account;
@property (nonatomic, strong) NSString        *serverNamePwd;
@property (nonatomic, strong) NSString        *serverNamePsk;
@property (nonatomic, strong) NSString        *vpmPasswordIdentifier;
@property (nonatomic, strong) NSString        *vpnPrivateKeyIdentifier;

@property (nonatomic, strong) NEVPNManager    *manager;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initParmas];
}



- (void)initView {
    [self.view addSubview:self.createButton];
    [self.view addSubview:self.connectButton];
    [self.view addSubview:self.disconnectButton];
}



- (void)initParmas {
    self.account = @"com.vpnfaster.ios.account";
    self.serverNamePwd = @"com.vpnfaster.ios.vpnServerNamePwd";
    self.serverNamePsk = @"com.vpnfaster.ios.vpnServerNamePsk";
    self.vpmPasswordIdentifier = @"123456"; //password 密码
    self.vpnPrivateKeyIdentifier = @"testtest"; //IPSec PSK
    [JFKeychain createKeychainValue:self.vpmPasswordIdentifier forIdentifier:self.serverNamePwd];
    [JFKeychain createKeychainValue:self.vpnPrivateKeyIdentifier forIdentifier:self.serverNamePsk];
//    [self addItemWithService:self.serverNamePwd account:self.account password:self.vpmPasswordIdentifier];
//    [self addItemWithService:self.serverNamePsk account:self.account password:self.vpnPrivateKeyIdentifier];
//    if ([SAMKeychain setPassword:self.vpmPasswordIdentifier forService:self.serverNamePwd account:self.account]) {
//        NSLog(@"add pwd success !");
//    }
//    if ([SAMKeychain setPassword:self.vpnPrivateKeyIdentifier forService:self.serverNamePsk account:self.account]) {
//        NSLog(@"add psk success !");
//    }

//    [KeyChainHelper save:@"vpnPwd" data:self.vpmPasswordIdentifier];//将pwd放入钥匙串，因为我们读取密码的时候需要从钥匙串中读出
//    [KeyChainHelper save:@"IPSecSharedPwd" data:self.vpnPrivateKeyIdentifier];//将PSK放入钥匙串
//    NSData *psk = [[KeyChainHelper load:@"IPSecSharedPwd"] dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *pwd = [[KeyChainHelper load:@"vpnPwd"] dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"test");
}



- (NEVPNManager *)manager {
    if (!_manager) {
        _manager = [NEVPNManager sharedManager];
    }
    return _manager;
}



- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 150, 100, 40)];
        [_createButton setTitle:@"create" forState:UIControlStateNormal];
        [_createButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _createButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_createButton.layer setMasksToBounds:YES];
        [_createButton.layer setCornerRadius:5];
        [_createButton.layer setBorderWidth:1]; //边框宽度
        CGColorRef colorref = [[UIColor redColor] CGColor];
        [_createButton.layer setBorderColor:colorref];//边框颜色
        [_createButton addTarget:self action:@selector(createTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createButton;
}



- (UIButton *)connectButton {
    if (!_connectButton) {
        _connectButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 100, 40)];
        [_connectButton setTitle:@"connect" forState:UIControlStateNormal];
        [_connectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _connectButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_connectButton.layer setMasksToBounds:YES];
        [_connectButton.layer setCornerRadius:5];
        [_connectButton.layer setBorderWidth:1]; //边框宽度
        CGColorRef colorref = [[UIColor redColor] CGColor];
        [_connectButton.layer setBorderColor:colorref];//边框颜色
        [_connectButton addTarget:self action:@selector(connectTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectButton;
}



- (UIButton *)disconnectButton {
    if (!_disconnectButton) {
        _disconnectButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 250, 100, 40)];
        [_disconnectButton setTitle:@"disconnect" forState:UIControlStateNormal];
        [_disconnectButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _disconnectButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_disconnectButton.layer setMasksToBounds:YES];
        [_disconnectButton.layer setCornerRadius:5];
        [_disconnectButton.layer setBorderWidth:1]; //边框宽度
        CGColorRef colorref = [[UIColor blueColor] CGColor];
        [_disconnectButton.layer setBorderColor:colorref];//边框颜色
        [_disconnectButton addTarget:self action:@selector(disconnectTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _disconnectButton;
}



- (void)createTap {
//    [[RRUser sharedInstance] getTotalInfo:^() {
//        
//    } failure:^(NSError *error) {
//        
//    }];
    
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        
        if (error) {
            
            NSLog(@"load error");
            
        }else{
            
            NEVPNProtocolIPSec *conf = [[NEVPNProtocolIPSec alloc] init];
            conf.serverAddress = @"47.91.246.135";
            conf.username = @"crayon";
            conf.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;//共享密钥方式
            
//            NSString *psk = [SAMKeychain passwordForService:self.serverNamePsk account:self.account];
            conf.sharedSecretReference = [JFKeychain searchKeychainCopyMatching:self.serverNamePsk];//从keychain中获取共享密钥
            
//            NSString *pwd = [SAMKeychain passwordForService:self.serverNamePwd account:self.account];
            conf.passwordReference = [JFKeychain searchKeychainCopyMatching:self.serverNamePwd];//从keychain中获取密码
            
            //本地id
            
            conf.localIdentifier = @"";
            conf.remoteIdentifier = @"47.91.246.135";//远程服务器的ID，该参数可以在自己服务器的VPN配置文件查询得到
            conf.useExtendedAuthentication = YES;
            conf.disconnectOnSleep = NO;//进入后台时是否断开VPN连接

            //按需连接，仅在wifi情况下连接，可以设置多种连接规则
            
            NSMutableArray *rules = [[NSMutableArray alloc] init];
            
            NEOnDemandRuleConnect *connectRule = [[NEOnDemandRuleConnect alloc] init];
            
            connectRule.interfaceTypeMatch = NEOnDemandRuleInterfaceTypeWiFi;
            
            [rules addObject:connectRule];
            
            self.manager.onDemandRules = rules;
            self.manager.onDemandEnabled = NO;//按需连接不可用
            
            [self.manager setProtocolConfiguration:conf];
            [self.manager setOnDemandEnabled:conf];
            self.manager.localizedDescription = @"VPNFaster";
            self.manager.enabled = true;
            
            ///保存VPN配置
            
            [self.manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"save error: %@", error);
                }else{
                    NSLog(@"save");
                }
            }];
        }
    }];
    
}



- (void)connectTap {
    
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        
        NSError *startError;

        [self.manager.connection startVPNTunnelAndReturnError:&startError];
        if (startError) {
            NSLog(@"start error %@", error.localizedDescription);
        }else{
            NSLog(@"Connection established");
        }
    }];
    
}



- (void)disconnectTap {
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        [self.manager.connection stopVPNTunnel];
        NSLog(@"Load error:%@", error);
        NSLog(@"Connection stop");
    }];
    
}



@end
