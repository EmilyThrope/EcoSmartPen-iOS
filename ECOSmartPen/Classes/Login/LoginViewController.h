//
//  LoginViewController.h
//  SmartHub
//
//  Created by Anaconda on 11/25/14.
//  Copyright (c) 2014 Panda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface LoginViewController : UIViewController<UIAlertViewDelegate, MBProgressHUDDelegate, UITextInputDelegate>
{
    BOOL                    mIsRemember;
    NSTimer                 *mLoginTimer;
    
    IBOutlet UIView         *mBackgroundView;
    IBOutlet UIView         *mServerView;
    IBOutlet UIButton       *mIsRememberBtn;

    IBOutlet UITextField    *mUserName;
    IBOutlet UITextField    *mPassword;

}

@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UILabel *mProgressLabel;
@property (strong, nonatomic) MBProgressHUD *HUD;


- (IBAction)clickLoginBtn:(id)sender;
//- (IBAction)clickSignUpBtn:(id)sender;
-(void) cancelProgress;


@end
