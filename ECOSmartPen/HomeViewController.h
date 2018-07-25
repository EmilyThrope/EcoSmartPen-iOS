//
//  HomeViewController.h
//  ECOSmartPen
//
//  Created by apple on 2018/4/20.
//  Copyright © 2018 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CorePlot-CocoaTouch.h"
#import "PopoverViewController.h"
#import "UIPopoverController+iPhone.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface HomeViewController : UIViewController<MBProgressHUDDelegate, CPTPlotDataSource,CPTPlotSpaceDelegate, CalendarViewDelegate, UIPopoverControllerDelegate>
{
    UIView              *maskView;
    UILabel             *mProgressLabel;
    MBProgressHUD       *HUD;
    NSMutableArray      *graphFirstValues;
    NSMutableArray      *graphSecondValues;
    NSMutableArray      *graphThirdValues;
    NSMutableArray      *graphLabels;
    
    int sel_year;
    int sel_month;
    int sel_day;
    int sel_dayofweek;
    
    int sel_last_year;
    int sel_last_month;
    int sel_last_day;
    int sel_last_dayofweek;
    
    int sel_day_mode;
    
    NSInteger selectCatIndex;
    
    int  colorIndex;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;

@property (strong, nonatomic) IBOutlet UIButton *btnCatridge;
@property (strong, nonatomic) IBOutlet UIView *mMenuView;
@property (strong, nonatomic) IBOutlet UIView *mChildSafetyView;
@property (strong, nonatomic) IBOutlet UIView *mTrackerFeelingView;
@property (strong, nonatomic) IBOutlet UIView *mTrackerSymptomsView;
@property (strong, nonatomic) IBOutlet UIView *mCalendarView;
@property (strong, nonatomic) IBOutlet UIView *mCatridgeSelectView;
@property (strong, nonatomic) IBOutlet UITableView *catTableView;
@property (strong, nonatomic) IBOutlet UIView *mTrackerFeelView;

@property (strong, nonatomic) IBOutlet UIView *mAssociatedFeelingsView;
@property (strong, nonatomic) IBOutlet UIView *mSymptomsRelievedView;
@property (strong, nonatomic) IBOutlet UILabel *lblTotal;

@property (strong, nonatomic) IBOutlet UILabel *lblTodayUsage;
@property (strong, nonatomic) IBOutlet UILabel *lblWeekUsage;
@property (strong, nonatomic) IBOutlet UIView *mWorkStationChildView;
@property (strong, nonatomic) IBOutlet UIButton *childSafetyButton;
@property (strong, nonatomic) IBOutlet UIButton *btnDateSel;
@property (strong, nonatomic) IBOutlet UIButton *btnDateLastSel;

@property (strong, nonatomic) IBOutlet UIButton *btnFeelYes;
@property (strong, nonatomic) IBOutlet UIButton *btnFeelNo;

@property (strong, nonatomic) IBOutlet UILabel *lblBatteryLevel;

@property CPTScatterPlot *firstPlot, *secondPlot, *thirdPlot;
@property (nonatomic, strong) CPTGraphHostingView *pressure_hostView;
@property (nonatomic, strong) CPTGraph *pressure_graph;
@property (strong, nonatomic) IBOutlet UIView *mGraphView;

@property (weak, nonatomic) IBOutlet UILabel *mLblFeelingsCat;

@property (weak, nonatomic) IBOutlet UILabel *mLblAssoCat;
@property (weak, nonatomic) IBOutlet UILabel *mLblSympCat;
@property (weak, nonatomic) IBOutlet UIButton *btnGraphCat;

@property (weak, nonatomic) IBOutlet UIImageView *imgBattery;
@property (weak, nonatomic) IBOutlet UILabel *lblAverageHour;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;

@property (weak, nonatomic) IBOutlet UILabel *lblChildOn;
@property (weak, nonatomic) IBOutlet UILabel *lblChildOff;
@property (weak, nonatomic) IBOutlet UILabel *lblMyDose;
@property (weak, nonatomic) IBOutlet UIImageView *imgVapeLevel;
@property (weak, nonatomic) IBOutlet UILabel *lblHomeTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCoinValue;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollFFView;

@property (weak, nonatomic) IBOutlet UILabel *doseCartridgeName;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmDosageName;

@property (strong, nonatomic) AVAudioPlayer * audioPlayer;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIButton *btnUserImage;

@end
