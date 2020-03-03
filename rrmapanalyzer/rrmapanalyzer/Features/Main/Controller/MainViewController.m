//
//  UserViewController.m
//  TuyaSmart
//
//  Created by fengyu on 15/2/28.
//  Copyright (c) 2015年 Tuya. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

#import "MainViewController.h"
#import "MainView.h"
#import "MapDetailViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()<MainViewDelegate>

@property (nonatomic,strong) MainView             *mainView;

@property (nonatomic,strong) JSContext            *jscontext;


@end

@implementation MainViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationGotMap:) name:@"GOT_MAP" object:nil];
    
    NSLog(@"****** recieved main view did load");
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.url != nil) {
        [self handleMapUrl:appDelegate.url];
    }
}

- (void)initView {
    _mainView = [[MainView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT)];
    
    _mainView.delegate = self;
    
    [self.view addSubview:_mainView];
}

- (JSContext *)jscontext {
    if (!_jscontext) {
        _jscontext = [[JSContext alloc] init];
        NSString *jxPath = [[NSBundle mainBundle] pathForResource:@"workerMapParser" ofType:@"jx"];
        NSString *jsContentStr = [NSString stringWithContentsOfFile:jxPath encoding:NSUTF8StringEncoding error:nil];
        //识别不到，按GBK编码再解码一次.这里不能先按GB18030解码，否则会出现整个文档无换行bug。
        if (!jsContentStr) {
            jsContentStr = [NSString stringWithContentsOfFile:jxPath encoding:0x80000632 error:nil];
        }
        //还是识别不到，按GB18030编码再解码一次.
        if (!jsContentStr) {
            jsContentStr = [NSString stringWithContentsOfFile:jxPath encoding:0x80000631 error:nil];
        }
        if (!jsContentStr) {
            return nil;
        }
//        [_jscontext evaluateScript:jsContentStr];
        [_jscontext evaluateScript:jsContentStr withSourceURL:[NSURL URLWithString:jxPath]];
        _jscontext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"RRAppLog - RRJsExecutor - Run js error:%@, context:%@", [exception toObject], context);
        };
    }
    return _jscontext;
}

- (void)appWillEnterForegroundNotification {
}

- (void)handleNotificationGotMap:(NSNotification *)info {
    NSURL *url = info.userInfo[@"url"];
    [self handleMapUrl:url];
}

- (void)handleMapUrl:(NSURL *)url {
    if (!url) {
        return;
    }
    NSData *mapData = [NSData dataWithContentsOfURL:url];
    NSData *unGzedMapData = [mapData gzipInflate];
    NSString *base64MapData = [unGzedMapData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    JSValue *func = self.jscontext[@"parse"];
    JSValue *value = [func callWithArguments:@[base64MapData]];
    NSDictionary *resultDict = [value toObject];
    
    self.mainView.usageInfoLabel.textColor = [UIColor redColor];
    NSLog(@"done:%@", resultDict);
}

- (void)gotoChooseVPNServer {
//    FVChooseServerViewController *vc = [FVChooseServerViewController new];
//    vc.delegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)showConnectFailedAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"network_issue_title", nil) message:NSLocalizedString(@"network_issue_message", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showConnectFailedAlertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - MainViewDelegate

- (void)mainViewConnectButtonTap:(nonnull MainView *)mainView {
    
}

@end
