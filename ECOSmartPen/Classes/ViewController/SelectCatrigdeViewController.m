//
//  SelectCatrigdeViewController.m
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import "SelectCatrigdeViewController.h"
#import "Const.h"
#import <sqlite3.h>


@interface SelectCatrigdeViewController ()

@end

NSMutableArray  *catsArray;


@implementation SelectCatrigdeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGestureRecogniser:_mMenuView];
    [self addGestureRecogniser:_mChildSafetyView];
    // Do any additional setup after loading the view.
    
    
    catsArray =  [[NSMutableArray alloc] init];
    
    
    [self changeChildSafetyButtonImage:childSafetyValue];
    
    
    [self.catTableView setBackgroundView:nil];
    [self.catTableView setBackgroundColor:[UIColor clearColor]];
    [self.catTableView setSeparatorColor:[UIColor clearColor]];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DisconnectEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleReadBatteryValue:)
                                                 name:ReadBatteryValueChange
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self changeChildSafetyButtonImage:childSafetyValue];
    
    
    [catsArray removeAllObjects];
    [self loadCatridge];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleDisconnected:)
                                                 name:DisconnectEvent
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
}


#pragma mark - Button Click Event

- (IBAction)doneButtonClick:(id)sender {
    NSString *catName = @"";
    NSLog(@"selected - index = %ld",(long)selectIndex);
    if([catsArray count]>selectIndex)
        catName = [catsArray objectAtIndex:selectIndex];
    [self saveCatridgeName:catName];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableArray *resArray = [[NSMutableArray alloc] init];
    [self catArray:tempArray];
    [self updateCatArray:tempArray NewVal:catName NewArray:resArray];
    [self changeCatTable:resArray];

    //[self gotoScreen:SCREEN_DOSAGETRACKER];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(gotoDosageScheduler) userInfo:nil repeats:NO];

}

-(void) gotoDosageScheduler
{
    [self gotoScreen:SCREEN_DOSAGESCHEDULER];
}

- (IBAction)addButtonClick:(id)sender {
    sendMode = SEND_CATRIDGE_ADDMODE;
    [self performSegueWithIdentifier:@"segueEditCatridge" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)homeButtonClick:(id)sender {
    [self gotoScreen:SCREEN_HOME];
}
- (IBAction)dosageSchedulerButtonClick:(id)sender {
    [self gotoScreen:SCREEN_DOSAGESCHEDULER];
}
- (IBAction)yourESPButtonClick:(id)sender {
    [self gotoScreen:SCREEN_YOURESP];
}
- (IBAction)dosageTrackerButtonClick:(id)sender {
    [self gotoScreen:SCREEN_DOSAGETRACKER];
}
- (IBAction)selectCatridgeButtonClick:(id)sender {
      [_mMenuView setHidden:YES];
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
    NSLog(@"SC selectScreenIndex : %d", selectScreenIndex);
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)menuButtonClick:(id)sender {
    [_mMenuView setHidden:NO];
}
- (IBAction)childSafetyButtonClick:(id)sender {
    [_mChildSafetyView setHidden:NO];
}

- (IBAction)childSafetyOffButtonClick:(id)sender {
    NSLog(@"Off Button Click");
    Byte data[1];
    data[0] = 3;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:1];
    [self sendBLEData:cmdData];
    childSafetyValue = CHILD_SAFETY_OFF;
    [self changeChildSafetyButtonImage:childSafetyValue];
}

- (IBAction)childSafetyOnButtonClick:(id)sender {
    NSLog(@"On Button Click");
    Byte data[1];
    data[0] = 0;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:1];
    [self sendBLEData:cmdData];
    childSafetyValue = CHILD_SAFETY_ON;
    [self changeChildSafetyButtonImage:childSafetyValue];
}


#pragma mark - Save/Get
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
    if(result == nil || [result isEqualToString:@""])
        result = defaultCatridgeName;
    NSLog(@"result = %@", result);
    return result;
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
    
    NSLog(@"result = %@", result);
    return result;
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

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (catsArray == nil)
        return 0;
    return [catsArray count];    //count of section
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
    
    NSString *catName = (NSString*)[catsArray objectAtIndex:indexPath.section];
    cell.textLabel.text = catName;
    
    if(selectIndex == indexPath.section)
    {
        cell.textLabel.textColor= [UIColor blackColor];//[UIColor yellowColor];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20.0f];
    }
    else
    {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:18.0f];
    }
    //cell.detailTextLabel.text= [dev.identifier UUIDString];
    //cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    UIImage *cartImg = [self getImage:catName];
    
    [cell.imageView setImage:cartImg];
    //UIImageView *myView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"devicepen"]];
    UIButton *infoButton=nil;
    if(selectIndex == indexPath.section)
    {
        infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        [infoButton setImage:[UIImage imageNamed:@"sel_cat"] forState:UIControlStateNormal];
        [infoButton setImage:[UIImage imageNamed:@"sel_cat_high"] forState:UIControlStateHighlighted];
        infoButton.tag = 200 + indexPath.section;
        [infoButton addTarget:self action:@selector(didInfoClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView  = infoButton;

    }
    else
    {
        infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [infoButton setImage:[UIImage imageNamed:@"infocat"] forState:UIControlStateNormal];
        [infoButton setImage:[UIImage imageNamed:@"infocat_high"] forState:UIControlStateHighlighted];
        infoButton.tag = 200 + indexPath.section;
        [infoButton addTarget:self action:@selector(didInfoClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView  = infoButton;
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    [tableView setBackgroundView:nil];
    [tableView setBackgroundColor:[UIColor clearColor]];
    return cell;
}

-(IBAction)didInfoClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    int tag =(int) btn.tag;
    if(tag - 200 < [catsArray count])
    {
        sendCatName = [catsArray objectAtIndex:tag-200];
    }
    if([sendCatName isEqualToString:defaultCatridgeName])
        sendMode = SEND_CATRIDGE_DEFAULT;
    else
        sendMode = SEND_CATRIDGE_EDITMODE;
    [self performSegueWithIdentifier:@"segueEditCatridge" sender:self];
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
    selectIndex = indexPath.section;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.catTableView reloadData];
    
    [self doneButtonClick:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
        NSString *catName = (NSString*)[catsArray objectAtIndex:indexPath.section];
        [self deleteCartride:catName];
        [catsArray removeObjectAtIndex:indexPath.section];
        [tableView reloadData];
        // tell table to refresh now

        ///////////////////////////////
        NSString *email = [self getSavedEmail];
        
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        [jsonDic setValue:email forKey:@"email"];
        [jsonDic setValue:catName forKey:@"cartridge"];
        [self sendDeleteCartridge:jsonDic];
    }
}

-(void) gotoSelectCatridge
{
    [self gotoScreen:SCREEN_SELECTCATRIDGE];
}

#pragma mark - Load Catridge

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


-(void) loadCatridge
{
    
    [catsArray removeAllObjects];
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    sqlite3_stmt    *statement;
    static sqlite3 *database = nil;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT SampleName FROM catridgeInfo",nil];
        
        const char *query_stmt = [querySQL UTF8String];
        
        //  NSLog(@"Databasae opened = %@", userN);
        
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            int rows = sqlite3_column_int(statement, 0);
            NSLog(@"rows : %d", rows);
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *sampleName = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"cat name : %@", sampleName);
                [catsArray addObject:sampleName];
            }
             sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    
    NSString *catName = [self getSavedCatridgeName];
    for(int i=0; i<[catsArray count]; i++)
    {
        NSString *temp = (NSString*) [catsArray objectAtIndex:i];
        if([temp isEqualToString:catName])
        {
            selectIndex = i;
            break;
        }
    }
    [self.catTableView reloadData];
}

-(void)deleteCartride:(NSString*)cartrideName
{
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    sqlite3_stmt    *statement;
    static sqlite3 *database = nil;
    
    if(sqlite3_open_v2([paths cStringUsingEncoding:NSUTF8StringEncoding], &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"DELETE FROM catridgeInfo WHERE SampleName = '%@'", cartrideName,nil];
        const char *query_stmt51 = [querySQL UTF8String];
        sqlite3_busy_timeout(database, 500);
        char *errMsg;
        if(sqlite3_exec(database, query_stmt51, NULL, NULL, &errMsg) != SQLITE_OK)
            NSLog( @"Delete catridgeInfo: %s, %s", sqlite3_errmsg(database), errMsg );
        
        sqlite3_busy_timeout(database, 100);
        sqlite3_close(database);
    }

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



-(void) catArray:(NSMutableArray*) array
{
    sqlite3_stmt    *statement;
    NSString *val = @"";
    static sqlite3 *database = nil;
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
-(void) changeCatTable:(NSMutableArray*) array
{
    sqlite3_stmt    *statement;
    NSString *cats = @"";
    static sqlite3 *database = nil;

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
                    
                    NSDate *todayDate = [NSDate date]; //Get todays date
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date.
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //Here we can set the format which we need
                    NSString *convertedDateString = [dateFormatter stringFromDate:todayDate];// Here convert date in NSString
                    NSString *currentTime = convertedDateString;
                    
                    
                    
                    NSString *sql1 = [NSString stringWithFormat: @"INSERT INTO CatInf (dt, cats) VALUES('%@','%@');",currentTime, cats];
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

#pragma mark - get/set
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
#pragma mark - WebApi

-(void) sendDeleteCartridge:(NSMutableDictionary*)jsonDic
{
    
    NSString *strName = [self getSavedName];
    if([strName isEqualToString:@"Guest"])
    {
        return;
    }
    
    NSString *SEND_URL = @"http://opuluslabs.com/cartridge_delete.php";
    
    NSURL *url = [NSURL URLWithString:SEND_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
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
            //[self hideProgress];
            if([jDic objectForKey:@"cartridge"])
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

#pragma mark - get Image Info
- (NSString *)getImageName :(NSString*) sampleName
{
    NSArray *paths          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [paths objectAtIndex:0];
    NSString *imgfileName   = [NSString stringWithFormat:@"img_%@_thumb.jpg", sampleName];
    directoryPath = [directoryPath stringByAppendingPathComponent:@"CatridgeImage"];
    NSString *dstPath = [directoryPath stringByAppendingPathComponent:imgfileName];
    
    return dstPath;
}

- (UIImage *)getImage:(NSString*) sampleName
{
    UIImage *userImage = [UIImage imageWithContentsOfFile:[self getImageName:sampleName]];
    return userImage;
}
@end
