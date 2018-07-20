//
//  YourESPViewController.m
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import "YourESPViewController.h"
#import "Const.h"

@interface YourESPViewController ()
{
    NSMutableArray  *deviceArray;
    CBPeripheral    *device;
    int             gotoFlag;
    int             childFlag;
}
@end

@implementation YourESPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGestureRecogniser:_mMenuView];
    [self addGestureRecogniser:_mChildSafetyView];
    // Do any additional setup after loading the view.
    
    [self.tblView setBackgroundView:nil];
    [self.tblView setBackgroundColor:[UIColor clearColor]];
    [self.tblView setSeparatorColor:[UIColor clearColor]];
    
    deviceArray =  [[NSMutableArray alloc] init];
    
    [self progressInit];
    
    if([[self getSavedConnectStatus] isEqualToString:@"connect"])
    {
        [_vwWorkStation setHidden:YES];
        [_tblDevices setHidden:NO];
        [_searchBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
        [_lblMyDevice setText:[self getSavedDeviceName]];
    }
    else
    {
        [_vwWorkStation setHidden:NO];
        [_tblDevices setHidden:YES];
        [_searchBtn setTitle:@"Search" forState:UIControlStateNormal];
    }
    

    gotoFlag = 0;
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
    maskView.alpha = 0.6;
    
    mProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 50, ScreenHeight/2 + 40, 100, 30)];
    mProgressLabel.text = @"";
    mProgressLabel.textAlignment = NSTextAlignmentCenter;
    mProgressLabel.textColor = [UIColor whiteColor];
    //mProgressLabel.backgroundColor = [UIColor greenColor];

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotiValueChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ReadBatteryValueChange object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(scanDevices) userInfo:nil repeats:NO];
    [self changeChildSafetyButtonImage:childSafetyValue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleDisconnected:)
                                                 name:DisconnectEvent
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleReadBatteryValue:)
                                                 name:ReadBatteryValueChange
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleNotification:)
                                                 name:NotiValueChange
                                               object:nil];
    [_lblBatteryLevel setText:[NSString stringWithFormat:@"%d %%",batteryLevel]];
    [self setBattery:batteryLevel];
     [_lblCoinValue setText:[NSString stringWithFormat:@"%d coins",coinValue]];
}

-(void) scanDevices
{
     if([[self getSavedConnectStatus] isEqualToString:@"disconnect"])
     {
         [self showProgress:@"Searching for your ESP..."];
         [mBLEComm startScanDevicesWithInterval:2.5 CompleteBlock:^(NSArray *devices)
          {
              [deviceArray removeAllObjects];
              for (CBPeripheral *per in devices)
              {
                  if([per.name containsString:@"VAPE"])
                  {
                      if(![deviceArray containsObject:per])
                          [deviceArray addObject:per];
                      NSLog(@"address %@",[per.identifier UUIDString]);
                  }
              }
              if([deviceArray count]>0)
                  device = [deviceArray objectAtIndex:0];
              [self.tblView reloadData];
              [self hideProgress];
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
}




#pragma mark - Button Event


- (IBAction)searchButtonClick:(id)sender {
    NSString *buttonName = _searchBtn.currentTitle;
    
    [self showProgress:@"Searching for your ESP..."];
    if([buttonName isEqualToString:@"Disconnect"])
    {
        [mBLEComm disconnectionDevice];
        [self saveDeviceName:@""];
        [self saveDeviceAddress:@""];
        [self saveConnectStatus:NO];
        if(childSafetyValue > 1)
            childSafetyValue -=2;
        [self changeChildSafetyButtonImage:childSafetyValue];
        sleep(1.0);
        [_tblDevices setHidden:YES];
        [_vwWorkStation setHidden:NO];
        [_searchBtn setTitle:@"Search" forState:UIControlStateNormal];
        [mBLEComm startScanDevicesWithInterval:1.5 CompleteBlock:^(NSArray *devices)
         {
             [deviceArray removeAllObjects];
             for (CBPeripheral *per in devices)
             {
                 if([per.name containsString:@"VAPE"])
                 {
                     if(![deviceArray containsObject:per])
                         [deviceArray addObject:per];
                 }
             }
             if([deviceArray count]>0)
                 device = [deviceArray objectAtIndex:0];
             [self hideProgress];
             [self.tblView reloadData];
         }];
    }
    else if([buttonName isEqualToString:@"Search"])
    {
        [mBLEComm startScanDevicesWithInterval:1.5 CompleteBlock:^(NSArray *devices)
         {
             [deviceArray removeAllObjects];
             for (CBPeripheral *per in devices)
             {
                 if([per.name containsString:@"VAPE"])
                 {
                     if(![deviceArray containsObject:per])
                         [deviceArray addObject:per];
                     NSLog(@"address %@",[per.identifier UUIDString]);
                 }
             }
             if([deviceArray count]>0)
                 device = [deviceArray objectAtIndex:0];
             [self.tblView reloadData];
             [self hideProgress];
         }];
    }
}


- (IBAction)homeButtonClick:(id)sender {
    [self gotoScreen:SCREEN_HOME];
}
- (IBAction)dosageSchedulerButtonClick:(id)sender {
    [self gotoScreen:SCREEN_DOSAGESCHEDULER];
}
- (IBAction)yourESPButtonClick:(id)sender {
       [_mMenuView setHidden:YES];
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
    NSLog(@"YourESP selectScreenIndex : %d", selectScreenIndex);
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)menuButtonClick:(id)sender {
    [_mMenuView setHidden:NO];
}
- (IBAction)childSafetyButtonClick:(id)sender {
    //[_mChildSafetyView setHidden:NO];
    if(childFlag == 0)
    {
        [self childSafetyOffButtonClick:nil];
    }
    else
    {
        [self childSafetyOnButtonClick:nil];
    }
}

- (IBAction)childSafetyOffButtonClick:(id)sender {
    NSLog(@"Off Button Click");
    Byte data[3];
    data[0] = 0xA1;
    data[1] = 1;
    data[2] = 1;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:3];
    gotoFlag = 1;
    [self sendBLEData:cmdData];
}

- (IBAction)childSafetyOnButtonClick:(id)sender {
    NSLog(@"On Button Click");
    Byte data[3];
    data[0] = 0xA1;
    data[1] = 1;
    data[2] = 0;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:3];
    gotoFlag = 1;
    [self sendBLEData:cmdData];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (deviceArray == nil)
        return 0;
    return [deviceArray count];    //count of section
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
    
    CBPeripheral *dev = (CBPeripheral*)[deviceArray objectAtIndex:indexPath.section];
    
    NSString *deviceName = [dev name];
    deviceName = [deviceName stringByReplacingOccurrencesOfString:@"VAPE" withString:@"ECO"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"\t\t%@", deviceName];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20.0];
   
    [cell.imageView setImage:[UIImage imageNamed:@"ble_img"]];
    //UIImageView *myView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ble_img"]];
    //cell.accessoryView  = myView;
   
    
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
    selectIndex = indexPath.section;
    device = [deviceArray objectAtIndex:indexPath.section];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showProgress:@"Connecting..."];
    NSString* address = [device.identifier UUIDString];
    NSLog(@"connect addr:%@",address);
    [mBLEComm connectionWithDeviceUUID:address TimeOut:3 CompleteBlock:^(CBPeripheral *device_new, NSError *err)
     {
         if (device_new)
         {
             NSLog(@"Discovery servicess...");
             [mBLEComm discoverServiceAndCharacteristicWithInterval:3 CompleteBlock:^(NSArray *serviceArray, NSArray *characteristicArray, NSError *err)
              {
                  [mBLEComm setNotificationForCharacteristicWithServiceUUID:@"AAA0" CharacteristicUUID:@"AAA5" enable:YES];
                  sleep(0.1);
                  [mBLEComm setNotificationForCharacteristicWithServiceUUID:@"180F" CharacteristicUUID:@"2A19" enable:YES];
                  
                  NSLog(@"Device Connected");
                  gotoFlag = 0;
                  [self readChildSafetyState];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      
                      NSString *deviceName = device.name;
                      deviceName =  [deviceName stringByReplacingOccurrencesOfString:@"VAPE" withString:@"ECO"];
                      [_tblDevices setHidden:NO];
                      [_vwWorkStation setHidden:YES];
                      [_lblMyDevice setText:deviceName];
                      [self saveDeviceName:deviceName];
                      [self saveDeviceAddress:address];
                      [self saveConnectStatus:YES];
                      [_searchBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
                  });
             }];
         }
         else
         {
             NSLog(@"Connect device failed.");
             [self hideProgress];
         }
     }];

}


#pragma mark - Progress methods
- (void)showProgress:(NSString*) str
{
    //mProgressLabel.text = str;
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

#pragma Save Device Name

-(void)saveDeviceName:(NSString*)myDev
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:myDev forKey:@"device_name"];
        [standardUserDefaults synchronize];
    }
}

-(void)saveDeviceAddress:(NSString*)myDevAddr
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:myDevAddr forKey:@"device_address"];
        [standardUserDefaults synchronize];
    }
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

-(NSString*)getSavedDeviceName
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"abc";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:@"device_name"];
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

-(NSString*)getSavedConnectStatus
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"abc";
    if (standardUserDefaults) {
             result=(NSString*)[standardUserDefaults valueForKey:@"connect_status"];
         }
    return result;
}
#pragma mark - Bluetooth Send

-(void) sendBLEData:(NSData*) data
{
    [mBLEComm sendCommand:data ServiceUUID:@"AAA0" CharacteristicUUID:@"AAA1"];
}
#pragma mark - Bluetooth Read

-(void) readChildSafetyState
{
    NSLog(@"Call readChildSafety");
    Byte data[2];
    data[0] = 0xA0;
    data[1] = 0;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:2];
    [self sendBLEData:cmdData];
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

-(void)bleNotification:(NSNotification*)noti
{
    NSData *receivedData = (NSData*)(noti.object);
    NSLog(@"YourESP - Read Value - %@",receivedData);
    if([receivedData length]<3)
        return;
    
    Byte *message = (Byte *)[receivedData bytes];
    int val = message[2];
    if(message[0] == 0xA1)
    {
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
        childFlag = val;
        [self hideProgress];
        if(gotoFlag == 0)
        {
            [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(gotoSelectCatridge) userInfo:nil repeats:NO];
        }
    }
}

-(void) gotoSelectCatridge
{
    [self gotoScreen:SCREEN_SELECTCATRIDGE];
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
    [self hideProgress];
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
    hud.backgroundColor = [UIColor greenColor];
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
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_off_btn"] forState:UIControlStateHighlighted];
            [_childSafetyButton setEnabled:true];
            _lblChildOn.font = [UIFont boldSystemFontOfSize:22.0];
            _lblChildOff.font = [UIFont systemFontOfSize:20.0];
            break;
        case CHILD_SAFETY_OFF:
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_off_btn"] forState:UIControlStateNormal];
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_on_btn"] forState:UIControlStateHighlighted];
            [_childSafetyButton setEnabled:true];
            _lblChildOff.font = [UIFont boldSystemFontOfSize:22.0];
            _lblChildOn.font = [UIFont systemFontOfSize:20.0];
            break;
    }
}





@end
