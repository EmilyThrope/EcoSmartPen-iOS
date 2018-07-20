//
//  DosageSchedulerViewController.h
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CalendarView.h"
#import <AVFoundation/AVFoundation.h>

@interface DosageSchedulerViewController : UIViewController<MBProgressHUDDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    int dosagemount;
    int dayCount;
    int dosageTime;
}

@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UILabel *mProgressLabel;
@property (strong, nonatomic) MBProgressHUD *HUD;

@property (weak, nonatomic) IBOutlet UIImageView *imgBattery;
@property (strong, nonatomic) IBOutlet UILabel *lblDosageLimit;
@property (strong, nonatomic) IBOutlet UIView *mMenuView;
@property (strong, nonatomic) IBOutlet UIView *mChildSafetyView;

@property (weak, nonatomic) IBOutlet UIView *mDayList;

@property (strong, nonatomic) IBOutlet UIButton *childSafetyButton;
@property (weak, nonatomic) IBOutlet UILabel *lblBatteryLevel;
@property (weak, nonatomic) IBOutlet UILabel *lblDay;
@property (weak, nonatomic) IBOutlet UITextField *txtDay;

@property (weak, nonatomic) IBOutlet UITextField *txtDosageTime;

@property (weak, nonatomic) IBOutlet UILabel *lblChildOn;
@property (weak, nonatomic) IBOutlet UILabel *lblChildOff;
@property (weak, nonatomic) IBOutlet UILabel *lblCatridgeName;

@property (weak, nonatomic) IBOutlet UILabel *lblCoinValue;
@property (strong, nonatomic) IBOutlet UIButton *closeSelectingCartrigeButton;

@end
