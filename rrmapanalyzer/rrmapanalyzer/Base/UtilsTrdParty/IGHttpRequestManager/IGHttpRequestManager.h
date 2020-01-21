//
//  IGHttpRequestManager.h
//  HengYiYing
//
//  Created by ideago63 on 16/8/22.
//  Copyright © 2016年 ideago. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "JMBasicViewProvider.h"
#import "AFHTTPSessionManager.h"
#import "RRProgressView.h"

typedef enum : NSUInteger {
    IGHttpRequestMethodGet,
    IGHttpRequestMethodPost,
}IGHttpRequestMethod;

@interface IGHttpRequestManager : NSObject
@property (nonatomic,strong) AFHTTPSessionManager *manager;
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *cachePath;
@property (nonatomic,strong) id parameters;
@property (nonatomic,assign) BOOL encryped;
@property (nonatomic,assign) NSTimeInterval timeout;
@property (nonatomic,assign) BOOL needUseLoadingView;
@property (nonatomic,assign) BOOL needCheckLoginStatus;

@property (nonatomic,assign) BOOL canceled;

+ (instancetype)newInstance;

+ (instancetype)getRequestWithUrl:(NSString *)url parameters:(id)parameters isJSON:(BOOL)isJSON cachePath:(NSString *)path withSuccessBlock:(void (^)(id))successBlock withFailBlock:(void (^)(NSError *))failBlock withWaitingBlock:(void (^)())waitingBlock;

+ (instancetype)postRequestWithUrl:(NSString *)url parameters:(id)parameters isJSON:(BOOL)isJSON cachePath:(NSString *)path withSuccessBlock: (void(^)(id responseObject)) successBlock withFailBlock:(void(^)(NSError *error)) failBlock withWaitingBlock:(void(^)())waitingBlock;

/**
 获取数据，如果有缓存的话，会从缓存区数据，没有再从服务器拉数据
 */
- (void)loadData;

/**
 强制从服务器拉数据
 */
- (void)loadDataFromServerHasLoadingView:(BOOL)hasLoadingView;

- (void)stop;

// 再次开始使用loadingView
//- (void)beginUseLoadingView;

// 暂停使用loadingView
//- (void)stopUseLoadingView;

//- (void)handleNetworkErrorViewForController:(UIViewController *)controller backAction:(TapAction)backAction reloadAction:(TapAction)reloadAction loadingViewFrame:(CGRect)loadingViewFrame loadingViewHasButton:(BOOL)hasButton;

- (void)downloadFile:(NSString * )fileUrl localFileName:(NSString *)localFileName callback:(RRSuccessDict)callback hud:(RRProgressView *)hud;

- (void)cancelDownloading;

@end
