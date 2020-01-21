//
//  IGHttpRequestManager.m
//  HengYiYing
//
//  Created by ideago63 on 16/8/22.
//  Copyright © 2016年 ideago. All rights reserved.
//

#import "IGHttpRequestManager.h"
#import "OpenUDID.h"
//#import "IGEncryptor.h"
//#import "Bb3Des.h"
#import "RRUser.h"
#import <MBProgressHUD/MBProgressHUD.h>

#define DefautWebRequestTimeout 5.f
#define DESkey @"jfr好@#8$am07&4*"

@interface IGHttpRequestManager ()
@property (nonatomic,assign) IGHttpRequestMethod method;
//@property (nonatomic,strong) JMBasicViewProvider *basicViewProvider;
@property (nonatomic,assign) BOOL isLoading;
// POST上传的是否是JSON字符串
@property (nonatomic,assign) BOOL isJSONPost;
@property (nonatomic,copy) void(^successBlock)(id responseObject);
@property (nonatomic,copy) void(^waitingBlock)();
@property (nonatomic,copy) void(^failBlock)(NSError *error);
//@property (nonatomic,weak) UIViewController *controller;
//@property (nonatomic,assign) CGRect loadingViewFrame;
//@property (nonatomic,assign) BOOL loadingViewHasButton;
//@property (nonatomic,copy) TapAction backAction;
//@property (nonatomic,copy) TapAction reloadAction;
@property (nonatomic,assign) BOOL needHandle;

@end

@implementation IGHttpRequestManager

+ (instancetype)httpRequestWithUrl:(NSString *)url cachePath:(NSString *)path withSuccessBlock:(void (^)(id))successBlock withFailBlock:(void (^)(NSError *))failBlock withWaitingBlock:(void (^)())waitingBlock
{
    IGHttpRequestManager *manager = [[self alloc] init];
    manager.isLoading = NO;
    manager.successBlock = successBlock;
    manager.failBlock = failBlock;
    manager.waitingBlock = waitingBlock;
    manager.url = url;
    manager.cachePath = path;
    manager.isJSONPost = NO;
//    manager.basicViewProvider = [JMBasicViewProvider sharedProvider];
    manager.needCheckLoginStatus = YES;
#if DebugMode
    manager.encryped = NO;
//    NSLog(@"debug模式");
#else
    manager.encryped = NO;
#endif
    return manager;
}

+ (instancetype)getRequestWithUrl:(NSString *)url parameters:(id)parameters isJSON:(BOOL)isJSON cachePath:(NSString *)path withSuccessBlock:(void (^)(id))successBlock withFailBlock:(void (^)(NSError *))failBlock withWaitingBlock:(void (^)())waitingBlock
{
    IGHttpRequestManager *manager = [IGHttpRequestManager httpRequestWithUrl:url cachePath:path withSuccessBlock:successBlock withFailBlock:failBlock withWaitingBlock:waitingBlock];
    manager.method = IGHttpRequestMethodGet;
    manager.isJSONPost = isJSON;
    manager.parameters = parameters;
    return manager;
}

+ (instancetype)newInstance {
    IGHttpRequestManager *manager = [[IGHttpRequestManager alloc] init];
    manager.canceled = false;
    return manager;
}

+ (instancetype)postRequestWithUrl:(NSString *)url parameters:(id)parameters isJSON:(BOOL)isJSON cachePath:(NSString *)path withSuccessBlock:(void (^)(id))successBlock withFailBlock:(void (^)(NSError *))failBlock withWaitingBlock:(void (^)())waitingBlock
{
    IGHttpRequestManager *manager = [IGHttpRequestManager httpRequestWithUrl:url cachePath:path withSuccessBlock:successBlock withFailBlock:failBlock withWaitingBlock:waitingBlock];
    manager.method = IGHttpRequestMethodPost;
    manager.isJSONPost = isJSON;
    manager.parameters = parameters;
    return manager;
}

- (void)downloadFile:(NSString * )fileUrl localFileName:(NSString *)localFileName callback:(RRSuccessDict)callback hud:(RRProgressView *)hud {
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    /* 在沙盒创建downloads文件夹 */
    NSString *filePath = [path stringByAppendingPathComponent:@""];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];

    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    /* 下载地址 */
    NSURL *url = [NSURL URLWithString:fileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    /* 下载路径 */
    NSString *filePathLocal = [path stringByAppendingPathComponent:@""];
    filePathLocal = [filePathLocal stringByAppendingPathComponent:localFileName];
    
    /* 开始请求下载 */
//    MBProgressHUD *hud = [TPProgressUtils showProgressToView:nil ProgressModel:MBProgressHUDModeDeterminate Text:@"loading"];
    _downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {

        NSLog(@"文件下载进度：%.0f％", downloadProgress.fractionCompleted * 100);

        dispatch_async(dispatch_get_main_queue(), ^{
            if (hud) {
                hud.progress = downloadProgress.fractionCompleted;
            }
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        /* 设定下载到的位置 */
        /* 先删除目标文件 */
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePathLocal error:nil];
        return [NSURL fileURLWithPath:filePathLocal];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (hud) {
            [hud hideAnimated:YES];
        }
        if (filePath == nil) {
            if (error && error.code && error.code == -999) {
                return;
            }
            NSLog(@"RRAppLog - IGHttpRequestManager download file error:%@", error);
            callback(@{@"error": error});
            return;
        }

        NSLog(@"下载完成%@", [filePath absoluteString]);
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [resultDict setObject:[[filePath absoluteString] substringFromIndex:7] forKey:@"path"];
        [resultDict setObject:localFileName forKey:@"filename"];
        if (error) {
            [resultDict setObject:error forKey:@"error"];
        }
        
        if (self.canceled == true) {
            return;
        }
        callback(resultDict);
        
    }];
    [_downloadTask resume];
}

- (void)loadData
{
    if(_isLoading) return;
    _isLoading = YES;
    if (_cachePath!=nil && [[NSFileManager defaultManager] fileExistsAtPath:_cachePath]) {
        [self loadFromCache];
    }else{
        [self loadDataFromServerHasLoadingView:YES];
    }
}

- (void)loadDataFromServerHasLoadingView:(BOOL)hasLoadingView;
{
    // 这里要替换manager，如果以前存在的话置空操作也有一个
    [_manager.operationQueue cancelAllOperations];
    _manager = nil;
    _manager = [AFHTTPSessionManager manager];
//    [_manager.requestSerializer setValue:[OpenUDID value] forHTTPHeaderField:@"uid"];
    // 设置超时时间
    [_manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    _manager.requestSerializer.timeoutInterval = DefautWebRequestTimeout;
    [_manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    _manager.requestSerializer = _isJSONPost? [AFJSONRequestSerializer serializer] : [AFHTTPRequestSerializer serializer];
    
#if DebugMode
    // 设置请求头
//    [_manager.requestSerializer setValue:@"Tangcupaigu" forHTTPHeaderField:@"ZhiMaKaiMen"];
    [_manager.requestSerializer setValue:@"false" forHTTPHeaderField:@"des"];
#endif
    
//    [_manager.requestSerializer setValue:[[RRUser sharedInstance] userName] forHTTPHeaderField:@"header_username"];
//
//    [_manager.requestSerializer setValue:APP_VERSION forHTTPHeaderField:@"header_appversion"];
    RRUser *user = [RRUser sharedInstance];
    if (user.token) {
        [_manager.requestSerializer setValue:user.token forHTTPHeaderField:@"token"];
    }

    if (_method == IGHttpRequestMethodGet) {
        [_manager GET:_url parameters:_parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleResponseObject:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self handleResponseWithError:error];
        }];
        [self requestDidBegin:hasLoadingView];
        // 数据已经开始请求，执行等待block
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if (_waitingBlock) {
            _waitingBlock();
        }

    }else{
        [_manager POST:_url parameters:_parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleResponseObject:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self handleResponseWithError:error];
        }];
        [self requestDidBegin:hasLoadingView];
        // 数据已经开始请求，执行等待block
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if (_waitingBlock) {
            _waitingBlock();
        }
    }
}

- (void)loadFromCache
{
    NSData *data = [NSData dataWithContentsOfFile:_cachePath];
    id responeObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    [self removeLoadingAnimationView:YES];
    _successBlock(responeObject);
}

#pragma mark - 请求开始的loading逻辑配置

/**
  请求开始后的loading指示图配置
 */
- (void)requestDidBegin:(BOOL)hasLoadingView
{
    __weak typeof(self) ws = self;
    // 如果需要托管处理，则这里应该显示loading动画
    if (ws.needHandle) {
//        [self removeNetErrorView];
//        [self removeTimeoutErrorView];
        if (hasLoadingView &&ws.needUseLoadingView) {
//            [self setupLoadingAnimationViewForController:_controller frame:_loadingViewFrame hasBackButton:_loadingViewHasButton backAction:_backAction];
        }
    }
}

#pragma mark - 请求成功处理
- (void)handleResponseObject:(id)responseObject
{
    __weak typeof(self) ws = self;
    ws.isLoading = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (ws.needHandle) {
//        [ws removeLoadingAnimationView:YES];
    }
    if (responseObject) {
       
        id resultData = responseObject==nil ? nil :([responseObject isKindOfClass:[NSDictionary class]]? responseObject : [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil]);
        
        
        // 针对HYY的解密处理,data键点值都需要解密
//        if (resultData[@"data"] && _encryped) {
//            NSString *decryptedString = [Bb3Des decryptWithText:resultData[@"data"] isKey:DESkey];
//            NSData *decryptedData = [decryptedString dataUsingEncoding:NSUTF8StringEncoding];
//            if(decryptedData){
//                id dataTmp = [NSJSONSerialization JSONObjectWithData:decryptedData options:NSJSONReadingMutableContainers error:nil];
//                NSMutableDictionary *dictm = [[NSMutableDictionary alloc] initWithDict:resultData];
//                [dictm setValue:dataTmp forKey:@"data"];
//                resultData = [dictm copy];
//            }
//        }
        
        
        // 如果缓存文件存在则删除，重新写入
        if (ws.cachePath) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:ws.cachePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:ws.cachePath error:nil];
            }
            
            NSArray *arr = [ws.cachePath componentsSeparatedByString:@"/"];
            NSMutableArray *arrm = [NSMutableArray arrayWithArray:arr];
            [arrm removeLastObject];
            NSString *directory = [[arrm copy] componentsJoinedByString:@"/"];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
            
            
            // 待写入缓存的Data
            NSData *fileData = [resultData isKindOfClass:[NSData class]]? resultData : [[resultData toJSONString] dataUsingEncoding:NSUTF8StringEncoding];
            
            if([[NSFileManager defaultManager] createFileAtPath:ws.cachePath contents:fileData attributes:nil]){
//                NSLog(@"catchFile create success : %@",ws.cachePath);
            }else{
//                NSLog(@"catchFile create fail : %@",ws.cachePath);
            }
        }
//        if ([[resultData objectForKey:@"code"] integerValue] == 2010 || [[resultData objectForKey:@"code"] integerValue] == 2011) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:TuyaSmartUserNotificationUserSessionInvalid object:nil];
//            return;
//        }
        
        ws.successBlock(resultData);
    }
}

#pragma mark - 请求失败处理
- (void)handleResponseWithError:(NSError *)error
{
    __weak typeof(self) ws = self;
    ws.isLoading = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // 数据请求失败执行请求失败block
    if (ws.needHandle) {
        // 超时错误
        if (error.code == -1001) {
//            [self setupTimeoutErrorViewForController:ws.controller backAction:ws.backAction reloadAction:ws.reloadAction];
        } else if (error.code == -1009) {
            // 断网错误
//            [self setupNetworkErrorViewForController:ws.controller backAction:ws.backAction];
        } else {
//            [self.basicViewProvider setupNoDataPageViewForController:ws.controller tapBackButtonAction:ws.backAction];
        }
//        [self removeLoadingAnimationView:NO];
    }
    
    if(ws.failBlock){
        ws.failBlock(error);
    }
}

- (void)stop
{
    [_manager.operationQueue cancelAllOperations];
}

- (void)cancelDownloading {
    [_downloadTask cancel];
}


/*
- (void)beginUseLoadingView
{
    _needUseLoadingView = YES;
}

- (void)stopUseLoadingView
{
    _needUseLoadingView = NO;
}

#pragma mark - 把网络请求的异常状况的视图交给IGDataLoader来处理

- (void)handleNetworkErrorViewForController:(UIViewController *)controller backAction:(TapAction)backAction reloadAction:(TapAction)reloadAction loadingViewFrame:(CGRect)loadingViewFrame loadingViewHasButton:(BOOL)hasButton
{
    _needHandle = YES;
    _controller = controller;
    _backAction = backAction;
    _reloadAction = reloadAction;
    _loadingViewFrame = loadingViewFrame;
    _loadingViewHasButton = hasButton;
    _needUseLoadingView = YES;
}

#pragma mark - 网络请求不同状态下的视图处理

- (void)setupLoadingAnimationViewForController:(UIViewController *)controller frame:(CGRect)frame hasBackButton:(BOOL)hasButton backAction:(TapAction)backAction
{
    [self.basicViewProvider setupLoadingViewForController:controller frame:frame  hasBackButton:hasButton tapBackButtonAction:backAction];
}

- (void)removeLoadingAnimationView:(BOOL)animated
{
    [self.basicViewProvider removeLoadingAnimationView:animated];
}

- (void)setupNetworkErrorViewForController:(UIViewController *)controller backAction:(TapAction)backAction
{
    [self.basicViewProvider setupNetworkErrorViewForController:controller tapBackButtonAction:backAction];
}

- (void)removeNetErrorView
{
    [self.basicViewProvider removeNetworkErrorView];
}

- (void)setupTimeoutErrorViewForController:(UIViewController *)controller backAction:(TapAction)backAction reloadAction:(TapAction)reloadAction
{
    [self.basicViewProvider setupNetworkTimeoutViewForController:controller tapBackButtonAction:backAction  tapReloadButtonAction:reloadAction];
}

- (void)removeTimeoutErrorView
{
    [self.basicViewProvider removeTimeoutErrorView];
}

 */

- (void)dealloc
{
    [_manager.operationQueue cancelAllOperations];
    _manager = nil;
//    NSLog(@"IGHttpRequestManager has been killed : %@",self);
}

@end
