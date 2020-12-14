//
//  RRSMapParser.m
//  rrmapanalyzer
//
//  Created by jianbin on 2020/12/14.
//  Copyright © 2020 jim. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "RRSMapParser.h"

@interface RRSMapParser()

@property (nonatomic,strong) JSContext            *jscontext;

@end

@implementation RRSMapParser

static RRSMapParser* _instance = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    }) ;
    
    return _instance ;
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

- (void)parse:(NSURL *)url result:(void (^)(NSDictionary * _Nonnull))result {
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.01*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *mapData = [NSData dataWithContentsOfURL:url];
        NSData *unGzedMapData = [mapData gzipInflate];
        NSString *base64MapData = [unGzedMapData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
        JSValue *func = self.jscontext[@"parse"];
        JSValue *value = [func callWithArguments:@[base64MapData]];
        NSDictionary *resultDict = [value toObject];
        
        NSLog(@"parse done:%@", resultDict);
        if (result) {
            result(resultDict);
        }
    });
}

@end
