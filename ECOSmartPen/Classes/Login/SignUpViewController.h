//
//  SignUpViewController.h
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface SignUpViewController : UIViewController<MBProgressHUDDelegate>

{
    UIView              *maskView;
    UILabel             *mProgressLabel;
    MBProgressHUD       *HUD;
    
    UIAlertView *alertLoading;
    NSArray *arrHeights;
    UIActionSheet  *actoinHeight;
    UIActionSheet *actionGender;
    
}
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirm;
@property (weak, nonatomic) IBOutlet UITextField *txtBirth;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

@property (weak, nonatomic) IBOutlet UITextField *txtSex;
@property (weak, nonatomic) IBOutlet UITextField *txtWeight;
@property (weak, nonatomic) IBOutlet UITextField *txtHeight;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UIView *viewWorkStation;
@property (strong, nonatomic) IBOutlet UIView *mCalendarView;

@end
