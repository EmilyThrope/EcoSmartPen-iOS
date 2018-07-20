//
//  ProfileViewController.m
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import "ProfileWebViewController.h"


@interface ProfileWebViewController ()
{

}



@end

@implementation ProfileWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *myURL = [NSURL URLWithString:@"https://www.mydxlife.com"];
    NSURLRequest * myRequest = [NSURLRequest requestWithURL:myURL];
    [_webView loadRequest:myRequest];
    
    UIWebView *webView1 = [[UIWebView alloc]init];
    NSString *urlString = @"https://www.mydxlife.com";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [webView1 loadRequest:urlRequest];
    [self.view addSubview:webView1];

}
- (void)viewWillAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

@end
