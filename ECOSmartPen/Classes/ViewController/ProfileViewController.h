//
//  ProfileViewController.h
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ProfileViewController : UIViewController<MBProgressHUDDelegate>

{
    
    UIView              *maskView;
    UILabel             *mProgressLabel;
    MBProgressHUD       *HUD;
    
    NSArray *arrHeights;
    UIActionSheet  *actoinHeight;
    UIActionSheet *actionGender;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgBattery;

@property (weak, nonatomic) IBOutlet UIImageView *imgUser;

@property (strong, nonatomic) IBOutlet UIView *mMenuView;
@property (strong, nonatomic) IBOutlet UIView *mChildSafetyView;
@property (strong, nonatomic) IBOutlet UIButton *childSafetyButton;
@property (weak, nonatomic) IBOutlet UILabel *lblBatteryLevel;

@property (weak, nonatomic) IBOutlet UILabel *lblChildOn;
@property (weak, nonatomic) IBOutlet UILabel *lblChildOff;

@property (weak, nonatomic) IBOutlet UITextField *txtSex;
@property (weak, nonatomic) IBOutlet UITextField *txtDOB;
@property (weak, nonatomic) IBOutlet UITextField *txtHeight;
@property (weak, nonatomic) IBOutlet UITextField *txtWeight;

@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (strong, nonatomic) IBOutlet UIView *viewMainBack;

@property (weak, nonatomic) IBOutlet UILabel *lblCoinValue;
@end
