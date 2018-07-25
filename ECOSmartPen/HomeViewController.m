//
//  HomeViewController.m
//  ECOSmartPen
//
//  Created by apple on 2018/4/20.
//  Copyright © 2018 mac. All rights reserved.
//

#import "HomeViewController.h"
#import "Const.h"
#import <sqlite3.h>
#import <AudioToolbox/AudioToolbox.h>

#import "PopoverViewController.h"
#import "UIPopoverController+iPhone.h"
#import "Const.h"

@interface HomeViewController ()
{
    PopoverViewController *viewPopController;
    UIPopoverController *popover;
    
    
    Boolean readBatteryFlag;
    
    NSMutableArray *checkFeelingArray;
    NSMutableArray *checkSymptomArray;
    
    NSMutableArray *feelingsArray;
    NSMutableArray *symptomsArray;
    NSMutableArray *catridgsArray;
    NSMutableArray *catridgsColorArray;
    
    NSString        *currentTime;
    int             currentDose;
    Boolean         shareState;
    Boolean         feelingSaveFlag ;
    
    sqlite3         *database;
    
    Boolean         save_allow;
    int             old_doseVal;
    NSTimer         *autoSaveTimer;
    
    int             plotXStartRange;//-24 * 6;
    int             plotXLengthRange;// 24 * 7;
    int             plotXInterval;
    int             plotYMaxRange;
    int             plotYMinRange;
    int             plotYInterval;
    
    
    NSTimer         *increaseLevelTimer;
    NSTimer         *decreaseLevelTimer;
    int             levelCount;
    int             currentPageIndex;
    
    int             coinTempValue;
    int             feel_state;
    
    NSString        *saveFeel;
    NSString        *saveSymp;
}

@property (weak, nonatomic) IBOutlet CalendarView *calenView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    catridgsArray = [[NSMutableArray alloc] init];
    catridgsColorArray = [[NSMutableArray alloc] init];
    
    currentTime = nil;
    currentDose = 0;
    shareState = NO;
    feelingSaveFlag = false;
    
    save_allow = false;
    old_doseVal = 0;
    autoSaveTimer = nil;
    
    
    [self addGestureRecogniser:_mMenuView];
    [self addGestureRecogniser:_mChildSafetyView];
    //[self addGestureRecogniser:_mCalendarView];
    //[self addGestureRecogniser:_mCatridgeSelectView]; do not use (for didselect)
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleNotification:)
                                                 name:NotiValueChange
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleWriteSuccess:)
                                                 name:WriteSuccessChange
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleDisconnected:)
                                                 name:DisconnectEvent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleReadBatteryValue:)
                                                 name:ReadBatteryValueChange
                                               object:nil];
    
    childSafetyValue = 0;
    [self changeChildSafetyButtonImage:childSafetyValue];
    
    [self initGraph];
    [self progressInit];
    [self initDatabase];
    [self initArray];
    [self showDates];
    [self initDatePicker];
    [self.catTableView setBackgroundView:nil];
    [self.catTableView setBackgroundColor:[UIColor clearColor]];
    [self.catTableView setSeparatorColor:[UIColor clearColor]];
    
    //[self refreshAllData];
    
    
    int width = self.view.frame.size.width;
    _scrollFFView.contentSize = CGSizeMake(width*3, 230);
    
    
//    _btnUserImage.layer.cornerRadius= 25;
//    _btnUserImage.clipsToBounds = true;
    
    // Dragon_3
    _btnUserImage.layer.cornerRadius  = _btnUserImage.frame.size.width / 2;
    _btnUserImage.clipsToBounds = YES;
}


-(void) initDatePicker
{
    viewPopController = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverContentController"];
    
    popover = [[UIPopoverController alloc] initWithContentViewController:viewPopController];
    popover.popoverContentSize = CGSizeMake(300, 320);
    popover.delegate = self;
    
    int widths = [[UIScreen mainScreen] bounds].size.width - 40;
    
    self.calenView.dayCellWidth = widths / 7;
    self.calenView.dayCellHeight = 50;
    self.calenView.monthCellWidth = widths / 3;
    self.calenView.monthCellHeight = 60;
    self.calenView.yearCellWidth = widths / 5;
    self.calenView.yearCellHeight = 80;
    
    self.calenView.shouldShowHeaders = YES;
    self.calenView.calendarDelegate = self;
    [self.calenView refresh];
}



- (IBAction)dayButtonClick:(id)sender {
    NSCalendar *cal = [NSCalendar currentCalendar];
    //CGRect frame = _mCalendarView.frame;
    //int x = (frame.size.width - self.calenView.frame.size.width)/2;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = sel_year;
    comps.month= sel_month;
    comps.day = sel_day;
    NSDate *toDate = [cal dateFromComponents:comps];
    [self.calenView setCurrentDate:toDate];
    [_mCalendarView setHidden:NO];
    sel_day_mode = SELECT_DAY_FIRST;
}
- (IBAction)dayLastButtonClick:(id)sender {
    NSCalendar *cal = [NSCalendar currentCalendar];
    //CGRect frame = _mCalendarView.frame;
    //int x = (frame.size.width - self.calenView.frame.size.width)/2;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = sel_last_year;
    comps.month= sel_last_month;
    comps.day = sel_last_day;
    NSDate *toDate = [cal dateFromComponents:comps];
    [self.calenView setCurrentDate:toDate];
    [_mCalendarView setHidden:NO];
    sel_day_mode = SELECT_DAY_LAST;
}

- (void)didChangeCalendarDate:(NSDate *)date
{
    NSLog(@"didChangeCalendarDate:%@", date);
}

- (void)didChangeCalendarDate:(NSDate *)date withType:(NSInteger)type withEvent:(NSInteger)event
{
    NSLog(@"didChangeCalendarDate:%@ withType:%ld withEvent:%ld", date, (long)type, (long)event);
    
    if(event == 1 && type == 0)
    {
        //NSString *weekString[] =  {@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"};
        //NSString *monthString[] = {@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"};
        
        unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit|NSWeekdayCalendarUnit;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:units fromDate:date];
        [components setTimeZone:[NSTimeZone localTimeZone]];
        NSInteger year = [components year];
        NSInteger month = [components month];
        NSInteger day = [components weekday];
        NSInteger daydate = [components day];
        if(sel_day_mode == SELECT_DAY_FIRST)
        {
            int diff = [self diffDays:(int)year month:(int)month day:(int)daydate lYear:sel_last_year lMonth:sel_last_month lDay:sel_last_day];
            if(diff>=0)
            {
                sel_year = (int)year;
                sel_month = (int)month;
                sel_day = (int)daydate;
                sel_dayofweek = (int)(day-1);
            }
            else
            {
                sel_year = sel_last_year;
                sel_month = sel_last_month;
                sel_day = sel_last_day;
                sel_dayofweek = sel_last_dayofweek;
            }
            //NSString *res1 = [NSString stringWithFormat:@"%@, %@ %d, %d", weekString[day - 1], monthString[month-1], (int)daydate, (int)(year)];
            NSString *res1 = [NSString stringWithFormat:@"Date : %02d/%02d/%04d - ", sel_month, sel_day, sel_year];
            [_btnDateSel setTitle:res1 forState:UIControlStateNormal];
        }
        else if(sel_day_mode == SELECT_DAY_LAST)
        {
            int diff = [self diffDays:sel_year month:sel_month day:sel_day lYear:(int)year lMonth:(int)month lDay:(int)daydate];
            if(diff>=0)
            {
                sel_last_year = (int)year;
                sel_last_month = (int)month;
                sel_last_day = (int)daydate;
                sel_last_dayofweek = (int)(day-1);
            }
            else
            {
                sel_last_year = sel_year;
                sel_last_month =sel_month;
                sel_last_day = sel_day;
                sel_last_dayofweek =sel_dayofweek;
            }
            
            
            //NSString *res1 = [NSString stringWithFormat:@"%@, %@ %d, %d", weekString[day - 1], monthString[month-1], (int)daydate, (int)(year)];
            NSString *res1 = [NSString stringWithFormat:@"%02d/%02d/%04d", sel_last_month, sel_last_day, sel_last_year];
            [_btnDateLastSel setTitle:res1 forState:UIControlStateNormal];
        }
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [self sympArray:tempArray];
        [self loadSymptoms:tempArray];
        [self loadGraph];
        tempArray = nil;
        feelingSaveFlag = false;
        [_mCalendarView setHidden:YES];
    }
}

- (void)didDoubleTapCalendar:(NSDate *)date withType:(NSInteger)type
{
    NSLog(@"didDoubleTapCalendar:%@ withType:%ld", date, (long)type);
}

- (IBAction)popoverButtonAction:(UIButton *)sender
{
    [popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - refresh

-(void) refreshAllData
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self feelArray:tempArray];
    [self loadFeeling:tempArray];
    [tempArray removeAllObjects];
    [self sympArray:tempArray];
    [self loadSymptoms:tempArray];
    tempArray = nil;
    
    [self loadCatrides];
    [self loadGraph];
    
}
-(void) initArray
{
    checkFeelingArray = [[NSMutableArray alloc] init];
    for(int i=0; i<13; i++)
        [checkFeelingArray addObject:[NSNumber numberWithBool:false]];
    
    checkSymptomArray = [[NSMutableArray alloc] init];
    for(int i=0; i<9; i++)
        [checkSymptomArray addObject:[NSNumber numberWithBool:false]];
    
    feelingsArray = [[NSMutableArray alloc] init];
    symptomsArray= [[NSMutableArray alloc] init];
}


-(void) progressInit
{
    // Do any additional setup after loading the view.
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x, self.view.center.y, 50, 50)];
    [button addTarget:self action:@selector(cancelProgress) forControlEvents:UIControlEventTouchUpInside];
    button.center = HUD.center;
    [HUD addSubview:button];
    
    HUD.delegate = self;
    [HUD hide:YES];
    
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [maskView setBackgroundColor:[UIColor blackColor]];
    maskView.alpha = 0.4;
    
    mProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 50, ScreenHeight/2 + 40, 100, 30)];
    mProgressLabel.text = @"";
    mProgressLabel.textAlignment = NSTextAlignmentCenter;
    mProgressLabel.textColor = [UIColor whiteColor];
    mProgressLabel.backgroundColor = [UIColor clearColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSString*)getTourVapePassState
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"first";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:@"vape_tour"];
    }
    return result;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self gotoScreen:selectScreenIndex];
    
    NSString *res = [self getTourVapePassState];
    if(![res isEqualToString:@"pass"])
    {
        [self performSegueWithIdentifier:@"segueTourVape" sender:nil];
    }
    
    if(selectScreenIndex != SCREEN_LOGOUT)
    {
        if([[self getConnectStatus] isEqualToString:@"disconnect"])  //2017/01/12 anaconda
        {
            if([[self getSavedDeviceName] length]>3)
            {
                [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(scanDevices) userInfo:nil repeats:NO];
                [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(connectProcessing) userInfo:nil repeats:NO];
            }
        }
        
        [self changeChildSafetyButtonImage:childSafetyValue];
        
        [self loadCatridgeFromDatabase];
        
        if([[self getConnectStatus] isEqualToString:@"connect"] && childSafetyValue < CHILD_SAFETY_ON)
        {
            [self readChildSaftetyStatus];
        }
        
        [self refreshAllData];
        
        [_lblBatteryLevel setText:[NSString stringWithFormat:@"%d %%",batteryLevel]];
        [self setBattery:batteryLevel];
        
        [_lblCoinValue setText:[NSString stringWithFormat:@"%d coins",coinValue]];
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString* result=(NSString*)[standardUserDefaults valueForKey:KEY_FIRSTNAME];
        _lblUserName.text = [NSString stringWithFormat:@"Hi, %@", result];
        
        [self initImageProcess];
    }
}



-(void) scanDevices
{
    [self showProgress];
    [mBLEComm startScanDevicesWithInterval:1.5 CompleteBlock:^(NSArray *devices)
     {
         for (CBPeripheral *per in devices)
         {
             if([per.name containsString:@"VAPE"])
             {
                 NSLog(@"devices : %@", per.name);
             }
         }
         
     }];
}

-(void) connectProcessing
{
    if([[self getConnectStatus] isEqualToString:@"disconnect"])
    {
        [self showProgress];
        NSString *addr = [self getSavedDeviceAddress];
        if([addr length] < 2)
        {
            [self hideProgress];
            return;
        }
        NSLog(@"address : %@", addr);
        [mBLEComm connectionWithDeviceUUID:addr TimeOut:5 CompleteBlock:^(CBPeripheral *device_new, NSError *err)
         {
             if (device_new)
             {
                 NSLog(@"Discovery servicess...");
                 [mBLEComm discoverServiceAndCharacteristicWithInterval:3 CompleteBlock:^(NSArray *serviceArray, NSArray *characteristicArray, NSError *err)
                  {
                      [mBLEComm setNotificationForCharacteristicWithServiceUUID:@"AAA0" CharacteristicUUID:@"AAA5" enable:YES];
                      sleep(0.1);
                      [mBLEComm setNotificationForCharacteristicWithServiceUUID:@"180F" CharacteristicUUID:@"2A19" enable:YES];
                      [self showToastShort:@"Device Connected"];
                      NSLog(@"Device Connected");
                      readBatteryFlag = true;
                      [self readBatteryValue];
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self saveConnectStatus:true];
                      });
                  }];
             }
             else
             {
                 NSLog(@"Connect device failed.");
                 [self showToastShort:@"Device discconect."];
                 //[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(connectProcessing) userInfo:nil repeats:NO];
                 [self hideProgress];
             }
         }];
    }
}

-(void)addGestureRecogniser:(UIView *)touchView{
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maskViewTouch)];
    [touchView addGestureRecognizer:singleTap];
}
-(void)maskViewTouch{
    [_mMenuView setHidden:YES];
    [_mChildSafetyView setHidden:YES];
    //[_mCalendarView setHidden:YES];
    //[_mCatridgeSelectView setHidden:YES];
}


#pragma mark - Button Event

- (IBAction)homeButtonClick:(id)sender {
    [self gotoScreen:SCREEN_HOME];
}
- (IBAction)yourESPButtonClick:(id)sender {
    [self gotoScreen:SCREEN_YOURESP];
}
- (IBAction)dosageSchedulerButtonClick:(id)sender {
    [self gotoScreen:SCREEN_DOSAGESCHEDULER];
}
- (IBAction)dosageTrackerButtonClick:(id)sender {
    [self gotoScreen:SCREEN_DOSAGETRACKER];
}
- (IBAction)selectCatridgeButtonClick:(id)sender {
    [self gotoScreen:SCREEN_SELECTCATRIDGE];
}

- (IBAction)profileButtonClick:(id)sender {
    [self gotoScreen:SCREEN_PROFILE];
}
- (IBAction)guestUserButtonClick:(id)sender {
    [self gotoScreen:SCREEN_GUESTUSER];
}
- (IBAction)logoutButtonClick:(id)sender {
    [self gotoScreen:SCREEN_LOGOUT];
}

- (IBAction)learnButtonClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:learnSiteURL]];
    [_mMenuView setHidden:YES];
}

-(void) gotoScreen:(int) index
{
    selectScreenIndex = SCREEN_NONE;
    switch(index)
    {
        case SCREEN_YOURESP:
            [self performSegueWithIdentifier:@"segueYourESP" sender:self];
            selectScreenIndex = SCREEN_YOURESP;
            break;
        case SCREEN_DOSAGESCHEDULER:
            [self performSegueWithIdentifier:@"segueDosageScheduler" sender:self];
            selectScreenIndex = SCREEN_DOSAGESCHEDULER;
            break;
        case SCREEN_SELECTCATRIDGE:
            [self performSegueWithIdentifier:@"segueSelectCatridge" sender:self];
            selectScreenIndex = SCREEN_SELECTCATRIDGE;
            break;
        case SCREEN_DOSAGETRACKER:
            [self performSegueWithIdentifier:@"segueDosageTracker" sender:self];
            selectScreenIndex = SCREEN_SELECTCATRIDGE;
            break;
        case SCREEN_PROFILE:
            [self performSegueWithIdentifier:@"segueYourProfile" sender:self];
            selectScreenIndex = SCREEN_PROFILE;
            break;
        case SCREEN_GUESTUSER:
            [self performSegueWithIdentifier:@"segueGuestUser" sender:self];
            selectScreenIndex = SCREEN_GUESTUSER;
            break;
        case SCREEN_LOGOUT:
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
    [_mMenuView setHidden:YES];
    [self hideConfirmFeeling];
    NSLog(@"DT selectScreenIndex : %d", selectScreenIndex);
}

- (IBAction)menuButtonClick:(id)sender {
    [_mMenuView setHidden:NO];
}
- (IBAction)childSafetyButtonClick:(id)sender {
    //[_mChildSafetyView setHidden:NO];
    NSString *str = _lblTotal.text;
    if([str isEqualToString:@"Child Safety OFF"]) // Dragon_3
        [self childSafetyOffButtonClick:nil];
    else
        [self childSafetyOnButtonClick:nil];
}

- (IBAction)childSafetyOffButtonClick:(id)sender {
    NSLog(@"On Button Click");
    Byte data[3];
    data[0] = 0xA1;
    data[1] = 1;
    data[2] = 1;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:3];
    //gotoFlag = 1;
    [self sendBLEData:cmdData];}

- (IBAction)childSafetyOnButtonClick:(id)sender {
    NSLog(@"Off Button Click");
    Byte data[3];
    data[0] = 0xA1;
    data[1] = 1;
    data[2] = 0;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:3];
    //gotoFlag = 1;
    [self sendBLEData:cmdData];
}


- (IBAction)feelingsButtonClick:(id)sender {
    UIButton *btn = (UIButton*)sender;
    NSString *btnSelImgName[] = {@"happy_sel", @"sad_sel", @"relaxed_sel", @"agitated_sel", @"energetic_sel", @"inactive_sel", @"social_sel", @"antisocial_sel", @"focused_sel", @"scattered_sel", @"motivated_sel", @"discouraged_sel", @"noeffect_sel"};
    NSString *btnNorImgName[] = {@"happy_nor", @"sad_nor", @"relaxed_nor", @"agitated_nor", @"energetic_nor", @"inactive_nor", @"social_nor", @"antisocial_nor", @"focused_nor", @"scattered_nor", @"motivated_nor", @"discouraged_nor", @"noeffect_nor"};
    int btag = (int)btn.tag;
    
    if(btag<100 + FEELS_COUNT)
    {
        Boolean res = [(NSNumber*)[checkFeelingArray objectAtIndex:(btag-100)] boolValue];
        if(res == false )
        {
            [btn setImage:[UIImage imageNamed:btnSelImgName[(btag-100)]] forState:UIControlStateNormal];
            if((btag-100)%2 == 0)
            {
                [self playChing];
            }
        }
        else
        {
            [btn setImage:[UIImage imageNamed:btnNorImgName[(btag-100)]] forState:UIControlStateNormal];
        }
        [checkFeelingArray replaceObjectAtIndex:(btag-100) withObject:[NSNumber numberWithBool:!res]];
        /*UIView *view = _mTrackerFeelingView;
         CGRect frame = view.frame;
         frame.origin.x = 0;
         _mTrackerFeelingView.frame = frame;*/
    }
    int count= 0;
    for(int i = 0; i<[checkFeelingArray count]; i++)
    {
        if([[checkFeelingArray objectAtIndex:i] boolValue] == true)
        {
            if(i % 2 == 0)
            {
                count++;
            }
            else
            {
                count--;
            }
        }
    }
    [_lblCoinValue setText:[NSString stringWithFormat:@"%d coins",coinTempValue+count]];
}
- (IBAction)dontShareButtonClick:(id)sender {
    Boolean res = shareState;
    if(res == false )
    {
        [_btnShare setImage:[UIImage imageNamed:@"dontshare_sel"] forState:UIControlStateNormal];
    }
    else
    {
        [_btnShare setImage:[UIImage imageNamed:@"dontshare_nor"] forState:UIControlStateNormal];
    }
    shareState = !res;
}

- (IBAction)symptomsButtonClick:(id)sender {
    UIButton *btn = (UIButton*)sender;
    NSString *btnSelImgName[] = {@"pain_sel", @"anxiety_sel", @"stress_sel", @"cancer_sel", @"epilepsy_sel", @"arthritis_sel", @"bipolar_sel", @"depression_sel", @"insomnia_sel"};
    NSString *btnNorImgName[] = {@"pain_nor", @"anxiety_nor", @"stress_nor", @"cancer_nor", @"epilepsy_nor", @"arthritis_nor", @"bipolar_nor", @"depression_nor", @"insomnia_nor"};
    int btag = (int)btn.tag;
    if(btag < 100 + SYMPTOMS_COUNT)
    {
        Boolean res = [(NSNumber*)[checkSymptomArray objectAtIndex:(btag-100)] boolValue];
        if(res == false )
        {
            [btn setImage:[UIImage imageNamed:btnSelImgName[(btag-100)]] forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:btnNorImgName[(btag-100)]] forState:UIControlStateNormal];
        }
        [checkSymptomArray replaceObjectAtIndex:(btag-100) withObject:[NSNumber numberWithBool:!res]];
    }
}



- (IBAction)feelingOKButtonClick:(id)sender {
    
    int i = 0;
    for(i = 0; i<[checkFeelingArray count]; i++)
    {
        if([[checkFeelingArray objectAtIndex:i] boolValue] == true)
        {
            break;
        }
    }
    if(i == [checkFeelingArray count])
        return;
    
    int count= 0;
    for(int i = 0; i<[checkFeelingArray count]; i++)
    {
        if([[checkFeelingArray objectAtIndex:i] boolValue] == true)
        {
            if(i % 2 == 0)
            {
                count++;
            }
            else
            {
                count--;
            }
        }
    }
    coinTempValue = coinTempValue + count;
    
    [self hideFeelings];
    [autoSaveTimer invalidate];
    autoSaveTimer = nil;
    [self showSymptoms];
    save_allow = false;
    feelingSaveFlag = true;
    
    ////////////////////////////////////////////////////////////
    levelCount = 0;
    NSString *nameStr = [NSString stringWithFormat:@"vape_level_%d", levelCount];
    _imgVapeLevel.image = [UIImage imageNamed:nameStr];
    coinValue = coinTempValue;
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateCoin) userInfo:nil repeats:NO];

}

-(void) nextDrawFeelingProcess
{
    NSString *feelStr = @"";
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self feelArray:tempArray];
    for(int i = 0; i<[tempArray count]; i++)
    {
        int val = [[tempArray objectAtIndex:i] intValue];
        if( val> 100000)
            [tempArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:val%100000]];
    }
    [self changeFeelTable:tempArray];
    
    for(int k = 0; k<[checkFeelingArray count]; k++)
    {
        if([[checkFeelingArray objectAtIndex:k] boolValue] == true)
        {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            NSMutableArray *resArray = [[NSMutableArray alloc] init];
            [self feelArray:tempArray];
            [self updateArray:tempArray NewVal:k NewArray:resArray];
            [self changeFeelTable:resArray];
            tempArray = nil;
            resArray = nil;
            
            feelStr = [NSString stringWithFormat:@"%@%dA",feelStr,k];
        }
    }
    
    [self addVape:feelStr];
    NSMutableArray *tempRArray = [[NSMutableArray alloc] init];
    [self feelArray:tempRArray];
    [self loadSymptoms:tempRArray];
    [self loadFeeling:tempRArray];
    tempArray = nil;
    saveFeel = [NSString stringWithString: feelStr];
    
    
}

- (IBAction)feelingCancelButtonClick:(id)sender {
    feelingSaveFlag = false;
    [self hideFeelings];
    [autoSaveTimer invalidate];
    autoSaveTimer = nil;
    save_allow = false;
    [self showSymptoms];
}

- (IBAction)symptomsCancelButtonClick:(id)sender {
    
    [self hideSymptoms];
}

- (IBAction)symptomsOKButtonClick:(id)sender {
    
    int i = 0;
    for(i = 0; i<[checkSymptomArray count]; i++)
    {
        if([[checkSymptomArray objectAtIndex:i] boolValue] == true)
        {
            break;
        }
    }
    if(i == [checkSymptomArray count])
        return;
    
    NSString *st = @"";
    for(i = 0; i<[checkSymptomArray count]; i++)
    {
        if([[checkSymptomArray objectAtIndex:i] boolValue] == true)
        {
            st = [st stringByAppendingString:[NSString stringWithFormat:@"%dA", i]];
        }
    }
    saveSymp = st;
    
    [self hideSymptoms];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(redrawFeelings) userInfo:nil repeats:NO];
    
}
- (IBAction)catridgeButtonClick:(id)sender {
    [_mCatridgeSelectView setHidden:NO];
}

-(void) redrawFeelings
{
    
    if(feelingSaveFlag)
        [self nextDrawFeelingProcess];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self sympArray:tempArray];
    for(int i = 0; i<[tempArray count]; i++)
    {
        int val = [[tempArray objectAtIndex:i] intValue];
        if( val> 100000)
            [tempArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:val%100000]];
    }
    [self changeSympTable:tempArray];
    
    
    for(int k = 0; k<[checkSymptomArray count]; k++)
    {
        if([[checkSymptomArray objectAtIndex:k] boolValue] == true)
        {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            NSMutableArray *resArray = [[NSMutableArray alloc] init];
            [self sympArray:tempArray];
            [self updateArray:tempArray NewVal:k NewArray:resArray];
            [self changeSympTable:resArray];
            tempArray = nil;
            resArray = nil;
        }
    }
    NSMutableArray *tempRArray = [[NSMutableArray alloc] init];
    [self sympArray:tempRArray];
    [self loadSymptoms:tempRArray];
    [self loadGraph];
    tempArray = nil;
    feelingSaveFlag = false;
    
    [self sendMyVape:saveFeel symptoms:saveSymp];
    
}

-(void) updateCoin
{
    [self sendChangeCoin];
}

- (IBAction)feelYesButtonClick:(id)sender {
    [_lblCoinValue setText:[NSString stringWithFormat:@"%d coins",coinTempValue+1]];
    feel_state = 1;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playChing];
    });
    [_btnFeelYes setImage:[UIImage imageNamed:@"feel_yes_sel"] forState:UIControlStateNormal];
    [_btnFeelNo setImage:[UIImage imageNamed:@"feel_no"] forState:UIControlStateNormal];
}
- (IBAction)feelNoButtonClick:(id)sender {
    [_lblCoinValue setText:[NSString stringWithFormat:@"%d coins",coinTempValue-1]];
     feel_state = 2;
    [_btnFeelYes setImage:[UIImage imageNamed:@"feel_yes"] forState:UIControlStateNormal];
    [_btnFeelNo setImage:[UIImage imageNamed:@"feel_no_sel"] forState:UIControlStateNormal];
}

-(void) playChing
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"ching"
                                         ofType:@"wav"]];
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];

    
    _audioPlayer = [[AVAudioPlayer alloc]
                                   initWithContentsOfURL:url
                                   error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",[error localizedDescription]);
    }
    else
    {
        //audioPlayer.delegate = self;
        [_audioPlayer play];
        //[_audioPlayer setNumberOfLoops:1]; // for continuous play
    }
}


- (IBAction)tellUSButtonClick:(id)sender {
    [self hideConfirmFeeling];
    [self showFeelings];
    
    coinTempValue = coinValue;
    if(feel_state == 2)
    {
        coinTempValue -= 1;
    }
    else if(feel_state == 1)
    {
        coinTempValue += 1;
    }
}

- (IBAction)anotherDoesButtonClick:(id)sender {
    [self hideConfirmFeeling];
    if(feel_state == 2)
    {
        coinValue -= 1;
    }
    else if(feel_state == 1)
    {
        coinValue += 1;
    }
    ///////////////////////////////////////////////
    levelCount = 0;
    NSString *nameStr = [NSString stringWithFormat:@"vape_level_%d", levelCount];
    _imgVapeLevel.image = [UIImage imageNamed:nameStr];
    [_btnFeelYes setImage:[UIImage imageNamed:@"feel_yes"] forState:UIControlStateNormal];
    [_btnFeelNo setImage:[UIImage imageNamed:@"feel_no"] forState:UIControlStateNormal];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateCoin) userInfo:nil repeats:NO];
}

#pragma mark - Move Function

-(void) showConfirmFeeling
{
    [_mTrackerFeelView setHidden:NO];
    UIView *view = _mTrackerFeelView;
    CGRect frame = view.frame;
    int main_height = view.frame.size.height;
    int top = 235;
    frame.origin.y = main_height;
    _mTrackerFeelView.frame = frame;
    
    NSLog(@"Show Confirm");
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = view.frame;
                         frame.origin.y = top;
                         view.frame = frame;
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void) hideConfirmFeeling
{
    UIView *view = _mTrackerFeelView;
    int main_height = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect frame = view.frame;
                         frame.origin.y = main_height;//+height;
                         view.frame = frame;
                     } completion:^(BOOL finished) {
                         [_mTrackerFeelView setHidden:YES];
                     }];
}
-(void) showFeelings
{
    [_mTrackerFeelingView setHidden:NO];
    UIView *view = _mTrackerFeelingView;
    CGRect frame = view.frame;
    int width = view.frame.size.width;
    frame.origin.x = -width;
    _mTrackerFeelingView.frame = frame;
    
    
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = view.frame;
                         frame.origin.x = 0;
                         view.frame = frame;
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void) hideFeelings
{
    UIView *view = _mTrackerFeelingView;
    //CGRect frame = view.frame;
    int width = view.frame.size.width;
    
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect frame = view.frame;
                         frame.origin.x = -width;
                         view.frame = frame;
                     } completion:^(BOOL finished) {
                         [_mTrackerFeelingView setHidden:YES];
                     }];
}

-(void) showSymptoms
{
    [_mTrackerSymptomsView setHidden:NO];
    UIView *view = _mTrackerSymptomsView;
    CGRect frame = view.frame;
    int width = view.frame.size.width;
    frame.origin.x = width;
    _mTrackerSymptomsView.frame = frame;
    
    [UIView animateWithDuration:0.5
                          delay:1.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = view.frame;
                         frame.origin.x = 0;
                         view.frame = frame;
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void) hideSymptoms
{
    UIView *view = _mTrackerSymptomsView;
    CGRect frame = view.frame;
    int width = view.frame.size.width;
    frame.origin.x = 0;
    _mTrackerSymptomsView.frame = frame;
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = view.frame;
                         frame.origin.x = width;
                         view.frame = frame;
                     } completion:^(BOOL finished) {
                         [_mTrackerSymptomsView setHidden:YES];
                         [_btnFeelYes setImage:[UIImage imageNamed:@"feel_yes"] forState:UIControlStateNormal];
                         [_btnFeelNo setImage:[UIImage imageNamed:@"feel_no"] forState:UIControlStateNormal];
                     }];
}

#pragma mark - Bluetooth Received
-(void) startSmoke
{
    levelCount = 0;
    increaseLevelTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(increaseLevel) userInfo:nil repeats:YES];
    
    
}

-(void) increaseLevel
{
    if(levelCount<5)
    {
        NSString *nameStr = [NSString stringWithFormat:@"vape_level_%d", levelCount];
        _imgVapeLevel.image = [UIImage imageNamed:nameStr];
        levelCount++;
    }
    else{
        [increaseLevelTimer invalidate];
    }
}
-(void)bleNotification:(NSNotification*)noti
{
    Boolean refresh_allow = false;
    NSData *receivedData = (NSData*)(noti.object);
    
    if([receivedData length] == 2)
    {// Smoke Start
        Byte *message = (Byte *)[receivedData bytes];
        if(message[0] == 0xA2)
        {
            [self startSmoke];
        }
        return;
    }
    
    
    if([receivedData length] == 3)
    {
        Byte *message = (Byte *)[receivedData bytes];
        if(message[0] == 0xA1)
        {
            NSData *receivedData = (NSData*)(noti.object);
            NSLog(@"Read Value - %@",receivedData);
            if([receivedData length]<1)
                return;
            
            Byte *message = (Byte *)[receivedData bytes];
            int val = message[2];
            if(val > 0)
            {
                childSafetyValue = CHILD_SAFETY_OFF;
                [self changeChildSafetyButtonImage:childSafetyValue];
            }
            else
            {
                childSafetyValue = CHILD_SAFETY_ON;
                [self changeChildSafetyButtonImage:childSafetyValue];
            }
            [self hideProgress];
        }
        return;
    }
    
    
    
    
    NSLog(@"Lock BLE Receive data - %@",receivedData);
    if([receivedData length]<6)
        return;
    
    [increaseLevelTimer invalidate];
    Byte *message = (Byte *)[receivedData bytes];
    short value = (message[3]<<8 | message[2]);
    int doseVal = value / 10;
    
    currentTime = [self currentDateTime];
    NSLog(@"\nBLE Noti Time - %@\n", currentTime);
    
    if(save_allow == true)
    {
        [self addVape:@"12"];
        save_allow = false;
        refresh_allow = true;
    }
    
    currentDose = 0;
    if(doseVal - old_doseVal > 0)
    {
        currentDose = doseVal - old_doseVal;
        old_doseVal = doseVal;
        coinTempValue = coinValue;
        feel_state = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showConfirmFeeling]; //[self showFeelings];
            [self clearFeelSympCheck];
            [self vibratePhone];
        });
        
        save_allow = true;
        autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(autoSave) userInfo:nil repeats:NO];
        
    }
    else if(doseVal< old_doseVal && doseVal >0)
    {
        currentDose = doseVal;
        old_doseVal = doseVal;
        coinTempValue = coinValue;
        feel_state = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showConfirmFeeling]; //[self showFeelings];
            [self clearFeelSympCheck];
            [self vibratePhone];
        });
        save_allow = true;
        ///
        autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(autoSave) userInfo:nil repeats:NO];
    }
    if(save_allow == false && refresh_allow == true)
    {
        sleep(0.3);
        [self loadGraph];
    }
    
    int alarm = currentDose + [self totalDosesinToday];
    int limit = [self getDosageLimitValue];
    if(alarm > limit+100)
    {
        [self showToastLong:@"You have exceeded your daily smoking."];
        [self childSafetyOnButtonClick:nil];
    }
}
-(void) bleWriteSuccess:(NSNotification*)noti
{
    NSLog(@"Write Success");
}

-(void) bleDisconnected:(NSNotification*)noti
{
    NSLog(@"Disconnected");
    [self showToastLong:@"Device Disconnected"];
    [self saveConnectStatus:NO];
    if(childSafetyValue > 1)
        childSafetyValue -=2;
    [self changeChildSafetyButtonImage:childSafetyValue];
}


-(void)bleReadBatteryValue:(NSNotification*)noti
{
    NSData *receivedData = (NSData*)(noti.object);
    NSLog(@"Read Battery Value - %@",receivedData);
    if([receivedData length]<1)
        return;
    
    Byte *message = (Byte *)[receivedData bytes];
    int val = message[0];
    [_lblBatteryLevel setText:[NSString stringWithFormat:@"%d %%",val]];
    batteryLevel = val;
    [self setBattery:val];
    if(readBatteryFlag == true)
    {
        [self readChildSaftetyStatus];
        readBatteryFlag = false;
    }
}

-(void)setBattery:(int)val
{
    if(val == 100)
    {
        [_imgBattery setImage:[UIImage imageNamed:@"b100"]];
    }
    else if(val>65)
    {
        [_imgBattery setImage:[UIImage imageNamed:@"b75"]];
    }
    else if(val>35)
    {
        [_imgBattery setImage:[UIImage imageNamed:@"b50"]];
    }
    else if(val>15)
    {
        [_imgBattery setImage:[UIImage imageNamed:@"b25"]];
    }
    else if(val>0)
    {
        [_imgBattery setImage:[UIImage imageNamed:@"b0"]];
    }
}
-(void) autoSave
{
    if(save_allow == true)
    {
        int NO_FEEL = 12;
        [self hideFeelings];
        [self addVape:@"12"];
        [self loadGraph];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        NSMutableArray *resArray = [[NSMutableArray alloc] init];
        [self feelArray:tempArray];
        [self updateArray:tempArray NewVal:NO_FEEL NewArray:resArray];
        [self changeFeelTable:resArray];
        [self loadFeeling:resArray];
        save_allow = false;
        resArray = nil;
        tempArray = nil;
    }
}




#pragma mark - Bluetooth Send

-(void) sendBLEData:(NSData*) data
{
    [mBLEComm sendCommand:data ServiceUUID:@"AAA0" CharacteristicUUID:@"AAA1"];
}
#pragma mark - Bluetooth Read

-(void) readBatteryValue
{
    readBatteryFlag = true;
    [mBLEComm readCharacteristicWithServiceUUID:@"180F" CharacteristicUUID:@"2A19"];
}

-(void) readChildSaftetyStatus
{
    NSLog(@"Call readChildSafety");
    Byte data[2];
    data[0] = 0xA0;
    data[1] = 0;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:2];
    [self sendBLEData:cmdData];
}


#pragma mark - Progress methods
- (void)showProgress
{
    mProgressLabel.text = @"";
    [self.view addSubview:maskView];
    [self.view addSubview:mProgressLabel];
    [self.view addSubview:HUD];
    [HUD show:YES];
}

- (void)hideProgress {
    [HUD hide:YES];
}

-(void) cancelProgress
{
    [self hideProgress];
}

#pragma mark - Save Device Name

-(void)saveConnectStatus:(Boolean)status
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString* saveStatus = status==true?@"connect":@"disconnect";
    if (standardUserDefaults) {
        [standardUserDefaults setObject:saveStatus forKey:@"connect_status"];
        [standardUserDefaults synchronize];
    }
}

-(NSString*)getConnectStatus
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"abc";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:@"connect_status"];
    }
    return result;
}

-(NSString*)getSavedDeviceName
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"abc";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:@"device_name"];
    }
    return result;
}

-(NSString*)getSavedEmail
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"guest";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:KEY_EMAIL];
        if(result == nil)
            result = @"guest";
    }
    return result;
}

-(NSString*)getSavedDeviceAddress
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"abc";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:@"device_address"];
    }
    return result;
}

-(void)saveCatridgeName:(NSString*)myCat
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:myCat forKey:@"catridge_name"];
        [standardUserDefaults synchronize];
    }
}

-(NSString*)getSavedCatridgeName
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"abc";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:@"catridge_name"];
    }
    if(result == nil)
        result = defaultCatridgeName;
    return result;
}
-(int)getDosageLimitValue
{
    int res = 10;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self dayDosageArray:array];
    if(sel_dayofweek<[array count])
    {
        res = [[array objectAtIndex:sel_dayofweek] intValue];
        array = nil;
    }
    NSLog(@"Dosage Limit Value : %d\n", res);
    return res;
}

#pragma mark - show time
-(void) showDates
{
    //NSString *weekString[] =  {@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"};
    //NSString *monthString[] = {@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"};
    
    
    NSDate *now = [NSDate date];
    // Specify which units we would like to use
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit|NSWeekdayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:units fromDate:now];
    [components setTimeZone:[NSTimeZone localTimeZone]];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components weekday];
    NSInteger date = [components day];
    
    sel_day = (int) date;
    sel_month = (int) month;
    sel_year = (int)year;
    sel_dayofweek = (int)day - 1;
    
    sel_last_day = (int) date;
    sel_last_month = (int) month;
    sel_last_year = (int)year;
    sel_last_dayofweek = (int)day - 1;
    
    NSString *res1 = [NSString stringWithFormat:@"Date : %02d/%02d/%04d - ", sel_month,sel_day,sel_year];
    NSString *res2 = [NSString stringWithFormat:@"%02d/%02d/%04d", sel_last_month, sel_last_day, sel_last_year];
   
    [_btnDateSel setTitle:res1 forState:UIControlStateNormal];
    [_btnDateLastSel setTitle:res2 forState:UIControlStateNormal];
    
    [self showLastSession];
}


-(void) showLastSession
{
    NSString *weekString[] =  {@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"};
    NSString *monthString[] = {@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"};
    
    
    NSDate *now = [NSDate date];
    // Specify which units we would like to use
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:units fromDate:now];
    [components setTimeZone:[NSTimeZone localTimeZone]];
    //NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components weekday];
    NSInteger date = [components day];
    NSInteger hour = [components hour];
    NSInteger min = [components minute];
    
    NSString *strPM = (hour>12)?@"PM":@"AM";
    if(hour>12)
        hour -= 12;
    NSString *res5 = [NSString stringWithFormat:@"%@, %@ %d| %02d:%02d %@", weekString[day - 1], monthString[month-1], (int)date, (int)(hour), (int)min, strPM];
    
    [_lblHomeTime setText:res5];
}

#pragma mark - date function
-(NSString*) currentDateTime
{
    NSDate *now = [NSDate date];
    // Specify which units we would like to use
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:units fromDate:now];
    [components setTimeZone:[NSTimeZone localTimeZone]];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger date = [components day];
    NSInteger hour = [components hour];
    NSInteger min = [components minute];
    NSInteger sec = [components second];
    NSString *convertedDateString = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", (int)year, (int)month, (int)date,(int)hour,(int)min,(int)sec];
    return convertedDateString;
}


#pragma mark - Symptoms Drawing
-(void) clearFeelSympCheck
{
    [checkFeelingArray removeAllObjects];
    for(int i=0; i<FEELS_COUNT; i++)
        [checkFeelingArray addObject:[NSNumber numberWithBool:false]];
    
    [checkSymptomArray removeAllObjects];
    for(int i=0; i<SYMPTOMS_COUNT; i++)
        [checkSymptomArray addObject:[NSNumber numberWithBool:false]];
    
    shareState = NO;
    
    NSString *btnSympImgName[9] = {@"pain_nor", @"anxiety_nor", @"stress_nor", @"cancer_nor", @"epilepsy_nor", @"arthritis_nor", @"bipolar_nor", @"depression_nor", @"insomnia_nor"};
    
    for(int i = 0; i<SYMPTOMS_COUNT; i++)
    {
        UIButton *btn = (UIButton*)[_mTrackerSymptomsView viewWithTag:i + 100];
        [btn setImage:[UIImage imageNamed:btnSympImgName[i]] forState:UIControlStateNormal];
    }
    
    NSString *btnFeelImgName[] = {@"happy_nor", @"sad_nor", @"relaxed_nor", @"agitated_nor", @"energetic_nor", @"inactive_nor", @"social_nor", @"antisocial_nor", @"focused_nor", @"scattered_nor", @"motivated_nor", @"discouraged_nor", @"noeffect_nor"};
    for(int i = 0; i<FEELS_COUNT; i++)
    {
        UIButton *btn = (UIButton*)[_mTrackerFeelingView viewWithTag:i + 100];
        [btn setImage:[UIImage imageNamed:btnFeelImgName[i]] forState:UIControlStateNormal];
    }
    
}

- (void) clearSymptoms
{
    for(int i=0; i<SYMPTOMS_COUNT; i++)
    {
        UILabel *lb = [_mSymptomsRelievedView viewWithTag:i+21];
        UIImageView *imgV = [_mSymptomsRelievedView viewWithTag:i + 1];
        [lb setHidden:YES];
        [imgV setHidden:YES];
        [lb setText:@""];
        [imgV setImage:nil];
        //[imgV setImage:[UIImage imageNamed:@""]];
    }
}

- (void) loadSymptoms:(NSMutableArray*) array
{
    int count = (int)[array count];
    [self clearSymptoms];
    for(int i=0; i<count; i++)
    {
        int vals =[[array objectAtIndex:i] intValue];
        int val = vals / 1000 % 100;
        int count = vals % 1000;
        UILabel *lb = [_mSymptomsRelievedView viewWithTag:i+21];
        UIImageView *imgV = [_mSymptomsRelievedView viewWithTag:i + 1];
        [lb setHidden:NO];
        [imgV setHidden:NO];
        NSString *res = [NSString stringWithFormat:@"%@(%d)",symptomsLblName[val],count];
        [lb setText:res];
        if(vals >=100000)
            [imgV setImage:[UIImage imageNamed:symptomsSelImgName[val]]];
        else
            [imgV setImage:[UIImage imageNamed:symptomsImgName[val]]];
    }
    
    //[self refreshFrame:count];
}

#pragma mark - Feeling Drawing

- (void) clearFeeling
{
    for(int i=0; i<FEELS_COUNT; i++)
    {
        UILabel *lb = [_mAssociatedFeelingsView viewWithTag:i+21];
        UIImageView *imgV = [_mAssociatedFeelingsView viewWithTag:i + 1];
        [lb setHidden:YES];
        [imgV setHidden:YES];
        [lb setText:@""];
        //[imgV setImage:[UIImage imageNamed:@""]];
        [imgV setImage:nil];
    }
}

- (void) loadFeeling:(NSMutableArray*) array
{
    int count = (int)[array count];
    [self clearFeeling];
    for(int i=0; i<count; i++)
    {
        int vals =[[array objectAtIndex:i] intValue];
        int val = vals / 1000 % 100;
        int count = vals % 1000;
        UILabel *lb = [_mAssociatedFeelingsView viewWithTag:i+21];
        UIImageView *imgV = [_mAssociatedFeelingsView viewWithTag:i + 1];
        [lb setHidden:NO];
        [imgV setHidden:NO];
        NSString *res = [NSString stringWithFormat:@"%@(%d)",feelingLblName[val],count];
        [lb setText:res];
        
        if(vals >=100000)
            [imgV setImage:[UIImage imageNamed:feelingSelImgName[val]]];
        else
            [imgV setImage:[UIImage imageNamed:feelingImgName[val]]];
    }
    
    //[self refreshFrame:count];
}


#pragma mark - Load Catridge
-(void) catArray:(NSMutableArray*) array
{
    sqlite3_stmt    *statement;
    NSString *val = @"";
    NSString *sql = [NSString stringWithFormat: @"SELECT cats FROM catInf WHERE id = 1",nil];
    const char *query_stmt5 = [sql UTF8String];
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            const char  *temp = (const char *)sqlite3_column_text(statement, 0);
            if(temp == nil)
                return;
            val = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
            if([val length]>0)
            {
                NSArray *tarray = [val componentsSeparatedByString:@"!"];
                for(int i=0; i<[tarray count]; i++)
                {
                    if([[tarray objectAtIndex:i] isEqualToString:@""])
                        continue;
                    NSString *vals = (NSString*)[tarray objectAtIndex:i];
                    [array addObject:vals];
                }
                tarray = nil;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
}

-(void) clearCatridge
{
    for(int i = 0; i<3; i++)
    {
        UILabel *lb = [_mWorkStationChildView viewWithTag:i+501];
        UIView *imgV = [_mWorkStationChildView viewWithTag:i + 401];
        [lb setHidden:YES];
        [imgV setHidden:YES];
    }
}
- (void) loadCatrides
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self catArray:array];
    
    int count = (int)[array count];
    [self clearCatridge];
    
    for(int i=0; i<count; i++)
    {
        UILabel *lb = [_mWorkStationChildView viewWithTag:i+501];
        UIView *imgV = [_mWorkStationChildView viewWithTag:i + 401];
        [lb setHidden:NO];
        [imgV setHidden:NO];
        
        NSString *str = (NSString*)[array objectAtIndex:i];
        [lb setText:str];
    }
    array = nil;
}

-(void) loadCatridgeFromDatabase
{
    
    [catridgsArray removeAllObjects];
    [catridgsColorArray removeAllObjects];
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    sqlite3_stmt    *statement;
   
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT SampleID, SampleName, TXT1, VAL1, TXT2, VAL2, TXT3, VAL3, TXT4, VAL4, TXT5, VAL5, TXT6, VAL6, colorID FROM catridgeInfo",nil];
        
        const char *query_stmt = [querySQL UTF8String];
        
        //  NSLog(@"Databasae opened = %@", userN);
        
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            int rows = sqlite3_column_int(statement, 0);
            NSLog(@"rows : %d", rows);
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *sampleName = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                int color = sqlite3_column_int(statement, 14);
                NSLog(@"cat name : %@", sampleName);
                NSLog(@"cat colr : %d", color);
                [catridgsArray addObject:sampleName];
                [catridgsColorArray addObject:[NSNumber numberWithInt:color]];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    
    NSString *catName = [self getSavedCatridgeName];
    for(int i=0; i<[catridgsArray count]; i++)
    {
        NSString *temp = (NSString*) [catridgsArray objectAtIndex:i];
        if([temp isEqualToString:catName])
        {
            selectCatIndex = i;
            break;
        }
    }
    [self.catTableView reloadData];
}


-(void) refreshFrame:(int) count
{
    int height = 100;
    if(count > 5)
    {
        height = 100 + (int)((count - 4) / 4) * 70;
    }
    CGRect frame = _mAssociatedFeelingsView.frame;
    frame.size.height = height;
    [_mAssociatedFeelingsView setFrame:frame];
    
    CGRect frame2 = _mSymptomsRelievedView.frame;
    int org = frame2.origin.y;
    frame2.origin.y = org - (320 - height);
    [_mSymptomsRelievedView setFrame:frame2];
    
    int height_all = 1500;//frame2.origin.y + frame2.size.height;
    
    CGRect frame3 = self.view.frame;
    frame3.size.height = height_all;
    [self.view setFrame:frame3];
    
}


#pragma mark - Data base
- (void) initDatabase
{
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    sqlite3_stmt    *statement;
    
    if(sqlite3_open_v2([paths cStringUsingEncoding:NSUTF8StringEncoding], &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK)
    {
        char *querySQL0 = "CREATE TABLE IF NOT EXISTS commInf(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, dt TIMESTAMP,dose INTEGER,feel TEXT, catridge TEXT, blename TEXT);";
        
        char *querySQL1 = "CREATE TABLE IF NOT EXISTS vapeInf(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, dt TIMESTAMP,dose INTEGER,feel TEXT, catridge TEXT, blename TEXT);";
        
        char *querySQL2 = "CREATE TABLE IF NOT EXISTS feelInf(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, dt TIMESTAMP,feels TEXT, catridge TEXT,blenames TEXT);";
        char *querySQL3 = "CREATE TABLE IF NOT EXISTS sympInf(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, dt TIMESTAMP,symps TEXT, catridge TEXT,blenames TEXT);";
        char *querySQL4 = "CREATE TABLE IF NOT EXISTS BLEInf (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, dt TIMESTAMP,blenames TEXT);";
        char *querySQL5 ="CREATE TABLE IF NOT EXISTS CatInf (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, dt TIMESTAMP,Cats TEXT);";
        char *querySQL6 ="CREATE TABLE IF NOT EXISTS CatridgeInfo (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, SampleID TEXT NOT NULL,  SampleName TEXT NOT NULL, TXT1 TEXT NOT NULL, VAL1 INTEGER, TXT2 TEXT NOT NULL, VAL2 INTEGER, TXT3 TEXT NOT NULL, VAL3 INTEGER, TXT4 TEXT NOT NULL, VAL4 INTEGER, TXT5 TEXT NOT NULL, VAL5 INTEGER, TXT6 TEXT NOT NULL, VAL6 INTEGER, colorID INTEGER, days TEXT NOT NULL,  CONSTRAINT UC_CatridgeInfo UNIQUE (SampleName));";
        
        char *errMsg;
        if(sqlite3_exec(database, querySQL0, NULL, NULL, &errMsg) != SQLITE_OK)
            NSLog( @"Save Error: %s, msg=%s", sqlite3_errmsg(database), errMsg );
        
        if(sqlite3_exec(database, querySQL1, NULL, NULL, &errMsg) != SQLITE_OK)
            NSLog( @"Save Error: %s, msg=%s", sqlite3_errmsg(database), errMsg );
        
        if(sqlite3_exec(database, querySQL2, NULL, NULL, &errMsg) != SQLITE_OK)
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
        
        if(sqlite3_exec(database, querySQL3, NULL, NULL, &errMsg) != SQLITE_OK)
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
        
        if(sqlite3_exec(database, querySQL4, NULL, NULL, &errMsg) != SQLITE_OK)
            NSLog( @"Save Error: %s, msg=%s", sqlite3_errmsg(database), errMsg );
        
        if(sqlite3_exec(database, querySQL5, NULL, NULL, &errMsg) != SQLITE_OK)
            NSLog( @"Save Error: %s, msg=%s", sqlite3_errmsg(database), errMsg );
        
        if(sqlite3_exec(database, querySQL6, NULL, NULL, &errMsg) != SQLITE_OK)
            NSLog( @"Save Error: %s, msg=%s", sqlite3_errmsg(database), errMsg );
        
        sqlite3_close(database);
    }
    
    
    
    if(sqlite3_open_v2([paths cStringUsingEncoding:NSUTF8StringEncoding], &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        //NSString *sql1 = [NSString stringWithFormat: @"INSERT INTO CatridgeInfo (SampleID, SampleName, TXT1, VAL1, TXT2, VAL2, TXT3, VAL3, TXT4, VAL4, TXT5, VAL5, TXT6, VAL6, colorID,days) VALUES('vape1','Blackberry','a',77,'a',3,'a',2,'a',18,'a',18,'a',18,11,'10|10|10|10|10|10|10');",nil];
        
        NSString *sql1 = [NSString stringWithFormat: @"INSERT INTO CatridgeInfo (SampleID, SampleName, TXT1, VAL1, TXT2, VAL2, TXT3, VAL3, TXT4, VAL4, TXT5, VAL5, TXT6, VAL6, colorID,days) VALUES('cart1','KURE','a',77,'a',3,'a',2,'a',18,'a',18,'a',18,11,'10|10|10|10|10|10|10');",nil];
        NSString *sql2 = [NSString stringWithFormat: @"INSERT INTO CatridgeInfo (SampleID, SampleName, TXT1, VAL1, TXT2, VAL2, TXT3, VAL3, TXT4, VAL4, TXT5, VAL5, TXT6, VAL6, colorID,days) VALUES('cart2','NIGHT CAP','a',77,'a',3,'a',2,'a',18,'a',18,'a',18,10,'10|10|10|10|10|10|10');",nil];
        NSString *sql3 = [NSString stringWithFormat: @"INSERT INTO CatridgeInfo (SampleID, SampleName, TXT1, VAL1, TXT2, VAL2, TXT3, VAL3, TXT4, VAL4, TXT5, VAL5, TXT6, VAL6, colorID,days) VALUES('cart3','WAKE','a',77,'a',3,'a',2,'a',18,'a',18,'a',18,9,'10|10|10|10|10|10|10');",nil];
        NSString *sql4 = [NSString stringWithFormat: @"INSERT INTO CatridgeInfo (SampleID, SampleName, TXT1, VAL1, TXT2, VAL2, TXT3, VAL3, TXT4, VAL4, TXT5, VAL5, TXT6, VAL6, colorID,days) VALUES('cart4','CRUISE CONTROL','a',77,'a',3,'a',2,'a',18,'a',18,'a',18,8,'10|10|10|10|10|10|10');",nil];
        NSString *sql5 = [NSString stringWithFormat: @"INSERT INTO CatridgeInfo (SampleID, SampleName, TXT1, VAL1, TXT2, VAL2, TXT3, VAL3, TXT4, VAL4, TXT5, VAL5, TXT6, VAL6, colorID,days) VALUES('cart5','BLAZED','a',77,'a',3,'a',2,'a',18,'a',18,'a',18,7,'10|10|10|10|10|10|10');",nil];
        NSString *sql6 = [NSString stringWithFormat: @"INSERT INTO CatridgeInfo (SampleID, SampleName, TXT1, VAL1, TXT2, VAL2, TXT3, VAL3, TXT4, VAL4, TXT5, VAL5, TXT6, VAL6, colorID,days) VALUES('cart6','SIGNATURE SERIES','a',77,'a',3,'a',2,'a',18,'a',18,'a',18,6,'10|10|10|10|10|10|10');",nil];
        
        const char *query_stmt51 = [sql1 UTF8String];
        const char *query_stmt52 = [sql2 UTF8String];
        const char *query_stmt53 = [sql3 UTF8String];
        const char *query_stmt54 = [sql4 UTF8String];
        const char *query_stmt55 = [sql5 UTF8String];
        const char *query_stmt56 = [sql6 UTF8String];
        
        sqlite3_busy_timeout(database, 500);
        
       
        if(sqlite3_prepare_v2(database, query_stmt51, -1, &statement, NULL) != SQLITE_OK)
        {
            NSLog(@"INSERT CatridgeInfo: %s", sqlite3_errmsg(database));
        }
        if(sqlite3_step(statement) != SQLITE_DONE ) {
            NSLog( @"INSERT CatridgeInfo: %s", sqlite3_errmsg(database) );
        }
        sqlite3_busy_timeout(database, 100);
        if(sqlite3_prepare_v2(database, query_stmt52, -1, &statement, NULL) != SQLITE_OK)
        {
            NSLog(@"INSERT CatridgeInfo: %s", sqlite3_errmsg(database));
        }
        if(sqlite3_step(statement) != SQLITE_DONE ) {
            NSLog( @"INSERT CatridgeInfo: %s", sqlite3_errmsg(database) );
        }
        sqlite3_busy_timeout(database, 100);
        if(sqlite3_prepare_v2(database, query_stmt53, -1, &statement, NULL) != SQLITE_OK)
        {
            NSLog(@"INSERT CatridgeInfo: %s", sqlite3_errmsg(database));
        }
        if(sqlite3_step(statement) != SQLITE_DONE ) {
            NSLog( @"INSERT CatridgeInfo: %s", sqlite3_errmsg(database) );
        }
        sqlite3_busy_timeout(database, 100);
        if(sqlite3_prepare_v2(database, query_stmt54, -1, &statement, NULL) != SQLITE_OK)
        {
            NSLog(@"INSERT CatridgeInfo: %s", sqlite3_errmsg(database));
        }
        if(sqlite3_step(statement) != SQLITE_DONE ) {
            NSLog( @"INSERT CatridgeInfo: %s", sqlite3_errmsg(database) );
        }
        sqlite3_busy_timeout(database, 100);
        if(sqlite3_prepare_v2(database, query_stmt55, -1, &statement, NULL) != SQLITE_OK)
        {
            NSLog(@"INSERT CatridgeInfo: %s", sqlite3_errmsg(database));
        }
        if(sqlite3_step(statement) != SQLITE_DONE ) {
            NSLog( @"INSERT CatridgeInfo: %s", sqlite3_errmsg(database) );
        }
        sqlite3_busy_timeout(database, 100);
        if(sqlite3_prepare_v2(database, query_stmt56, -1, &statement, NULL) != SQLITE_OK)
        {
            NSLog(@"INSERT CatridgeInfo: %s", sqlite3_errmsg(database));
        }
        if(sqlite3_step(statement) != SQLITE_DONE ) {
            NSLog( @"INSERT CatridgeInfo: %s", sqlite3_errmsg(database) );
        }
        
       
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        [self saveCartDefaultFile];
    }
    
    
    NSString *sql = [NSString stringWithFormat: @"SELECT count(cats) FROM catInf",nil];
    const char *query_stmt5 = [sql UTF8String];
    const char *dbpath =  [paths UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            int res  =(int) sqlite3_column_int(statement, 0);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            if(res == 0)
            {
                if(sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
                {
                    NSString *currentTime4 = [self currentDateTime];
                    NSString *sql1 = [NSString stringWithFormat: @"INSERT INTO CatInf (dt, cats) VALUES('%@','%@!');",currentTime4,defaultCatridgeName];
                    const char *query_stmt51 = [sql1 UTF8String];
                    sqlite3_busy_timeout(database, 500);
                    if(sqlite3_prepare_v2(database, query_stmt51, -1, &statement, NULL) != SQLITE_OK)
                    {
                        NSLog(@"Insert CatInfo Error: %s", sqlite3_errmsg(database));
                    }
                    
                    if(sqlite3_step(statement) != SQLITE_DONE ) {
                        NSLog( @"Insert CatInfo Error: %s", sqlite3_errmsg(database) );
                    }
                    sqlite3_finalize(statement);
                    sqlite3_close(database);
                }
            }
        }
        else
        {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
    }
}

- (NSString *)getCartImageName :(NSString*) sampleName
{
    NSArray *paths          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [paths objectAtIndex:0];
    NSString *imgfileName   = [NSString stringWithFormat:@"img_%@_thumb.jpg", sampleName];
    directoryPath = [directoryPath stringByAppendingPathComponent:@"CatridgeImage"];
    NSString *dstPath = [directoryPath stringByAppendingPathComponent:imgfileName];
    return dstPath;
}

- (void) saveCartDefaultFile
{
    NSString *cartName[]= {@"KURE", @"NIGHT CAP", @"WAKE", @"CRUISE CONTROL", @"BLAZED", @"SIGNATURE SERIES"};
    NSString *cartImageName[]= {@"cat_0",@"cat_1",@"cat_2",@"cat_3",@"cat_4",@"cat_5"};
    
    for(int i=0; i<6; i++)
    {
        NSString *path =[self getCartImageName:cartName[i]];
        UIImage *image = [UIImage imageNamed:cartImageName[i]];
        [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    }
}
- (NSString *) getWritableDBPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:myDB];
    
}

-(void)createEditableCopyOfDatabaseIfNeeded
{
    // Testing for existence
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:myDB];
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
        return;
    
    // The writable database does not exist, so copy the default to
    // the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath]
                               stringByAppendingPathComponent:myDB];
    success = [fileManager copyItemAtPath:defaultDBPath
                                   toPath:writableDBPath
                                    error:&error];
    if(!success)
    {
        NSAssert1(0,@"Failed to create writable database file with Message : '%@'.",
                  [error localizedDescription]);
    }
}

- (int) totalDoses
{
    int result = 0;
    NSString *cat = [self getSavedCatridgeName];
    sqlite3_stmt    *statement;
    
    NSString *sql = [NSString stringWithFormat: @"SELECT count(dose) FROM vapeInf WHERE catridge='%@'",cat];
    const char *query_stmt5 = [sql UTF8String];
    
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    
    if (sqlite3_open([paths UTF8String], &database) == SQLITE_OK)
    {
        
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            result = (int)sqlite3_column_int(statement, 0);
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
        else
        {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            sqlite3_close(database);
        }
    }
    return result;
}


- (int) totalDosesinToday
{
    int result = 0;
    NSString *cat = [self getSavedCatridgeName];
    sqlite3_stmt    *statement;
    
    NSString *convertedDateString = [NSString stringWithFormat:@"%04d-%02d-%02d", sel_year, sel_month, sel_day];
    
    
    NSString *sql = [NSString stringWithFormat: @"SELECT count(dose) FROM vapeInf WHERE catridge='%@' AND (dt > '%@ 00:00:00' AND dt < '%@ 23:59:59')",cat, convertedDateString, convertedDateString];
    const char *query_stmt5 = [sql UTF8String];
    
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    
    if (sqlite3_open([paths UTF8String], &database) == SQLITE_OK)
    {
        
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            result = (int)sqlite3_column_int(statement, 0);
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
        else
        {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            sqlite3_close(database);
        }
    }
    return result;
}

/*- (int) totalDosesinWeek
 {
 int result = 0;
 NSString *cat = [self getSavedCatridgeName];
 sqlite3_stmt    *statement;
 
 
 NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
 [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
 [dateFormat setDateFormat:@"yyy-MM-dd'T'HH:mm:ssZ"];
 NSDate *eventDate = [dateFormat dateFromString:[NSString stringWithFormat:@"%4d-%2d-%2dT00:00:00Z", sel_year, sel_month, sel_day]];
 
 NSDate *todayDate = eventDate;//[NSDate date]; //Get todays date
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date.
 [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
 [dateFormatter setDateFormat:@"yyyy-MM-dd"]; //Here we can set the format which we need
 NSString *convertedDateString = [dateFormatter stringFromDate:todayDate];// Here convert date in NSString
 
 
 NSTimeInterval seconds = 60 * 60 * 24 * 7;
 NSDate *oldDate = [todayDate dateByAddingTimeInterval:-seconds];
 NSString *convertedOldDateString = [dateFormatter stringFromDate:oldDate];// Here convert date in NSString
 
 NSString *sql = [NSString stringWithFormat: @"SELECT count(dose) FROM vapeInf WHERE catridge='%@' AND (dt > '%@ 00:00:00' AND dt < '%@ 23:59:59')",cat, convertedOldDateString, convertedDateString];
 const char *query_stmt5 = [sql UTF8String];
 
 [self createEditableCopyOfDatabaseIfNeeded];
 NSString * paths=[self getWritableDBPath];
 
 if (sqlite3_open([paths UTF8String], &database) == SQLITE_OK)
 {
 if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
 {
 sqlite3_step(statement);
 result = (int) sqlite3_column_int(statement, 0);
 }
 else
 {
 NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
 }
 sqlite3_finalize(statement);
 sqlite3_close(database);
 }
 return result;
 }*/

- (int) totalDosesinDay:(int) year month:(int)month day:(int) day CatridgeName:(NSString*) catName
{
    int result = 0;
    NSString *cat = catName;
    sqlite3_stmt    *statement;
    
    NSString *convertedDateString = [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day];
    NSLog(@"\nTotal doses in hour Time - %@\n", convertedDateString);
    
    NSString *sql = [NSString stringWithFormat: @"SELECT count(dose) FROM vapeInf WHERE catridge='%@' AND (dt > '%@ 00:00:00' AND dt < '%@ 23:59:59')",cat, convertedDateString, convertedDateString];
    const char *query_stmt5 = [sql UTF8String];
    
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    
    if (sqlite3_open([paths UTF8String], &database) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            result = (int) sqlite3_column_int(statement, 0);
        }
        else
        {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return result;
}

- (int) totalCommDosesinDay:(int) year month:(int)month day:(int) day CatridgeName:(NSString*) catName
{
    int result = 0;
    NSString *cat = catName;
    sqlite3_stmt    *statement;
    
    NSString *convertedDateString = [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day];
    NSLog(@"\nTotal doses in hour Time - %@\n", convertedDateString);
    
    NSString *sql = [NSString stringWithFormat: @"SELECT count(dose) FROM commInf WHERE catridge='%@' AND (dt > '%@ 00:00:00' AND dt < '%@ 23:59:59')",cat, convertedDateString, convertedDateString];
    const char *query_stmt5 = [sql UTF8String];
    
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    
    if (sqlite3_open([paths UTF8String], &database) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            result = (int) sqlite3_column_int(statement, 0);
        }
        else
        {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return result;
}


- (int) totalDosesinHour:(int) year month:(int)month day:(int) day hour: (int) hour CatridgeName:(NSString*) catName
{
    int result = 0;
    NSString *cat = catName;
    sqlite3_stmt    *statement;
    
    NSString *convertedDateString = [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day];
    NSLog(@"\nTotal doses in hour Time - %@\n", convertedDateString);
    
    NSString *sql = [NSString stringWithFormat: @"SELECT count(dose) FROM vapeInf WHERE catridge='%@' AND (dt > '%@ %02d:00:00' AND dt < '%@ %02d:59:59')",cat, convertedDateString, hour, convertedDateString, hour];
    const char *query_stmt5 = [sql UTF8String];
    
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    
    if (sqlite3_open([paths UTF8String], &database) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            result = (int) sqlite3_column_int(statement, 0);
        }
        else
        {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return result;
}

- (int) totalCommDosesinHour:(int) year month:(int)month day:(int) day hour: (int) hour CatridgeName:(NSString*) catName
{
    int result = 0;
    NSString *cat = catName;
    sqlite3_stmt    *statement;
    
    NSString *convertedDateString = [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day];
    
    NSLog(@"\nTotal commDoes in hour Time - %@\n", convertedDateString);
    
    NSString *sql = [NSString stringWithFormat: @"SELECT count(dose) FROM commInf WHERE catridge='%@' AND (dt > '%@ %02d:00:00' AND dt < '%@ %02d:59:59')",cat, convertedDateString, hour, convertedDateString, hour];
    const char *query_stmt5 = [sql UTF8String];
    
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    
    if (sqlite3_open([paths UTF8String], &database) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            result = (int) sqlite3_column_int(statement, 0);
        }
        else
        {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return result;
}

-(void) dayDosageArray:(NSMutableArray*) array
{
    sqlite3_stmt    *statement;
    NSString *val = @"";
    [array removeAllObjects];
    NSString *catName = [self getSavedCatridgeName];
    
    if(catName == nil || [catName isEqualToString:@"[ ]"])
        return;
    
    NSString *sql = [NSString stringWithFormat: @"SELECT days FROM CatridgeInfo WHERE SampleName='%@'",catName];
    const char *query_stmt5 = [sql UTF8String];
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            const char  *temp = (const char *)sqlite3_column_text(statement, 0);
            if(temp == nil)
                return;
            val = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
            if([val length]>0)
            {
                NSArray *tarray = [val componentsSeparatedByString:@"|"];
                for(int i=0; i<[tarray count]; i++)
                {
                    if([[tarray objectAtIndex:i] isEqualToString:@""])
                        continue;
                    int vals = [[tarray objectAtIndex:i] intValue];
                    [array addObject:[NSNumber numberWithInt:vals]];
                }
                tarray = nil;
            }
            
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}

-(void) updateArray:(NSMutableArray*) array NewVal :(int)new_val NewArray:(NSMutableArray*) new_array
{
    [new_array removeAllObjects];
    
    int temp_cnt = 1;
    for(int i=0; i<[array count]; i++)
    {
        int cur_val = [[array objectAtIndex:i] intValue] ;
        if(cur_val / 1000 % 100 == new_val)
        {
            temp_cnt = cur_val % 1000;
            temp_cnt++;
            break;
        }
    }
    
    [new_array addObject:[NSNumber numberWithInt:new_val * 1000 + temp_cnt + 100000]];
    
    for(int i=0; i<[array count]; i++)
    {
        int cur_val = [[array objectAtIndex:i] intValue] ;
        if(cur_val / 1000 % 100!= new_val)
            [new_array addObject:[NSNumber numberWithInt:cur_val]];
    }
}


-(void) feelArray:(NSMutableArray*) array
{
    sqlite3_stmt    *statement;
    NSString *val = @"";
    [array removeAllObjects];
    NSString *bleName = [self getSavedDeviceName];
    NSString *catName = [self getSavedCatridgeName];
    if(bleName == nil || [bleName isEqualToString:@"[ ]"])
        return;
    
    NSString *sql = [NSString stringWithFormat: @"SELECT feels FROM feelInf WHERE blenames='%@' and catridge='%@'",bleName, catName];
    const char *query_stmt5 = [sql UTF8String];
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            const char  *temp = (const char *)sqlite3_column_text(statement, 0);
            if(temp == nil)
                return;
            val = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
            if([val length]>0)
            {
                NSArray *tarray = [val componentsSeparatedByString:@"A"];
                for(int i=0; i<[tarray count]; i++)
                {
                    if([[tarray objectAtIndex:i] isEqualToString:@""])
                        continue;
                    int vals = [[tarray objectAtIndex:i] intValue];
                    [array addObject:[NSNumber numberWithInt:vals]];
                }
                tarray = nil;
            }
            
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}
-(void) changeFeelTable:(NSMutableArray*) array
{
    sqlite3_stmt    *statement;
    NSString *feels = @"";
    NSString *bleName = [self getSavedDeviceName];
    NSString *cat = [self getSavedCatridgeName];
    for(int i =0; i<[array count]; i++)
    {
        int temp = [[array objectAtIndex:i] intValue];
        feels = [NSString stringWithFormat:@"%@%dA",feels,temp];
    }
    
    NSString *sql = [NSString stringWithFormat: @"SELECT count(feels) FROM feelInf WHERE blenames='%@' and catridge='%@'",bleName, cat];
    const char *query_stmt5 = [sql UTF8String];
    
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            int res  =(int) sqlite3_column_int(statement, 0);
            sqlite3_finalize(statement);
            if(res == 0)
            {
                NSString *sql1 = [NSString stringWithFormat: @"INSERT INTO feelInf (dt, feels, catridge, blenames) VALUES('%@','%@','%@','%@');",currentTime, feels, cat, bleName];
                const char *query_stmt51 = [sql1 UTF8String];
                sqlite3_busy_timeout(database, 500);
                if(sqlite3_prepare_v2(database, query_stmt51, -1, &statement, NULL) != SQLITE_OK)
                {
                    NSLog(@"Insert feelInfo Error: %s", sqlite3_errmsg(database));
                }
                
                if(sqlite3_step(statement) != SQLITE_DONE ) {
                    NSLog( @"Insert feelInfo  Error: %s", sqlite3_errmsg(database) );
                }
                sqlite3_finalize(statement);
            }
            else
            {
                NSString *sql2 = [NSString stringWithFormat: @"UPDATE feelInf SET feels = '%@' WHERE blenames = '%@' and catridge='%@'", feels, bleName,cat];
                const char *query_stmt52 = [sql2 UTF8String];
                sqlite3_busy_timeout(database, 500);
                if(sqlite3_prepare_v2(database, query_stmt52, -1, &statement, NULL) != SQLITE_OK)
                {
                    NSLog(@"Update feelInfo Error: %s", sqlite3_errmsg(database));
                }
                if(sqlite3_step(statement) != SQLITE_DONE ) {
                    NSLog( @"Update feelInfo Error: %s", sqlite3_errmsg(database) );
                }
                sqlite3_finalize(statement);
            }
        }
        else
        {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
        }
    }
    sqlite3_close(database);
}

-(void) sympArray:(NSMutableArray*) array
{
    sqlite3_stmt    *statement;
    NSString *val = @"";
    [array removeAllObjects];
    NSString *bleName = [self getSavedDeviceName];
    NSString *catName = [self getSavedCatridgeName];
    if(bleName == nil || [bleName isEqualToString:@"[ ]"])
        return;
    
    NSString *sql = [NSString stringWithFormat: @"SELECT symps FROM sympInf WHERE blenames='%@' and catridge='%@'",bleName, catName];
    const char *query_stmt5 = [sql UTF8String];
    
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            const char  *temp = (const char *)sqlite3_column_text(statement, 0);
            if(temp == nil)
                return;
            val = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
            if([val length]>0)
            {
                NSArray *tarray = [val componentsSeparatedByString:@"A"];
                for(int i=0; i<[tarray count]; i++)
                {
                    if([[tarray objectAtIndex:i] isEqualToString:@""])
                        continue;
                    int vals = [[tarray objectAtIndex:i] intValue];
                    [array addObject:[NSNumber numberWithInt:vals]];
                }
                tarray = nil;
            }
        }
        else{
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}
-(void) changeSympTable:(NSMutableArray*) array
{
    sqlite3_stmt    *statement;
    int val = 0;
    NSString *symps = @"";
    NSString *symps_t = @"";
    NSString *bleName = [self getSavedDeviceName];
    NSString *cat = [self getSavedCatridgeName];
    for(int i =0; i<[array count]; i++)
    {
        int temp = [[array objectAtIndex:i] intValue];
        symps = [NSString stringWithFormat:@"%@%dA",symps,temp];
    }
    //saveSymp = symps;
     NSString *sql = [NSString stringWithFormat: @"SELECT count(symps) FROM sympInf WHERE blenames='%@' and catridge='%@'",bleName,cat];
    const char *query_stmt5 = [sql UTF8String];
    
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            val =(int) sqlite3_column_int(statement, 0);
            sqlite3_finalize(statement);
            if(val == 0)
            {
                NSString *sql1 = [NSString stringWithFormat: @"INSERT INTO sympInf (dt, symps, catridge, blenames)  VALUES('%@','%@','%@','%@');",currentTime, symps, cat, bleName];
                const char *query_stmt51 = [sql1 UTF8String];
                sqlite3_busy_timeout(database, 500);
                if(sqlite3_prepare_v2(database, query_stmt51, -1, &statement, NULL) != SQLITE_OK)
                {
                    NSLog(@"Insert Symp Error: %s", sqlite3_errmsg(database));
                }
                
                if(sqlite3_step(statement) != SQLITE_DONE ) {
                    NSLog( @"Insert Symp Error: %s", sqlite3_errmsg(database) );
                }
                sqlite3_finalize(statement);
            }
            else
            {
                NSString *sql2 = [NSString stringWithFormat: @"UPDATE sympInf SET symps = '%@' WHERE blenames = '%@' and catridge='%@'", symps, bleName,cat];
                const char *query_stmt52 = [sql2 UTF8String];
                sqlite3_busy_timeout(database, 500);
                if(sqlite3_prepare_v2(database, query_stmt52, -1, &statement, NULL) != SQLITE_OK)
                {
                    NSLog(@"Update Symp Error: %s", sqlite3_errmsg(database));
                }
                if(sqlite3_step(statement) != SQLITE_DONE ) {
                    NSLog( @"Update Symp Error: %s", sqlite3_errmsg(database) );
                }
                sqlite3_finalize(statement);
            }
        }
        else
        {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            sqlite3_close(database);
        }
    }
}

-(void) addVape:(NSString*) feelStr
{
    NSString *cat = [self getSavedCatridgeName];
    NSString *devName = [self getSavedDeviceName];
    sqlite3_stmt    *statement;
    
    NSString *sql = [NSString stringWithFormat: @"INSERT INTO vapeInf (dt, dose, feel, catridge, blename)  VALUES('%@',%d,'%@','%@', '%@');", currentTime, currentDose ,feelStr ,cat, devName];
    const char *query_stmt5 = [sql UTF8String];
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    
    if(sqlite3_open_v2([paths UTF8String], &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        sqlite3_busy_timeout(database, 500);
        if(sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) != SQLITE_OK)
        {
            NSLog(@"Insert Vape Error: %s", sqlite3_errmsg(database));
        }
        
        if(sqlite3_step(statement) != SQLITE_DONE ) {
            NSLog( @"Insert Vape  Error: %s", sqlite3_errmsg(database) );
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    
    if(shareState==NO)
    {
        NSString *sql2 = [NSString stringWithFormat: @"INSERT INTO commInf (dt, dose, feel, catridge, blename)  VALUES('%@',%d,'%@','%@', '%@');", currentTime, currentDose ,feelStr ,cat, devName];
        const char *query_stmt6 = [sql2 UTF8String];
        [self createEditableCopyOfDatabaseIfNeeded];
        
        if(sqlite3_open_v2([paths UTF8String], &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
        {
            sqlite3_busy_timeout(database, 500);
            if(sqlite3_prepare_v2(database, query_stmt6, -1, &statement, NULL) != SQLITE_OK)
            {
                NSLog(@"Insert Comm Error: %s", sqlite3_errmsg(database));
            }
            
            if(sqlite3_step(statement) != SQLITE_DONE ) {
                NSLog( @"Insert Comm  Error: %s", sqlite3_errmsg(database) );
            }
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
    }
}


#pragma mark - Graph Processing

-(void) loadGraph
{
    NSString *cat = [self getSavedCatridgeName];
    int todayCount = [self totalDosesinToday];
    //int weekCount = [self totalDosesinWeek];
    //int tCount = [self totalDoses];
    NSString *todayRes = [NSString stringWithFormat:@"%d/%d", todayCount, [self getDosageLimitValue]];
    //NSString *weekRes = [NSString stringWithFormat:@"%d doses", weekCount];
    //NSString *cntRes = [NSString stringWithFormat:@"%d", tCount];
    _lblTodayUsage.text = todayRes;
    //_lblWeekUsage.text = weekRes;
  
    [_btnCatridge setTitle:cat forState:UIControlStateNormal];
    [_btnGraphCat setTitle:cat forState:UIControlStateNormal];
    _mLblAssoCat.text = cat;
    _doseCartridgeName.text = cat;
    _mLblSympCat.text = cat;
    _mLblFeelingsCat.text = cat;
    _lblConfirmDosageName.text =cat;
    
    ////////////////////////////////////////////////
    [self changeColors];
    [self reloadGraph];
}


-(void) changeColors
{
    NSString *cat = [self getSavedCatridgeName];
    colorIndex = -1;
    NSLog(@"Cat Name - %@", cat);
    UIColor *colorc = [UIColor whiteColor];
    for(int i =0; i<[catridgsArray count]; i++)
    {
        NSString *str = [catridgsArray objectAtIndex:i];
        if([str isEqualToString:cat])
        {
            colorIndex = [[catridgsColorArray objectAtIndex:i] intValue];
            break;
        }
    }
    if(colorIndex > -1)
        colorc = [UIColor colorWithRed:colors_array[colorIndex*3]/255.0f green:colors_array[colorIndex*3 + 1]/255.0f blue:colors_array[colorIndex*3+2]/255.0f alpha:1.0];
    
    [_btnCatridge setTitleColor:colorc forState:UIControlStateNormal];
    [_btnGraphCat setTitleColor:colorc forState:UIControlStateNormal];
    _mLblAssoCat.textColor = colorc;
    _doseCartridgeName.textColor = colorc;
    _mLblSympCat.textColor = colorc;
    _mLblFeelingsCat.textColor = colorc;
    _lblTodayUsage.textColor =  colorc;
    _lblMyDose.textColor = colorc;
    //_lblConfirmDosageName.textColor=colorc;
    
    for(int i=0; i<4; i++)
    {
        UILabel *lb = [_mSymptomsRelievedView viewWithTag:i+21];
        lb.textColor = colorc;
    }
    for(int j=0; j<4; j++)
    {
        UILabel *lb = [_mAssociatedFeelingsView viewWithTag:j+21];
        lb.textColor = colorc;
    }
    
}

#pragma mark - show toast message
-(void) showToastShort:(NSString*) message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    //hud.backgroundColor = [UIColor redColor];
    [hud hide:YES afterDelay:1.5];
}

-(void) showToastLong:(NSString*) message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    //hud.backgroundColor = [UIColor redColor];
    [hud hide:YES afterDelay:3];
}

#pragma mark - vibrate
-(void) vibratePhone
{
    if([[UIDevice currentDevice].model isEqualToString:@"iPhone"])
    {
        AudioServicesPlaySystemSound (1352); //works ALWAYS as of this post
    }
    else
    {
        // Not an iPhone, so doesn't have vibrate
        // play the less annoying tick noise or one of your own
        AudioServicesPlayAlertSound (1105);
    }
}


#pragma mark - child Safety button Image
-(void) changeChildSafetyButtonImage:(int) status
{
    UIImage *simage_childonnone = (UIImage *)[UIImage imageNamed:@"child_on_none"];
    UIImage *simage_childoffnone = (UIImage *)[UIImage imageNamed:@"child_off_none"];
    
    switch(status)
    {
        case CHILD_SAFETY_ON_NONE:
            [_childSafetyButton setImage:simage_childonnone forState:UIControlStateNormal];
            [_childSafetyButton setEnabled:false];
            
            _lblTotal.text = @"Child Safety ON";   // Dragon_3
            break;
        case CHILD_SAFETY_OFF_NONE:
            [_childSafetyButton setImage:simage_childoffnone forState:UIControlStateNormal];
            [_childSafetyButton setEnabled:false];
            
            _lblTotal.text = @"Child Safety OFF";    // Dragon_3
            break;
        case CHILD_SAFETY_ON:
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_on_btn"] forState:UIControlStateNormal];
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_off_btn"] forState:UIControlStateHighlighted];
            [_childSafetyButton setEnabled:true];
            _lblChildOn.font = [UIFont boldSystemFontOfSize:22.0];
            _lblChildOff.font = [UIFont systemFontOfSize:20.0];
//            _lblTotal.text = @"Child Safety ON";
            _lblTotal.text = @"Child Safety OFF";   // Dragon_3
            break;
        case CHILD_SAFETY_OFF:
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_off_btn"] forState:UIControlStateNormal];
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_on_btn"] forState:UIControlStateHighlighted];
            [_childSafetyButton setEnabled:true];
            _lblChildOff.font = [UIFont boldSystemFontOfSize:22.0];
            _lblChildOn.font = [UIFont systemFontOfSize:20.0];
//            _lblTotal.text = @"Child Safety OFF";
            _lblTotal.text = @"Child Safety ON";    // Dragon_3
            break;
    }
}


#pragma mark - Drawing Graph
-(void)initGraph
{
    plotXStartRange = 0;//-24 * 6;
    plotXLengthRange = 4;// 24 * 7;
    plotXInterval = 1;
    plotYMaxRange = 10;
    plotYMinRange = 0;
    plotYInterval = 1;
    
    graphFirstValues = [[NSMutableArray alloc] init];
    graphSecondValues = [[NSMutableArray alloc] init];
    graphThirdValues = [[NSMutableArray alloc] init];
    graphLabels = [[NSMutableArray alloc] init];
    //Initialize and display Graph (x and y axis lines)
    
    CGRect frame = self.mGraphView.bounds;
    frame.size.width = [[UIScreen mainScreen] bounds].size.width - 40;
    self.pressure_graph = [[CPTXYGraph alloc] initWithFrame:frame];
    self.pressure_hostView = [[CPTGraphHostingView alloc] initWithFrame:frame];
    self.pressure_hostView.hostedGraph = self.pressure_graph;
    
    [self.mGraphView addSubview:_pressure_hostView];
    
    //apply styling to Graph
    [self.pressure_graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    
    //set graph backgound area transparent
    self.pressure_graph.backgroundColor = nil;
    self.pressure_graph.fill = nil;
    self.pressure_graph.plotAreaFrame.fill = nil;
    self.pressure_graph.plotAreaFrame.plotArea.fill = nil;
    
    //This removes top and right lines of graph
    self.pressure_graph.plotAreaFrame.borderLineStyle = nil;
    
    //This shows x and y axis labels from 0 to 1
    self.pressure_graph.plotAreaFrame.masksToBorder = NO;
    
    
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.pressure_graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(plotXStartRange)
                                                    length:CPTDecimalFromInt(plotXLengthRange)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(plotYMinRange)
                                                    length:CPTDecimalFromInt(plotYMaxRange)];
    
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.pressure_graph.axisSet;
    NSNumberFormatter *axisLabelFormatter = [[NSNumberFormatter alloc]init];
    [axisLabelFormatter setGeneratesDecimalNumbers:NO];
    [axisLabelFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [axisLabelFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    //Define x-axis properties
    //x-axis intermediate interval 2
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromInt(plotXInterval);
    axisSet.xAxis.minorTicksPerInterval = 1;
    axisSet.xAxis.minorTickLength = 5;
    axisSet.xAxis.majorTickLength = 7;
    
    //axisSet.xAxis.title = @"Time";
    axisSet.xAxis.titleOffset = 4;
    axisSet.xAxis.labelFormatter = axisLabelFormatter;
    
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    axisSet.xAxis.labelTextStyle = titleStyle;
    axisSet.yAxis.labelTextStyle = titleStyle;
    
    //Define y-axis properties
    //y-axis intermediate interval = 50;
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromInt(plotYInterval);
    axisSet.yAxis.minorTicksPerInterval = 1;
    axisSet.yAxis.minorTickLength = 5;
    axisSet.yAxis.majorTickLength = 7;
    //axisSet.yAxis.title = @"Doses";
    axisSet.yAxis.titleOffset = 1;
    axisSet.yAxis.labelFormatter = axisLabelFormatter;
    
    //set graph grid lines
    CPTMutableLineStyle *gridLineStyle = [[CPTMutableLineStyle alloc] init];
    gridLineStyle.lineColor = [CPTColor colorWithComponentRed:53.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:1.0];
    gridLineStyle.lineWidth = 0.5;
    axisSet.xAxis.majorGridLineStyle = gridLineStyle;
    axisSet.yAxis.majorGridLineStyle = gridLineStyle;
    
    //Define line plot and set line properties
    self.firstPlot = [[CPTScatterPlot alloc] init];
    self.firstPlot.dataSource = self;
    self.firstPlot.identifier = @"first";
    [self.pressure_graph addPlot:self.firstPlot toPlotSpace:plotSpace];
    
    self.secondPlot = [[CPTScatterPlot alloc] init];
    self.secondPlot.dataSource = self;
    self.secondPlot.identifier = @"second";
    [self.pressure_graph addPlot:self.secondPlot toPlotSpace:plotSpace];
    
    /* self.thirdPlot = [[CPTScatterPlot alloc] init];
     self.thirdPlot.dataSource = self;
     self.thirdPlot.identifier = @"third";
     [self.pressure_graph addPlot:self.thirdPlot toPlotSpace:plotSpace];*/
    
    
    
    //first plot style
    //set line plot style
    CPTColor *firstColor = [CPTColor colorWithComponentRed:0 green:183.0f/255.0f blue:1.0 alpha:1.0];
    CPTMutableLineStyle *firstLineStyle = [self.firstPlot.dataLineStyle mutableCopy];
    firstLineStyle.lineWidth = 2;
    firstLineStyle.lineColor = [CPTColor colorWithComponentRed:1.0 green:1.0 blue:0.7 alpha:0.0];;//firstColor;
    self.firstPlot.dataLineStyle = firstLineStyle;
    
    CPTMutableLineStyle *firstSymbolineStyle = [CPTMutableLineStyle lineStyle];
    firstSymbolineStyle.lineColor = firstColor;
    CPTPlotSymbol *firstSymbol = [CPTPlotSymbol hexagonPlotSymbol];
    firstSymbol.fill = [CPTFill fillWithColor:firstColor];
    firstSymbol.lineStyle = firstSymbolineStyle;
    firstSymbol.size = CGSizeMake(10.0f, 10.0f);
    self.firstPlot.plotSymbol = firstSymbol;
    
    //second plot style
    //set line plot style
    CPTColor *secondColor = [CPTColor colorWithComponentRed:204.0f/255.0f green:159.0f/255.0f blue:83.0f/255.0f alpha:1.0];
    CPTMutableLineStyle *secondLineStyle = [self.secondPlot.dataLineStyle mutableCopy];
    secondLineStyle.lineWidth = 2;
    secondLineStyle.lineColor = [CPTColor colorWithComponentRed:1.0 green:1.0 blue:0.7 alpha:0.0];// secondColor;
    self.secondPlot.dataLineStyle = secondLineStyle;
    
    CPTMutableLineStyle *secondSymbolineStyle = [CPTMutableLineStyle lineStyle];
    secondSymbolineStyle.lineColor = secondColor;
    CPTPlotSymbol *secondSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    secondSymbol.fill = [CPTFill fillWithColor:secondColor];
    secondSymbol.lineStyle = secondSymbolineStyle;
    secondSymbol.size = CGSizeMake(8.0f, 8.0f);
    self.secondPlot.plotSymbol = secondSymbol;
    
    //third plot style
    //set line plot style
    
    
    /*CPTColor *thirdColor = [CPTColor colorWithComponentRed:0 green:0.094 blue:1.0 alpha:1.0];
     CPTMutableLineStyle *thirdLineStyle = [self.firstPlot.dataLineStyle mutableCopy];
     thirdLineStyle.lineWidth = 2;
     thirdLineStyle.lineColor = thirdColor;
     self.thirdPlot.dataLineStyle = thirdLineStyle;
     
     CPTMutableLineStyle *thirdSymbolineStyle = [CPTMutableLineStyle lineStyle];
     thirdSymbolineStyle.lineColor = thirdColor;
     CPTPlotSymbol *thirdSymbol = [CPTPlotSymbol ellipsePlotSymbol];
     thirdSymbol.fill = [CPTFill fillWithColor:thirdColor];
     thirdSymbol.lineStyle = thirdSymbolineStyle;
     thirdSymbol.size = CGSizeMake(3.0f, 3.0f);
     self.thirdPlot.plotSymbol = thirdSymbol;*/
    
    
}

-(int) diffDays:(int) year month:(int)month day:(int)day lYear:(int) lyear lMonth:(int)lmonth lDay:(int)lday
{
    NSString *s1 = [NSString stringWithFormat:@"%04d-%02d-%02d 00:00:00",year,month,day];
    NSString *s2 = [NSString stringWithFormat:@"%04d-%02d-%02d 00:00:00",lyear,lmonth,lday];
    
    NSDateFormatter *formater=[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"YYYY-MM-dd  HH:mm:ss"];
    [formater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date1 = [formater dateFromString:s1];
    NSDate *date2 = [formater dateFromString:s2];
    
    NSTimeInterval secs= [date2 timeIntervalSinceDate:date1];
    int numberofDays = secs / 86400;
    return numberofDays + 1;
}
-(int) dayInfo:(int) year month:(int)month day:(int)day diff:(int)diff
{
    int res = 0;
    int days[12]={31,28,31,30,31,30,31,31,30,31,30,31};
    int cur_year = year;
    int cur_month = month;
    int cur_day = day;
    
    if(month == 1 && diff>=day)
    {
        cur_year--;
        cur_month = 12;
        cur_day = days[cur_month-1] + day - diff;
    }
    else if(month == 3 && diff>=day)
    {
        cur_month = 2;
        cur_day = days[cur_month] + day - diff + year % 4 == 0?1:0;
    }
    else if(month>2 && diff>=day)
    {
        cur_month--;
        cur_day = days[cur_month] + day - diff;
    }
    else if(diff<day)
    {
        cur_day = day - diff;
    }
    res = cur_year * 10000 + cur_month * 100 + cur_day;
    NSLog(@"cur day - %d", res);
    return res;
}
-(NSMutableArray *)reloadGraph
{
    [graphFirstValues removeAllObjects];
    [graphSecondValues removeAllObjects];
    [graphThirdValues removeAllObjects];
    [graphLabels removeAllObjects];
    
    NSString *catrigeName = [self getSavedCatridgeName];
    int max = 3;
    
    int diff_days = [self diffDays:sel_year month:sel_month day:sel_day lYear:sel_last_year lMonth:sel_last_month lDay:sel_last_day];
    for(int q=1; q<=diff_days; q++)
    {
        [graphLabels addObject:[NSString stringWithFormat:@"%02d",q]];
    }
    
    for(int k=diff_days-1; k>=0; k--)
    {
        int res = [self dayInfo:sel_last_year month:sel_last_month day:sel_last_day diff:k];
        int temp_year = res /10000;
        int temp_month = res /100 % 100;
        int temp_day = res % 100;
        
        int count = [self totalDosesinDay:temp_year month:temp_month day:temp_day  CatridgeName:catrigeName];
        [graphFirstValues addObject:[NSNumber numberWithInt:count]];
        if(count>max)
            max = count;
    }
    
    int avsum = 0;
    int avcount = 0;
    
    for(int w=diff_days-1; w>=0; w--)
    {
        int res = [self dayInfo:sel_last_year month:sel_last_month day:sel_last_day diff:w];
        int temp_year = res /10000;
        int temp_month = res /100 % 100;
        int temp_day = res % 100;
        int count = [self totalCommDosesinDay:temp_year month:temp_month day:temp_day CatridgeName:catrigeName];
        
        [graphSecondValues addObject:[NSNumber numberWithInt:count]];
        if(count>max)
            max = count;
        avsum+=count;
        if(count > 0)
            avcount++;
    }
    
    /*for(int q=-24*6; q<24; q++)
     {
     [graphLabels addObject:[NSString stringWithFormat:@"%02d",q]];
     }
     
     for(int k=6; k>=0; k--)
     {
     int res = [self dayInfo:sel_year month:sel_month day:sel_day diff:k];
     int temp_year = res /10000;
     int temp_month = res /100 % 100;
     int temp_day = res % 100;
     for(int i = 0; i<24; i++)
     {
     int count = [self totalDosesinHour:temp_year month:temp_month day:temp_day hour:i  CatridgeName:catrigeName];
     if(count>max)   max = count;
     [graphFirstValues addObject:[NSNumber numberWithInt:count]];
     count = 0;
     }
     }
     
     
     int avsum = 0;
     int avcount = 0;
     
     for(int w=6; w>=0; w--)
     {
     int res = [self dayInfo:sel_year month:sel_month day:sel_day diff:w];
     int temp_year = res /10000;
     int temp_month = res /100 % 100;
     int temp_day = res % 100;
     for(int j = 0; j<24; j++)
     {
     int count = [self totalCommDosesinHour:temp_year month:temp_month day:temp_day hour:j  CatridgeName:catrigeName];
     if(count>max)   max = count;
     [graphSecondValues addObject:[NSNumber numberWithInt:count]];
     avsum+=count;
     if(count > 0)
     avcount++;
     }
     }
     */
    
    if(avcount == 0)
        _lblAverageHour.text = @"0";
    else
        _lblAverageHour.text = [NSString stringWithFormat:@"%d", (int)(ceil(avsum/avcount))];
    
    int xMax = [self diffDays:sel_year month:sel_month day:sel_day lYear:sel_last_year lMonth:sel_last_month lDay:sel_last_day];
    
    int xMaxShow = xMax + 1;//xMax<4?4:xMax;
    [self updatePlotSpace:max + 1 xMax:xMaxShow];
    [self.pressure_graph reloadData];
    return nil;
}

-(void)updatePlotSpace:(int)yMax xMax:(int)xMax
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.pressure_graph.defaultPlotSpace;
    [plotSpace scaleToFitPlots:@[self.firstPlot]];
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(plotXStartRange)
                                                    length:CPTDecimalFromInt(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(plotYMinRange)
                                                    length:CPTDecimalFromInt(yMax)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.pressure_graph.axisSet;
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromInt(plotXInterval);
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromInt(yMax/4);
    
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [graphFirstValues count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    if([plot.identifier isEqual:@"first"])
    {
        switch (fieldEnum) {
            case CPTScatterPlotFieldX:
                return [graphLabels objectAtIndex:index];
                break;
                
            case CPTScatterPlotFieldY:
                return [graphFirstValues objectAtIndex:index];
                break;
        }
    }
    else  if([plot.identifier isEqual:@"second"])
    {
        switch (fieldEnum) {
            case CPTScatterPlotFieldX:
                return [graphLabels objectAtIndex:index];
                break;
                
            case CPTScatterPlotFieldY:
                return [graphSecondValues objectAtIndex:index];
                break;
        }
    }
    else  if([plot.identifier isEqual:@"third"])
    {
        switch (fieldEnum) {
            case CPTScatterPlotFieldX:
                return [graphLabels objectAtIndex:index];
                break;
                
            case CPTScatterPlotFieldY:
                return [graphThirdValues objectAtIndex:index];
                break;
        }
    }
    return [NSDecimalNumber zero];
}
#pragma mark - CPTPlotDelegate methods
/*- (CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate {
 
 return newRange;
 }*/
-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)displacement{
    return CGPointMake(displacement.x,0);}

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate{
    if (coordinate == CPTCoordinateY) {
        // newRange = ((CPTXYPlotSpace*)space).yRange;
    }
    return newRange;
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (catridgsArray == nil)
        return 0;
    return [catridgsArray count];    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1; //count number of row from counting array hear cataGorry is An Array
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:MyIdentifier] ;
    }
    
    NSString *catName = (NSString*)[catridgsArray objectAtIndex:indexPath.section];
    cell.textLabel.text = catName;
    
    int indexColor = [[catridgsColorArray objectAtIndex:indexPath.section] intValue];
    UIColor *color = [UIColor whiteColor];
    
    if(indexColor < 10)
    {
        color = [UIColor colorWithRed:colors_array[indexColor*3]/255.0f green:colors_array[indexColor*3 + 1]/255.0f blue:colors_array[indexColor*3+2]/255.0f alpha:1.0];
    }
    cell.textLabel.textColor= [UIColor whiteColor];//color;
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20.0];
    
    //cell.detailTextLabel.text= [dev.identifier UUIDString];
    //cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    
    [cell.imageView setImage:nil];
    //UIImageView *myView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"devicepen"]];
    UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [infoButton setImage:[UIImage imageNamed:@"infocat"] forState:UIControlStateNormal];
    [infoButton setImage:[UIImage imageNamed:@"infocat_high"] forState:UIControlStateHighlighted];
    
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    [tableView setBackgroundView:nil];
    [tableView setBackgroundColor:[UIColor clearColor]];
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectCatIndex = indexPath.section;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self.catTableView reloadData];
    [_mCatridgeSelectView setHidden:YES];
    
    NSString *catName =defaultCatridgeName;
    if([catridgsArray count]>selectCatIndex)
        catName = [catridgsArray objectAtIndex:selectCatIndex];
    [self saveCatridgeName:catName];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableArray *resArray = [[NSMutableArray alloc] init];
    [self catArray:tempArray];
    [self updateCatArray:tempArray NewVal:catName NewArray:resArray];
    [self changeCatTable:resArray];
    
    [self refreshAllData];
}

-(void) updateCatArray:(NSMutableArray*) array NewVal :(NSString*)new_val NewArray:(NSMutableArray*) new_array
{
    [new_array removeAllObjects];
    [new_array addObject:new_val];
    for(int i=0; i<[array count]; i++)
    {
        NSString* cur_val = (NSString*)[array objectAtIndex:i];
        if(![cur_val isEqualToString:new_val])
            [new_array addObject:cur_val];
    }
}

-(void) changeCatTable:(NSMutableArray*) array
{
    sqlite3_stmt    *statement;
    NSString *cats = @"";
   
    for(int i =0; i<[array count]; i++)
    {
        NSString *temp = (NSString*)[array objectAtIndex:i];
        cats = [NSString stringWithFormat:@"%@%@!",cats,temp];
    }
    
    NSString *sql = [NSString stringWithFormat: @"SELECT count(cats) FROM catInf",nil];
    const char *query_stmt5 = [sql UTF8String];
    
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        if (sqlite3_prepare_v2(database, query_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            int res  =(int) sqlite3_column_int(statement, 0);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            if(res == 0)
            {
                if(sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
                {
                    
                    NSString *currentTime5 = [self currentDateTime];
                    NSString *sql1 = [NSString stringWithFormat: @"INSERT INTO CatInf (dt, cats) VALUES('%@','%@');",currentTime5, cats];
                    const char *query_stmt51 = [sql1 UTF8String];
                    sqlite3_busy_timeout(database, 500);
                    if(sqlite3_prepare_v2(database, query_stmt51, -1, &statement, NULL) != SQLITE_OK)
                    {
                        NSLog(@"Update Error: %s", sqlite3_errmsg(database));
                    }
                    
                    if(sqlite3_step(statement) != SQLITE_DONE ) {
                        NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
                    }
                    sqlite3_finalize(statement);
                    sqlite3_close(database);
                }
            }
            else
            {
                if(sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
                {
                    NSString *sql2 = [NSString stringWithFormat: @"UPDATE CatInf SET cats = '%@' WHERE id = 1", cats];
                    const char *query_stmt52 = [sql2 UTF8String];
                    if(sqlite3_prepare_v2(database, query_stmt52, -1, &statement, NULL) != SQLITE_OK)
                    {
                        NSLog(@"Update Error: %s", sqlite3_errmsg(database));
                    }
                    if(sqlite3_step(statement) != SQLITE_DONE ) {
                        NSLog( @"Update Error: %s", sqlite3_errmsg(database) );
                    }
                    sqlite3_finalize(statement);
                    sqlite3_close(database);
                    
                }
            }
        }
        else
        {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            sqlite3_close(database);
        }
    }
}


#pragma mark - Web Api

-(void) sendChangeCoin
{
    
    NSString *userName = [self getSavedName];
    
    if([userName isEqualToString:@"Guest"])
    {
        return;
    }
    
    NSString *myMail = [self getSavedEmail];
    
    NSString *SEND_URL = @"http://opuluslabs.com/coin_modify.php";
    NSURL *url = [NSURL URLWithString:SEND_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    [jsonDic setValue:myMail forKey:@"email"];
    [jsonDic setValue:[NSString stringWithFormat:@"%d", coinValue] forKey:@"coin"];
    
    NSLog(@"data - %@",jsonDic);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:nil];
    
    NSString *postlength = [NSString stringWithFormat:@"%d", (int)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postlength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [self showProgress];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data == nil)
        {
            [self hideProgress];
            return;
        }
        
        NSDictionary *jDic = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
        NSLog(@"result: %@", jDic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgress];
            if(![jDic objectForKey:@"Coin"])
            {
                NSLog(@"server error");
            }
            else if ([[jDic objectForKey:@"Coin"] intValue] == 0)
            {
                NSLog(@"server error");
            }
        });
    }] resume];
}
-(void) sendMyVape:(NSString*) feelings symptoms:(NSString*)symptoms
{
    
    NSString *userName = [self getSavedName];
    
    if([userName isEqualToString:@"Guest"])
    {
       return;
    }
   
    NSString *myMail = [self getSavedEmail];
    NSString *devName = [self getSavedDeviceName];
    NSString *catName = [self getSavedCatridgeName];
    
    NSString *SEND_URL = @"http://opuluslabs.com/feeling_add.php";
    NSURL *url = [NSURL URLWithString:SEND_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    [jsonDic setValue:myMail forKey:@"email"];
    [jsonDic setValue:devName forKey:@"blename"];
    [jsonDic setValue:catName forKey:@"cartridge"];
    [jsonDic setValue:@"1" forKey:@"dose"];
    [jsonDic setValue:feelings forKey:@"feel"];
    [jsonDic setValue:symptoms forKey:@"symp"];
    [jsonDic setValue:shareState?@"1":@"0" forKey:@"isCommunity"];
 
    NSLog(@"data - %@",jsonDic);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:nil];
    
    NSString *postlength = [NSString stringWithFormat:@"%d", (int)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postlength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //[self showProgress];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data == nil)
        {
            //[self hideProgress];
            return;
        }
        
        NSDictionary *jDic = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
        NSLog(@"\nresult: %@\n", jDic);
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self hideProgress];
            if(![jDic objectForKey:@"Feelings"])
            {
                NSLog(@"server error");
            }
            else if ([[jDic objectForKey:@"Feelings"] intValue] == 0)
            {
                NSLog(@"server error");
            }
        });
    }] resume];
}

-(void) sendDatabase
{
    NSString * paths=[self getWritableDBPath];
    //NSString *filenames = @"ecodatabse.db";
    
    NSString *myMail = [self getSavedEmail];
    NSString  *SEND_URL = @"http://opuluslabs.com/ecobackup.php";
    NSData *file_data = [NSData dataWithContentsOfFile:paths];
    NSString *file_base64 = [file_data base64Encoding];
    NSURL *url = [NSURL URLWithString:SEND_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    [jsonDic setValue:myMail forKey:@"email"];
    [jsonDic setValue:@"database.db" forKey:@"filename"];
    [jsonDic setValue:file_base64 forKey:@"file_data"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:nil];
    
    NSString *postlength = [NSString stringWithFormat:@"%d", (int)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postlength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [self showProgress];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data == nil)
        {
            [self hideProgress];
            return;
        }
        //NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        NSDictionary *jDic = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
        NSLog(@"result: %@", jDic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgress];
            if(![jDic objectForKey:@"success"])
            {
                NSLog(@"server error");
            }
            else if ([[jDic objectForKey:@"success"] intValue] == 0)
            {
                NSLog(@"server error");
            }
        });
    }] resume];
}

#pragma mark-
#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int pageNum = round( scrollView.contentOffset.x / scrollView.frame.size.width);
    currentPageIndex = pageNum;
    self.pageControl.currentPage = pageNum;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onTimerScroll) userInfo:nil repeats:YES];
}


- (void) tapped:(UITapGestureRecognizer*)tapRecognizer
{
    NSLog(@"tap on %d",currentPageIndex);
    
}

#pragma mark - user image;
-(void) initImageProcess
{
    NSString *userName = [self getSavedName];
    NSString *filePath = [self getUserImageName:userName];
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSLog(@"\nfilePath : %@ \n", filePath);
    if([fm fileExistsAtPath:filePath isDirectory:nil])
    {
//        [_btnUserImage setImage:[self getImage:userName] forState:UIControlStateNormal];
        [_btnUserImage setImage:[self cropImage:[self getImage:userName]] forState:UIControlStateNormal];   // Dragon_3
        
        //_imgUser.image = [self getImage:userName];
        //oldUserImageName = userName;
    }
}

-(NSString*)getSavedName
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"guest";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:KEY_FIRSTNAME];
        if(result == nil)
            result = @"guest";
    }
    return result;
}

#pragma mark - get Image Info
- (NSString *)getUserImageName :(NSString*) userName
{
    NSArray *paths          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [paths objectAtIndex:0];
    NSString *imgfileName   = [NSString stringWithFormat:@"img_%@_thumb.jpg", userName];
    directoryPath = [directoryPath stringByAppendingPathComponent:@"UserImage"];
    NSString *dstPath = [directoryPath stringByAppendingPathComponent:imgfileName];
    
    return dstPath;
}

- (UIImage *)getImage:(NSString*) userName
{
    UIImage *userImage = [UIImage imageWithContentsOfFile:[self getUserImageName:userName]];
    return userImage;
}

// Dragon_3
- (UIImage*) cropImage:(UIImage*)inputImage
{
    CGSize ori = inputImage.size;
    CGSize newSize = CGSizeMake(ori.width, ori.width);
    if (ori.height < ori.width) {
        newSize = CGSizeMake(ori.height, ori.height);
    }
    CGFloat viewWidth = newSize.width;
    CGFloat viewHeight = newSize.width;
    CGRect cropRect = CGRectMake((ori.width - viewWidth) / 2, (ori.height - viewHeight) / 2, viewWidth, viewHeight);
    
    // viewWidth, viewHeight are dimensions of imageView
    //    const CGFloat imageViewScale = MAX(inputImage.size.width/viewWidth, inputImage.size.height/viewHeight);
    const CGFloat imageViewScale = 1.0;
    // Scale cropRect to handle images larger than shown-on-screen size
    cropRect.origin.x *= imageViewScale;
    cropRect.origin.y *= imageViewScale;
    cropRect.size.width *= imageViewScale;
    cropRect.size.height *= imageViewScale;
    
    // Perform cropping in Core Graphics
    CGImageRef cutImageRef = CGImageCreateWithImageInRect(inputImage.CGImage, cropRect);
    
    // Convert back to UIImage
    UIImage* croppedImage = [UIImage imageWithCGImage:cutImageRef];
    
    // Clean up reference pointers
    CGImageRelease(cutImageRef);
    
    return croppedImage;
}
@end

