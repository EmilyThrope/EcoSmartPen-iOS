//
//  AddCatrideViewController.h
//  ECOSmartPen
//
//  Created by apple on 8/8/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AddCatrideViewController : UIViewController
{
    int colorCount;
    UIView              *maskView;
    UILabel             *mProgressLabel;
    MBProgressHUD       *HUD;
}

@property (strong, nonatomic) IBOutlet UIImageView *imgCartridge;

@property (strong, nonatomic) IBOutlet UITextField *txtSampleID;
@property (strong, nonatomic) IBOutlet UITextField *txtSampleName;
@property (weak, nonatomic) IBOutlet UILabel *lblColor;
@property (weak, nonatomic) IBOutlet UIView *mColorView;

@end
