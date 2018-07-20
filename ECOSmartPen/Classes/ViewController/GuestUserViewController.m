//
//  GuestUserViewController.m
//  ECOSmartPen
//
//  Created by apple on 9/15/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import "GuestUserViewController.h"
#import "Const.h"
@interface GuestUserViewController ()

@end

@implementation GuestUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGestureRecogniser:_mMenuView];
    [self addGestureRecogniser:_mChildSafetyView];
    // Do any additional setup after loading the view.
    
    [self changeChildSafetyButtonImage:childSafetyValue];
    
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
    [self gotoScreen:SCREEN_PROFILE];
}

- (IBAction)guestUserButtonClick:(id)sender {
    [_mMenuView setHidden:YES];
}

- (IBAction)logoutButtonClick:(id)sender {
    [self gotoScreen:SCREEN_LOGOUT];
}


-(void) gotoScreen:(int) index
{
    switch(index)
    {
        case SCREEN_YOURESP:
            selectScreenIndex = SCREEN_YOURESP;
            break;
        case SCREEN_DOSAGESCHEDULER:
            selectScreenIndex = SCREEN_DOSAGESCHEDULER;
            break;
        case SCREEN_DOSAGETRACKER:
            selectScreenIndex = SCREEN_NONE;
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
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)saveButtonClick:(id)sender {
    NSLog(@"Save Button Click");
    
    NSString *old = [self getGuestPwd];
    NSString *str = _txtOldPwd.text;
    
    if([str isEqualToString:old] == false)
    {
        [self showToastShort:@"Old Password incorrect."];
        return;
    }
    else if([_txtPwd.text length] < 6)
    {
        [self showToastShort:@"Pasword should be between 6 to 30 characters."];
        return;
    }
    else if ([_txtPwd.text isEqualToString:_txtConfirmPwd.text] == false)
    {
        [self showToastShort:@"Password does not match."];
        return;
    }
    
    [self saveGuestPwd:_txtPwd.text];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Save/Get function
-(void)saveGuestPwd:(NSString*)pwd
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:pwd forKey:@"guest_pwd"];
        [standardUserDefaults synchronize];
    }
}


-(NSString*)getGuestPwd
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"";
    if (standardUserDefaults) {
        if([standardUserDefaults valueForKey:@"guest_pwd"] == nil)
            result = @"";
        else
            result=(NSString*)[standardUserDefaults valueForKey:@"guest_pwd"];
    }
    
    NSLog(@"result = %@", result);
    return result;
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
            break;
        case CHILD_SAFETY_OFF:
            [_childSafetyButton setImage:[UIImage imageNamed:@"child_off_btn"] forState:UIControlStateNormal];
            [_childSafetyButton setImage:[UIImage imageNamed:@"childsafetyoff_high"] forState:UIControlStateHighlighted];
            [_childSafetyButton setEnabled:true];
            break;
    }
}
#pragma mark - text filed event
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}
@end
