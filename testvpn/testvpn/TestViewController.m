//

//  ViewController.m

//  testvpn

//

//  Created by jianbin on 2019/4/27.

//  Copyright © 2019年 roborock. All rights reserved.

//



@import NetworkExtension;



#import "TestViewController.h"
#import "KeyChainHelper.h"
#import <Security/Security.h>
#import <SAMKeychain/SAMKeychain.h>
#import "JFKeychain.h"



@interface TestViewController ()



@property (nonatomic, strong) UIButton        *createButton;
@property (nonatomic, strong) UIButton        *connectButton;
@property (nonatomic, strong) UIButton        *disconnectButton;

@property (nonatomic, strong) NSString        *account;
@property (nonatomic, strong) NSString        *serverNamePwd;
@property (nonatomic, strong) NSString        *serverNamePsk;
@property (nonatomic, strong) NSString        *vpmPasswordIdentifier;
@property (nonatomic, strong) NSString        *vpnPrivateKeyIdentifier;

@property (nonatomic, strong) NEVPNManager   *manager;

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
    self.account = @"com.roborock.testvpn.account";
    self.serverNamePwd = @"com.roborock.testvpn.vpnServerNamePwd";
    self.serverNamePsk = @"com.roborock.testvpn.vpnServerNamePsk";
    self.vpmPasswordIdentifier = @"19260817"; //password 密码
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
    
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        
        if (error) {
            
            NSLog(@"load error");
            
        }else{
            
            NEVPNProtocolIPSec *conf = [[NEVPNProtocolIPSec alloc] init];
            conf.serverAddress = @"47.91.246.135";
            conf.username = @"vpn";
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
            
            
            
            //self.manager.onDemandEnabled = NO;//按需连接不可用
            
            
            
            [self.manager setProtocolConfiguration:conf];
            
            [self.manager setOnDemandEnabled:conf];
            
            self.manager.localizedDescription = @"sjb test vpn";
            
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

- (CFTypeRef)passwordForService:(nonnull NSString *)service account:(nonnull NSString *)account{
    
    //生成一个查询用的 可变字典
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [dict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass]; //表明为一般密码可能是证书或者其他东西
    
    [dict setObject:service forKey:(__bridge id)kSecAttrService];    //输入service
    
    [dict setObject:account forKey:(__bridge id)kSecAttrAccount];  //输入account
    
    [dict setObject:@YES forKey:(__bridge id)kSecReturnData];     //返回Data
    
    //查询
    
    OSStatus status = -1;
    
    CFTypeRef result = NULL;
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)dict,&result);//核心API 查找是否匹配 和返回密码！
    
    if (status != errSecSuccess) { //判断状态
        
        return nil;
        
    }
    
    //返回数据
    
    NSString *password = [[NSString alloc] initWithData:(__bridge_transfer NSData *)result encoding:NSUTF8StringEncoding];//转换成string
    
    return result;
    
}

-(BOOL)addItemWithService:(NSString *)service account:(NSString *)account password:(NSString *)password{
    
    //先查查是否已经存在
    
    //构造一个操作字典用于查询
    
    NSMutableDictionary *searchDict = [[NSMutableDictionary alloc]initWithCapacity:4];
    
    [searchDict setObject:service forKey:(__bridge id)kSecAttrService];                         //标签service
    
    [searchDict setObject:account forKey:(__bridge id)kSecAttrAccount];                         //标签account
    
    [searchDict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];//表明存储的是一个密码
    
    
    
    OSStatus status = -1;
    
    CFTypeRef result =NULL;
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDict, &result);
    
    if (status == errSecItemNotFound) {                                              //没有找到则添加
        
        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];    //把password 转换为 NSData
        
        [searchDict setObject:passwordData forKey:(__bridge id)kSecValueData];       //添加密码
        
        status = SecItemAdd((__bridge CFDictionaryRef)searchDict, NULL);             //!!!!!关键的添加API
        
    }else if (status == errSecSuccess){                                              //成功找到，说明钥匙已经存在则进行更新
        
        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];    //把password 转换为 NSData
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:searchDict];
        
        [dict setObject:passwordData forKey:(__bridge id)kSecValueData];             //添加密码
        
        status = SecItemUpdate((__bridge CFDictionaryRef)searchDict, (__bridge CFDictionaryRef)dict);//!!!!关键的更新API
        
    }
    
    return (status == errSecSuccess);
    
}


@end
