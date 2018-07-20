//
//  GuestUserViewController.h
//  ECOSmartPen
//
//  Created by apple on 9/15/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface GuestUserViewController : UIViewController<MBProgressHUDDelegate>

@property (strong, nonatomic) IBOutlet UIView *mMenuView;
@property (strong, nonatomic) IBOutlet UIView *mChildSafetyView;
@property (strong, nonatomic) IBOutlet UIButton *childSafetyButton;

@property (strong, nonatomic) IBOutlet UITextField *txtOldPwd;
@property (strong, nonatomic) IBOutlet UITextField *txtPwd;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirmPwd;

@end
