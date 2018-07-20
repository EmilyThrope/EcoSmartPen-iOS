//
//  ProfileViewController.h
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Foundation;

@interface ProfileWebViewController : UIViewController

{
    __weak IBOutlet UIWebView *webView;
}

@property (nonatomic,strong) UIWebView* webView;

@end
