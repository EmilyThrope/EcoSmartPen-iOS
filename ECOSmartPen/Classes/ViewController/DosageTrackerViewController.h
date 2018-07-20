//
//  DosageTrackerViewController.h
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CorePlot-CocoaTouch.h"
#import "PopoverViewController.h"
#import "UIPopoverController+iPhone.h"

@interface DosageTrackerViewController : UIViewController<MBProgressHUDDelegate, CPTPlotDataSource,CPTPlotSpaceDelegate, CalendarViewDelegate, UIPopoverControllerDelegate>
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
@property (weak, nonatomic) IBOutlet UIButton *btnCatridge;
@property (strong, nonatomic) IBOutlet UIView *mMenuView;
@property (strong, nonatomic) IBOutlet UIView *mChildSafetyView;

@property (weak, nonatomic) IBOutlet UIView *mCalendarView;
@property (weak, nonatomic) IBOutlet UIView *mCatridgeSelectView;
@property (weak, nonatomic) IBOutlet UITableView *catTableView;

@property (strong, nonatomic) IBOutlet UIView *mAssociatedFeelingsView;
@property (strong, nonatomic) IBOutlet UIView *mSymptomsRelievedView;
@property (weak, nonatomic) IBOutlet UILabel *lblTotal;

@property (strong, nonatomic) IBOutlet UILabel *lblTodayUsage;
@property (strong, nonatomic) IBOutlet UILabel *lblWeekUsage;
@property (strong, nonatomic) IBOutlet UIView *mWorkStationChildView;
@property (strong, nonatomic) IBOutlet UIButton *childSafetyButton;
@property (weak, nonatomic) IBOutlet UIButton *btnDateSel;
@property (weak, nonatomic) IBOutlet UIButton *btnDateLastSel;

@property (weak, nonatomic) IBOutlet UILabel *lblBatteryLevel;

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

@property (weak, nonatomic) IBOutlet UIButton *closeSelectingCartrigeButton;

@property (weak, nonatomic) IBOutlet UILabel *lblCoinValue;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrView;

@property bool isEmailing;

//instagram
@property (nonatomic, retain)UIDocumentInteractionController *documentController;
@property (weak, nonatomic) IBOutlet UITextField *txtIncludeInAlgo;
- (IBAction)btnIncludeInAlgoClicked:(id)sender;


@end
