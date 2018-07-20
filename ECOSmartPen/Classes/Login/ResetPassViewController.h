//
//  LoginViewController.h
//  SmartHub
//
//  Created by Anaconda on 11/25/14.
//  Copyright (c) 2014 Panda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface ResetPassViewController : UIViewController<UIAlertViewDelegate, MBProgressHUDDelegate, UITextInputDelegate>
{

}

@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UILabel *mProgressLabel;
@property (strong, nonatomic) MBProgressHUD *HUD;

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

@end
