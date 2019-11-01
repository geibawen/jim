//
//  ViewController.m
//  rrmapanalyzer
//
//  Created by jianbin on 2019/7/29.
//  Copyright © 2019年 jim. All rights reserved.
//

#import "ViewController.h"

#import "GCDAsyncUdpSocket.h"

@interface ViewController () <GCDAsyncUdpSocketDelegate>


@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startRRConecting];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)startRRConecting {
    NSLog(@"RRAppLog - ConnectAp - startRRConecting");
    
    GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    NSError *error = nil;
    
    //绑定本地端口
    [socket bindToPort:6667 error:&error];
    
    if (error) {
        NSLog(@"RRAppLog - ConnectAp - error1:%@",error);
    }
    
    //启用广播
    [socket enableBroadcast:YES error:&error];
    
    if (error) {
        NSLog(@"RRAppLog - ConnectAp - error2:%@",error);
        return;
    }
    
    //开始接收数据(不然会收不到数据)
    [socket beginReceiving:&error];
    
    if (error) {
        NSLog(@"RRAppLog - ConnectAp - error3:%@",error);
        return;
    }
    
//    [self.udpSocket sendData:@"123" toHost:@"255.255.255.255" port:55559 withTimeout:10 tag:100];
    
    self.udpSocket = socket;
    
}

#pragma mark - socket delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    NSLog(@"Got udp");
    
//    [self.udpSocket close];
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"RRAppLog - ConnectAp - recieved udp:%@",msg);
    
}

@end
