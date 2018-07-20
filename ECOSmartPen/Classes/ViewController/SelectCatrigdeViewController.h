//
//  SelectCatrigdeViewController.h
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SelectCatrigdeViewController : UIViewController<MBProgressHUDDelegate>
{
    NSInteger           selectIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgBattery;
@property (strong, nonatomic) IBOutlet UITableView *catTableView;
@property (strong, nonatomic) IBOutlet UIView *mMenuView;
@property (strong, nonatomic) IBOutlet UIView *mChildSafetyView;
@property (strong, nonatomic) IBOutlet UIButton *childSafetyButton;
@property (weak, nonatomic) IBOutlet UILabel *lblBatteryLevel;

@property (weak, nonatomic) IBOutlet UILabel *lblChildOn;
@property (weak, nonatomic) IBOutlet UILabel *lblChildOff;

@property (weak, nonatomic) IBOutlet UILabel *lblCoinValue;

@end
