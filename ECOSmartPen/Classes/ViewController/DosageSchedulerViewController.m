//
//  DosageSchedulerViewController.m
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import "DosageSchedulerViewController.h"
#import "Const.h"
#import "PopoverViewController.h"
#import "UIPopoverController+iPhone.h"
#import <sqlite3.h>

NSString *weekName[] = {@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"};



@interface DosageSchedulerViewController ()
{
    NSString *sampleID;
}
@end

@implementation DosageSchedulerViewController
@synthesize HUD;
@synthesize mProgressLabel;
@synthesize maskView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
     
    [self addGestureRecogniser:_mMenuView];
    [self addGestureRecogniser:_mChildSafetyView];
    [self addGestureRecogniser:_mDayList];
    // Do any additional setup after loading the view.
    
    NSDate *nowDATE = [NSDate date];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit|NSWeekdayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:units fromDate:nowDATE];
    [components setTimeZone:[NSTimeZone localTimeZone]];
    dayCount = (int)[components weekday] - 1;
    
    //dayCount = [self getSavedWeekDayValue];
    dosageTime = [self getSavedDosageTimeValue];
    
    _lblCatridgeName.text = [self getSavedCatridgeName];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self dayDosageArray:array];
    if(dayCount<[array count])
    {
        dosagemount = [[array objectAtIndex:dayCount] intValue];
        _lblDosageLimit.text = [NSString stringWithFormat:@"%d", dosagemount];
        array = nil;
        _lblDay.text = weekName[dayCount];
    }
    
    int hour = dosageTime /60;
    int min = dosageTime % 60;
    if(hour > 11)
        _txtDosageTime.text = [NSString stringWithFormat:@"%02d:%02d PM",(int)hour - 12, (int)min];
    else
        _txtDosageTime.text = [NSString stringWithFormat:@"%02d:%02d AM",(int)hour, (int)min];

    
    [self changeChildSafetyButtonImage:childSafetyValue];

    
    [self initDatePicker];
    [self progressInit];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DisconnectEvent object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self changeChildSafetyButtonImage:childSafetyValue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleDisconnected:)
                                                 name:DisconnectEvent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleReadBatteryValue:)
                                                 name:ReadBatteryValueChange
                                               object:nil];
    [_lblBatteryLevel setText:[NSString stringWithFormat:@"%d %%",batteryLevel]];
    [self setBattery:batteryLevel];
     [_lblCoinValue setText:[NSString stringWithFormat:@"%d coins",coinValue]];
}

-(void)addGestureRecogniser:(UIView *)touchView{
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maskViewTouch)];
    [touchView addGestureRecognizer:singleTap];
}
-(void)maskViewTouch{
    [_mMenuView setHidden:YES];
    [_mChildSafetyView setHidden:YES];
    [_mDayList setHidden:YES];
}


- (IBAction)doneButtonClick:(id)sender {
    [self saveWeekDayValue:dayCount];
    [self saveDosageTimeValue:dosageTime];
    
    [self gotoScreen:SCREEN_HOME];
}
- (IBAction)plusButtonClick:(id)sender {
    if(dosagemount<50)
        dosagemount++;
    _lblDosageLimit.text = [NSString stringWithFormat:@"%d", dosagemount ];
    [self changeDosageLitmit:dosagemount];
    
    //[self sendDatabase]; 2017/04/26
}
- (IBAction)minusButtonClick:(id)sender {
    if(dosagemount>1)
        dosagemount--;
    _lblDosageLimit.text = [NSString stringWithFormat:@"%d", dosagemount ];
    [self changeDosageLitmit:dosagemount];
    
    //[self sendDatabase]; 2017/04/26
}

- (IBAction)homeButtonClick:(id)sender {
    [self gotoScreen:SCREEN_HOME];
}

- (IBAction)dosageSchedulerButtonClick:(id)sender {
       [_mMenuView setHidden:YES];
}

- (IBAction)yourESPButtonClick:(id)sender {
    [self gotoScreen:SCREEN_YOURESP];
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

- (IBAction)dayButtonClick:(id)sender {
    NSLog(@"Day click");
    [_mDayList setHidden:NO];
}


- (IBAction)weekdaysButtonClick:(id)sender {
    UIButton *but = (UIButton*)sender;
    int tag = (int)but.tag - 700;
    if(tag<7)
    {
        _lblDay.text = weekName[tag];
        dayCount = tag;
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self dayDosageArray:array];
        dosagemount = [[array objectAtIndex:tag] intValue];
        _lblDosageLimit.text = [NSString stringWithFormat:@"%d", dosagemount];
        array = nil;
        
    }
    [_mDayList setHidden:YES];
}


-(void) gotoScreen:(int) index
{
    switch(index)
    {
        case SCREEN_HOME:
            selectScreenIndex = SCREEN_NONE;
            break;
        case SCREEN_YOURESP:
            selectScreenIndex = SCREEN_YOURESP;
            break;
        case SCREEN_DOSAGESCHEDULER:
            selectScreenIndex = SCREEN_DOSAGESCHEDULER;
            break;
        case SCREEN_DOSAGETRACKER:
            selectScreenIndex = SCREEN_DOSAGETRACKER;
            break;
        case SCREEN_SELECTCATRIDGE:
            selectScreenIndex = SCREEN_SELECTCATRIDGE;
            break;
        case SCREEN_PROFILE:
            selectScreenIndex = SCREEN_PROFILE;
            break;
        case SCREEN_GUESTUSER:
            selectScreenIndex = SCREEN_GUESTUSER;
            break;
        case SCREEN_LOGOUT:
            selectScreenIndex = SCREEN_LOGOUT;
            break;
    }
    [self.navigationController popViewControllerAnimated:NO];
}


- (IBAction)menuButtonClick:(id)sender {
    [_mMenuView setHidden:NO];
}
- (IBAction)childSafetyButtonClick:(id)sender {
    [_mChildSafetyView setHidden:NO];
}

- (IBAction)childSafetyOffButtonClick:(id)sender {
    Byte data[1];
    data[0] = 3;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:1];
    [self sendBLEData:cmdData];
    childSafetyValue = CHILD_SAFETY_OFF;
    [self changeChildSafetyButtonImage:childSafetyValue];
}

- (IBAction)childSafetyOnButtonClick:(id)sender {
    Byte data[1];
    data[0] = 0;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:1];
    [self sendBLEData:cmdData];
    childSafetyValue = CHILD_SAFETY_ON;
    [self changeChildSafetyButtonImage:childSafetyValue];
}



#pragma mark - Save/Get function
-(void)saveDosageTimeValue:(int)value
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString* saveStatus = [NSString stringWithFormat:@"%d",value];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:saveStatus forKey:@"dosage_time"];
        [standardUserDefaults synchronize];
    }
}

-(int)getSavedDosageTimeValue
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    int res = 10 * 60;
    NSString *result = @"abc";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:@"dosage_time"];
        res = [result intValue];
        if(res == 0)
            res = 10 * 60;
    }
    
    NSLog(@"result = %@", result);
    return res;
}

-(void)saveWeekDayValue:(int)value
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString* saveStatus = [NSString stringWithFormat:@"%d",value];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:saveStatus forKey:@"week_day"];
        [standardUserDefaults synchronize];
    }
}

-(int)getSavedWeekDayValue
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    int res = 10;
    NSString *result = @"abc";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:@"week_day"];
        res = [result intValue];
        if(res == 0)
            res = 0;
    }
    
    NSLog(@"result = %@", result);
    return res;
}

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
    
    NSLog(@"result = %@", result);
    return result;
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
#pragma mark - database
-(void) changeDosageLitmit:(int) value
{
    sqlite3_stmt    *statement;
    NSString *days = @"";
    static sqlite3 *database = nil;
    
    
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    NSString *catName = [self getSavedCatridgeName];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self dayDosageArray:array];
    
    [array replaceObjectAtIndex:dayCount withObject:[NSNumber numberWithInt:value]];
    days = [NSString stringWithFormat:@"%d",[[array objectAtIndex:0] intValue]];
    for(int i=1; i<[array count]; i++)
    {
        days = [days stringByAppendingString:[NSString stringWithFormat:@"|%d",[[array objectAtIndex:i] intValue]]];
    }
    
    
    if(sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        NSString *sql2 = [NSString stringWithFormat: @"UPDATE CatridgeInfo SET days = '%@' WHERE SampleName = '%@'", days, catName];
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
    else
    {
        NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
        sqlite3_close(database);
    }
    
    ////////////////////////////////////////////////////////////////////
    NSString *strName = [self getSavedName];
    if([strName isEqualToString:@"Guest"])
    {
        return;
    }
    NSString *myMail = [self getSavedEmail];
   
    NSString  *CHANGESCHEDULE_URL = @"http://opuluslabs.com/changescheduler.php";
    NSURL *url = [NSURL URLWithString:CHANGESCHEDULE_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    [jsonDic setValue:myMail forKey:@"email"];
    [jsonDic setValue:sampleID forKey:@"sampleID"];
    [jsonDic setValue:catName forKey:@"cartridge"];
    [jsonDic setValue:catName forKey:@"sampleName"];
    [jsonDic setValue:days forKey:@"days"];
    
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
        NSLog(@"result: %@", jDic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgress];
            if([jDic objectForKey:@"schedule"])
            {
                NSLog(@"success");
            }
            else
            {
                NSLog(@"server error");
            }
        });
    }] resume];
}
-(void) dayDosageArray:(NSMutableArray*) array
{
    static sqlite3 *database = nil;
    sqlite3_stmt    *statement;
    NSString *val = @"";
    [array removeAllObjects];
    NSString *catName = [self getSavedCatridgeName];
    
    if(catName == nil || [catName isEqualToString:@"[ ]"])
        return;
    
    NSString *sql = [NSString stringWithFormat: @"SELECT days,sampleID FROM CatridgeInfo WHERE SampleName='%@'",catName];
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
            const char  *temp2 = (const char *)sqlite3_column_text(statement, 1);
            
            val = [[NSString alloc]initWithUTF8String:(const char *) temp];
            sampleID = [[NSString alloc]initWithUTF8String:(const char *)temp2];
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

- (NSString *) getWritableDBPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:myDB];
    
}

#pragma mark - Bluetooth Received
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
#pragma mark - Bluetooth Send

-(void) sendBLEData:(NSData*) data
{
    [mBLEComm sendCommand:data ServiceUUID:@"AAA0" CharacteristicUUID:@"AAA1"];
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
    
    [hud hide:YES afterDelay:3];
}


#pragma mark - child Safety button Image
-(void) changeChildSafetyButtonImage:(int) status
{
    switch(status)
    {
        case CHILD_SAFETY_ON_NONE:
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_on_none"] forState:UIControlStateNormal];
            [_childSafetyButton setEnabled:false];
            break;
        case CHILD_SAFETY_OFF_NONE:
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_off_none"] forState:UIControlStateNormal];
            [_childSafetyButton setEnabled:false];
            break;
        case CHILD_SAFETY_ON:
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_on_btn"] forState:UIControlStateNormal];
            [_childSafetyButton setImage:[UIImage imageNamed:@"childsafetyon_high"] forState:UIControlStateHighlighted];
            [_childSafetyButton setEnabled:true];
            _lblChildOn.font = [UIFont boldSystemFontOfSize:22.0];
            _lblChildOff.font = [UIFont systemFontOfSize:20.0];
            break;
        case CHILD_SAFETY_OFF:
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_off_btn"] forState:UIControlStateNormal];
            [_childSafetyButton setImage:[UIImage imageNamed:@"childsafetyoff_high"] forState:UIControlStateHighlighted];
            [_childSafetyButton setEnabled:true];
            _lblChildOff.font = [UIFont boldSystemFontOfSize:22.0];
            _lblChildOn.font = [UIFont systemFontOfSize:20.0];
            break;
    }
}


#pragma mark - select time
UIDatePicker *datePicker1;
UIView *mkView1;
-(void) initDatePicker
{
    datePicker1 = [[UIDatePicker alloc]init];
    
    NSDate* result;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setHour:(NSInteger)(dosageTime/60)];
    [comps setMinute:(NSInteger)(dosageTime%60)];
    NSCalendar *gre = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    result = [gre dateFromComponents:comps];
    [datePicker1 setDate:result];
    datePicker1.datePickerMode = UIDatePickerModeTime;
    [datePicker1 addTarget:self action:@selector(dateTextField:) forControlEvents:UIControlEventValueChanged];
    
    [_txtDosageTime setInputView:datePicker1];
    
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    [_txtDosageTime setInputAccessoryView:toolBar];
    
}

-(void) dateTextField:(id)sender
{
    
}

-(void) ShowSelectedDate
{
    UIDatePicker *picker = (UIDatePicker*)_txtDosageTime.inputView;
    //UIToolbar *toolbar = (UIToolbar*)_txtDosageTime.inputAccessoryView;
    [picker setMaximumDate:[NSDate date]];
    //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    
    unsigned units = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:units fromDate:eventDate];
    
    NSInteger hour = [components hour];
    NSInteger min = [components minute];
    
    dosageTime = (int)hour * 60 + (int)min;
    
    if(hour > 11)
        _txtDosageTime.text = [NSString stringWithFormat:@"%02d:%02d PM",(int)hour - 12, (int)min];
    else
        _txtDosageTime.text = [NSString stringWithFormat:@"%02d:%02d AM",(int)hour, (int)min];
    [_txtDosageTime resignFirstResponder];
}

#pragma mark - upload database
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

#pragma mark - Progress methods
-(void) progressInit
{
    // Do any additional setup after loading the view.
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x, self.view.center.y, 50, 50)];
    [button addTarget:self action:@selector(cancel_Progress) forControlEvents:UIControlEventTouchUpInside];
    button.center = HUD.center;
    [HUD addSubview:button];
    
    HUD.delegate = self;
    [HUD hide:YES];
    int                     ScreenHeight = 0;
    int                     ScreenWidth = 0;
    
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [maskView setBackgroundColor:[UIColor blackColor]];
    maskView.alpha = 0.4;
    
    mProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 50, ScreenHeight/2 + 40, 100, 30)];
    mProgressLabel.text = @"";
    mProgressLabel.textAlignment = NSTextAlignmentCenter;
    mProgressLabel.textColor = [UIColor whiteColor];
    mProgressLabel.backgroundColor = [UIColor clearColor];
    
}

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

-(void) cancel_Progress
{
    [self hideProgress];
}
@end
