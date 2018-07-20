//
//  ProfileViewController.m
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import "ProfileViewController.h"
#import "Const.h"
@interface ProfileViewController ()
{
    int gotoFlag;
    int childFlag;
    
    UIDatePicker *datePicker1;
    UIView *mkView1;
}
@end

@implementation ProfileViewController

NSString *oldUserImageName = @"";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGestureRecogniser:_mMenuView];
    [self addGestureRecogniser:_mChildSafetyView];
    // Do any additional setup after loading the view.
    
    [self changeChildSafetyButtonImage:childSafetyValue];
    
    
    arrHeights=@[@"4 Feet",@"4 Feet 1 Inches",@"4 Feet 2 Inches",@"4 Feet 3 Inches",@"4 Feet 4 Inches",@"4 Feet 5 Inches",@"4 Feet 6 Inches",@"4 Feet 7 Inches",@"4 Feet 8 Inches",@"4 Feet 9 Inches",@"4 Feet 10 Inches",@"4 Feet 11 Inches",@"5 Feet",@"5 Feet 1 Inches",@"5 Feet 2 Inches",@"5 Feet 3 Inches",@"5 Feet 4 Inches",@"5 Feet 5 Inches",@"5 Feet 6 Inches",@"5 Feet 7 Inches",@"5 Feet 8 Inches",@"5 Feet 9 Inches",@"5 Feet 10 Inches",@"5 Feet 11 Inches",@"6 Feet",@"6 Feet 1 Inches",@"6 Feet 2 Inches",@"6 Feet 3 Inches",@"6 Feet 4 Inches",@"6 Feet 5 Inches",@"6 Feet 6 Inches",@"6 Feet 7 Inches",@"6 Feet 8 Inches",@"6 Feet 9 Inches",@"6 Feet 10 Inches",@"6 Feet 11 Inches",@"7 Feet"];
    actoinHeight=[[UIActionSheet alloc] initWithTitle:@"Height" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"4 Feet",@"4 Feet 1 Inches",@"4 Feet 2 Inches",@"4 Feet 3 Inches",@"4 Feet 4 Inches",@"4 Feet 5 Inches",@"4 Feet 6 Inches",@"4 Feet 7 Inches",@"4 Feet 8 Inches",@"4 Feet 9 Inches",@"4 Feet 10 Inches",@"4 Feet 11 Inches",@"5 Feet",@"5 Feet 1 Inches",@"5 Feet 2 Inches",@"5 Feet 3 Inches",@"5 Feet 4 Inches",@"5 Feet 5 Inches",@"5 Feet 6 Inches",@"5 Feet 7 Inches",@"5 Feet 8 Inches",@"5 Feet 9 Inches",@"5 Feet 10 Inches",@"5 Feet 11 Inches",@"6 Feet",@"6 Feet 1 Inches",@"6 Feet 2 Inches",@"6 Feet 3 Inches",@"6 Feet 4 Inches",@"6 Feet 5 Inches",@"6 Feet 6 Inches",@"6 Feet 7 Inches",@"6 Feet 8 Inches",@"6 Feet 9 Inches",@"6 Feet 10 Inches",@"6 Feet 11 Inches",@"7 Feet", nil];
    
    actionGender=[[UIActionSheet alloc] initWithTitle:@"Gender" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Male",@"Female", nil];
    

    
    [self LoadAccount];
    [self progressInit];
    [self initBirthDatePicker];
    [self initImageProcess];
    
    _imgUser.layer.backgroundColor = [[UIColor clearColor] CGColor];
    _imgUser.layer.cornerRadius = 75;
    _imgUser.layer.borderWidth = 1;
    _imgUser.clipsToBounds = true;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet==actionGender){
        if(buttonIndex==0)
            _txtSex.text=@"Male";
        if(buttonIndex==1)
            _txtSex.text=@"Female";
    } else if(actionSheet==actoinHeight){
        if(buttonIndex<arrHeights.count){
            _txtHeight.text=[arrHeights objectAtIndex:buttonIndex];
        }
    }
}

- (void)LoadAccount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = @"";
    value = [defaults objectForKey:KEY_FIRSTNAME];
    if( value == nil )
        value = @"";
    
    NSString *temp = [defaults objectForKey:KEY_LASTNAME];
    if(temp != nil)
    {
        value =[value stringByAppendingString:@" "];
        value = [value stringByAppendingString:temp];
    }
    
    if( value == nil )
        value = @"";
    
    [_lblUsername setText:value];
    
    value = [defaults objectForKey:KEY_GENDER];
    if( value == nil )
        value = @"";
    
    [_txtSex setText:value];
    
    
    value = [defaults objectForKey:KEY_BIRTH];
    if( value == nil )
        value = @"";
    
    [_txtDOB setText:value];
    
    NSString *weight = [defaults objectForKey:KEY_WEIGHT];
    weight = [weight stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    [_txtWeight setText:[NSString stringWithFormat:@"%@", weight]];
    
    NSString *height = [defaults objectForKey:KEY_HEIGHT];
    height = [height stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    [_txtHeight setText:[NSString stringWithFormat:@"%@", height]];
}


-(void) initImageProcess
{
    NSString *userName = [self getSavedName];
    NSString *filePath = [self getUserImageName:userName];
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSLog(@"\nfilePath : %@ \n", filePath);
    if([fm fileExistsAtPath:filePath isDirectory:nil])
    {
        _imgUser.image = [self getImage:userName];
        oldUserImageName = userName;
    }
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

-(void)addGestureRecogniser:(UIView *)touchView{
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maskViewTouch)];
    [touchView addGestureRecognizer:singleTap];
}
-(void)maskViewTouch{
    [_mMenuView setHidden:YES];
    [_mChildSafetyView setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DisconnectEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ReadBatteryValueChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotiValueChange object:nil];
   
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bleNotification:)
                                                 name:NotiValueChange
                                               object:nil];
    
     if(getImageStatus == true)
     {
         UIImage *image = [self getImage:defaultUserImageName];
         if(image != nil)
         {
             _imgUser.image = image;
             oldUserImageName = defaultUserImageName;
             getImageStatus = false;
         }

     }
    
    [_lblBatteryLevel setText:[NSString stringWithFormat:@"%d %%",batteryLevel]];
    [self setBattery:batteryLevel];
     [_lblCoinValue setText:[NSString stringWithFormat:@"%d coins",coinValue]];
}

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
    [self gotoScreen:SCREEN_SELECTCATRIDGE];
}
- (IBAction)profileButtonClick:(id)sender {
    [_mMenuView setHidden:YES];
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
    [self sendBLEData:cmdData];
}

- (IBAction)childSafetyOnButtonClick:(id)sender {
    NSLog(@"On Button Click");
    Byte data[3];
    data[0] = 0xA1;
    data[1] = 1;
    data[2] = 0;
    NSData *cmdData = [[NSData alloc] initWithBytes:data length:3];
    [self sendBLEData:cmdData];
}


- (IBAction)cameraButtonClick:(id)sender {
    getImageStatus = false;
    
    UIImage *image = [self getImage:oldUserImageName];
    if(image != nil && ![oldUserImageName isEqualToString:@""])
    {
        NSString *filePath1 = [self getUserImageName:defaultUserImageName];
        NSString *filePath2 = [self getUserImageName:oldUserImageName];
        
        NSFileManager * fm = [[NSFileManager alloc] init];
        NSError *err;
        if([fm fileExistsAtPath:filePath2 isDirectory:nil])
        {
            Boolean res = [fm copyItemAtPath:filePath2 toPath:filePath1 error:&err];
            if(res == false)
                NSLog(@"Error:%@", err);
        }
    }
   [self performSegueWithIdentifier:@"segueSelectImage" sender:self];
}

- (IBAction)fillOutButtonClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fillOutURL]];
}


- (IBAction)saveButtonClick:(id)sender
{
    UIImage *image = [self getImage:oldUserImageName];
    NSString *samName = [self getSavedName];
    if(image != nil && ![oldUserImageName isEqualToString:@""])
    {
        if([samName isEqualToString: oldUserImageName])
            return;
        
        NSString *filePath1 = [self getUserImageName:samName];
        NSString *filePath2 = [self getUserImageName:oldUserImageName];
        NSLog(@"\nfilePath1:%@, filePath2:%@\n", filePath1, filePath2);
        NSFileManager * fm = [[NSFileManager alloc] init];
        NSError *err;
        
        if([fm fileExistsAtPath:filePath1 isDirectory:nil])
        {
            [fm removeItemAtPath:filePath1 error:&err];
            NSLog(@"Remove file (add data):%@", filePath1);
        }
        
        if([fm fileExistsAtPath:filePath2 isDirectory:nil])
        {
            Boolean res = [fm moveItemAtPath:filePath2 toPath:filePath1 error:&err];
            if(res == false)
                NSLog(@"Error:%@", err);
            [fm removeItemAtPath:filePath2 error:&err];
            NSLog(@"Remove file (add data):%@", filePath2);
        }
    }
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email;
    email = [defaults objectForKey:KEY_EMAIL];
    if( email == nil )
        email = @"";
    
    NSString *sex = _txtSex.text;
    NSString *dob = _txtDOB.text;
    NSString *weight = _txtWeight.text;
    NSString *height = _txtHeight.text;
    
    if([sex length]<1)
    {
        [self showToastLong:@"Please input gender information."];
        return;
    }
    
    if([dob length] != 10)
    {
        [self showToastLong:@"Date Input Error"];
        return;
    }
    
    NSString *strName = [self getSavedName];
    
    if([strName isEqualToString:@"Guest"])
    {
        [self homeButtonClick:nil];
        return;
    }
    
    NSString *SEND_URL = @"http://opuluslabs.com/user_modify.php";
    
    NSURL *url = [NSURL URLWithString:SEND_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    [jsonDic setValue:email forKey:@"email"];
    [jsonDic setValue:sex forKey:@"gender"];
    [jsonDic setValue:dob forKey:@"date"];
    [jsonDic setValue:height forKey:@"height"];
    [jsonDic setValue:weight forKey:@"weight"];
    
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
        NSDictionary *jDic = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
        NSLog(@"Update reply: %@", jDic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgress];
            if([jDic objectForKey:@"user"])
            {
                NSDictionary *temp = [jDic objectForKey:@"user"];
                NSString *gener = [temp objectForKey:@"gender"];
                NSString *birth = [temp objectForKey:@"date"];
                NSString * height =[temp objectForKey:@"height"];
                NSString * weight =[temp objectForKey:@"weight"];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:sex forKey:KEY_GENDER];
                [defaults setObject:dob forKey:KEY_BIRTH];
                [defaults setObject:height forKey:KEY_HEIGHT];
                [defaults setObject:weight forKey:KEY_WEIGHT];
                [self dosageTrackerButtonClick:nil];
                
            }
            else if([jDic objectForKey:@"error_msg"])
            {
                [self showToastLong:[jDic objectForKey:@"error_msg"]];
            }
        });
    }] resume];
}



#pragma mark - Save/Get function
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

-(void)bleNotification:(NSNotification*)noti
{
    NSData *receivedData = (NSData*)(noti.object);
    NSLog(@"Profile - Read Value - %@",receivedData);
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

#pragma mark - text filed event
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect frame = _viewMainBack.frame;
    if(textField !=_txtSex && textField !=_txtHeight && textField !=_txtDOB){
        if (frame.origin.y > -100)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.35];
            frame.origin.y = -150;
            _viewMainBack.frame = frame;
            [UIView commitAnimations];
        }
    }
    
    if(textField==_txtSex){
        [textField resignFirstResponder];
        [self.txtHeight resignFirstResponder];
        [self.txtDOB resignFirstResponder];
        [self.txtWeight resignFirstResponder];
        [actionGender showInView:self.view];
        return false;
    } else if (textField==_txtHeight){
        [textField resignFirstResponder];
        [self.txtSex resignFirstResponder];
        [self.txtDOB resignFirstResponder];
        [self.txtHeight resignFirstResponder];
        [self.txtWeight resignFirstResponder];
        
        [actoinHeight showInView:self.view];
        return false;
        
    }

    return true;// return [super textFieldShouldBeginEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGRect frame = _viewMainBack.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    frame.origin.y = 0;
    _viewMainBack.frame = frame;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return true;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return true;
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

#pragma mark - select time
-(void) initBirthDatePicker
{
    datePicker1 = [[UIDatePicker alloc]init];
    
    NSDate* result;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:(NSInteger)(1970)];
    [comps setMonth:1];
    [comps setDay:1];
    NSCalendar *gre = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    result = [gre dateFromComponents:comps];
    [datePicker1 setDate:result];
    datePicker1.datePickerMode = UIDatePickerModeDate;
    [datePicker1 addTarget:self action:@selector(dateTextField:) forControlEvents:UIControlEventValueChanged];
    
    [_txtDOB setInputView:datePicker1];
    
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    [_txtDOB setInputAccessoryView:toolBar];
    
}


-(void) dateTextField:(id)sender
{
    
}

-(void) ShowSelectedDate
{
    UIDatePicker *picker = (UIDatePicker*)_txtDOB.inputView;
    //UIToolbar *toolbar = (UIToolbar*)_txtDosageTime.inputAccessoryView;
    [picker setMaximumDate:[NSDate date]];
    //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:units fromDate:eventDate];
    
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    _txtDOB.text = [NSString stringWithFormat:@"%04d-%02d-%02d",(int)year, (int)month, (int)day];
    [_txtDOB resignFirstResponder];
}
@end
