//
//  XLJwebVController.m
//  二维码扫描demo
//
//  Created by m on 2017/1/5.
//  Copyright © 2017年 XLJ. All rights reserved.
//

#import "XLJwebVController.h"

@interface XLJwebVController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation XLJwebVController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor redColor];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"111");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
}

@end
