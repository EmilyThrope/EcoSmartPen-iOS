//
//  LoginViewController.m
//  SmartHub
//
//  Created by Anaconda on 11/25/14.
//  Copyright (c) 2014 Panda. All rights reserved.
//

#import "LoginViewController.h"
#import "Utility.h"
#import "Const.h"

#define KEY_SERVERIP        @"ServerIP"
#define KEY_SERVERPORT      @"ServerPort"
#define KEY_REMEMBER        @"Remember"


#define CMD_LOGIN       1

@interface LoginViewController ()
{
    Byte        mCurrecntCmd;
}
@end

@implementation LoginViewController
@synthesize HUD;
@synthesize mProgressLabel;
@synthesize maskView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mUserName.text = @"";
    mPassword.text = @"";
    
    [self InitVariables];
    [self CreateFolder];
    [self progressInit];
    
}

- (void)CreateFolder
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *paths          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [paths objectAtIndex:0];
    NSString *folderPath = [directoryPath stringByAppendingPathComponent:@"UserImage"];
    
    [fileMgr createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *folderPath2 = [directoryPath stringByAppendingPathComponent:@"CatridgeImage"];
    
    [fileMgr createDirectoryAtPath:folderPath2 withIntermediateDirectories:YES attributes:nil error:nil];
    
    folderPath = [directoryPath stringByAppendingPathComponent:@"DoorImage"];
    
    [fileMgr createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)LoadAccount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *value;
    
    BOOL bvalue = YES;// [[defaults objectForKey:KEY_REMEMBER] boolValue];
    
    mIsRemember = bvalue;
    value = [defaults objectForKey:KEY_EMAIL];
    if( value == nil )
        value = @"";
    if( !mIsRemember )
        value = @"";
    
    [mUserName setText:value];
    value = [defaults objectForKey:KEY_PASSWORD];
    if( value == nil )
        value = @"";
    if( !mIsRemember )
        value = @"";
    [mPassword setText:value];
}

- (void)SaveAccount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:mUserName.text forKey:KEY_EMAIL];
    [defaults setObject:mPassword.text forKey:KEY_PASSWORD];
    [defaults setObject:[NSNumber numberWithBool:mIsRemember] forKey:KEY_REMEMBER];
}

- (void) InitVariables {
    [self LoadAccount];
    
    mLoginTimer = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    if(gotoLoginFlag == 1)
    {
        [self LoadAccount];
        [self performSegueWithIdentifier:@"segueHome" sender:nil];
        gotoLoginFlag = 0;
    }
}



#pragma mark - Click Buttons


- (IBAction)clickLoginBtn:(id)sender
{
    NSString *username = mUserName.text;
    NSString *password = mPassword.text;
    
    if([username length]<1)
    {
        [self showToastLong:@"Please input user name."];
        return;
    }
    
    if([password length]<1)
    {
        [self showToastLong:@"Please input password."];
        return;
    }
    
    NSString *post =[NSString stringWithFormat:@"password=%@&email=%@",password,username];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postlength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    NSString  *LOGIN_URL = @"http://opuluslabs.com/login.php";
    
    NSURL *url = [NSURL URLWithString:LOGIN_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postlength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [self showProgress];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        NSDictionary *jDic = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
        NSLog(@"Login reply: %@", jDic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgress];
            if([jDic objectForKey:@"user"])
            {
                NSDictionary *temp = [jDic objectForKey:@"user"];
                NSString *gener = [temp objectForKey:@"gender"];
                NSString *birth = [temp objectForKey:@"date"];
                NSString *firstname = [temp objectForKey:@"firstname"];
                NSString *lastname = [temp objectForKey:@"lastname"];
                NSString * height =[temp objectForKey:@"height"];
                NSString * weight =[temp objectForKey:@"weight"];
                NSString * coinStr =[temp objectForKey:@"coin"];
                coinValue = (int)[coinStr integerValue];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:username forKey:KEY_EMAIL];
                [defaults setObject:password forKey:KEY_PASSWORD];
                [defaults setObject:gener forKey:KEY_GENDER];
                [defaults setObject:birth forKey:KEY_BIRTH];
                [defaults setObject:firstname forKey:KEY_FIRSTNAME];
                [defaults setObject:lastname forKey:KEY_LASTNAME];
                [defaults setObject:height forKey:KEY_HEIGHT];
                [defaults setObject:weight forKey:KEY_WEIGHT];
                
                [self performSegueWithIdentifier:@"segueHome" sender:nil];
                
            }
            else if([jDic objectForKey:@"error_msg"])
            {
                [self showToastLong:[jDic objectForKey:@"error_msg"]];
            }
        });
    }] resume];
}


/*- (IBAction)clickLoginBtn:(id)sender
{
    NSString         *LOGIN_URL = @"http://52.39.200.110/api/v1/api-token-auth/";
    NSURL *url = [NSURL URLWithString:LOGIN_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
 
    NSString *username = mUserName.text;
    NSString *password = mPassword.text;
 
    if([username length]<1)
    {
        [self showToastLong:@"Please input user name."];
        return;
    }
    
    if([password length]<1)
    {
        [self showToastLong:@"Please input password."];
        return;
    }
    
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    [jsonDic setValue:username forKey:@"username"];
    [jsonDic setValue:password forKey:@"password"];
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
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        NSDictionary *jDic = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:NULL];
        NSLog(@"Login reply: %@", jDic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgress];
            if([jDic objectForKey:@"name"])
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:username forKey:KEY_USERNAME];
                [defaults setObject:password forKey:KEY_PASSWORD];
                [self performSegueWithIdentifier:@"segueHome" sender:nil];
            }
            else{
                [self showToastLong:@"Login Failed."];
            }
        });
    }] resume];
}*/

- (IBAction)clickGuestBtn:(id)sender
{
    NSString *old = [self getGuestPwd];
    mUserName.text = @"Guest";
    
    if([mPassword.text isEqualToString:old] == false)
    {
        [self showToastShort:@"Password does not match."];
        mPassword.text = @"";
        return;
    }
    
    NSString *res = [self getTourVapePassState];
    if(![res isEqualToString:@"pass"])
    {
        [self performSegueWithIdentifier:@"segueHome" sender:nil];
    }
    else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"Male" forKey:KEY_GENDER];
        [defaults setObject:@"2000-01-01" forKey:KEY_BIRTH];
        [defaults setObject:@"Guest" forKey:KEY_FIRSTNAME];
        [defaults setObject:@" " forKey:KEY_LASTNAME];
        [defaults setObject:@"6 feet" forKey:KEY_HEIGHT];
        [defaults setObject:@"160 lbs" forKey:KEY_WEIGHT];
        [self performSegueWithIdentifier:@"segueHome" sender:nil];
    }
    
}

-(void) loginStartTimer:(NSTimer*) timer
{
    [self cancelProgress];
   /* [mXmppComm disconnect];
    [self showAlert:[Utility NSLocalizedString:@"Window Application is offline."]]; */
}

-(void) cancelProgress
{
    mCurrecntCmd = 0;
//    [super cancelProgress];
    if(mLoginTimer)
    {
        [mLoginTimer invalidate];
        mLoginTimer  = nil;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    {
        CGRect frame = mBackgroundView.frame;
        if (frame.origin.y > -100)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.35];
            frame.origin.y = -130;
            mBackgroundView.frame = frame;
            [UIView commitAnimations];
        }
    }
    return true;// return [super textFieldShouldBeginEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGRect frame = mBackgroundView.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    frame.origin.y = 0;
    mBackgroundView.frame = frame;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return true;
   // return [super textFieldShouldReturn:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return true;
    //return [super textFieldShouldEndEditing:textField];
}

- (void)keyBoardRemove:(id)sender
{
    CGRect frame = mBackgroundView.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    frame.origin.y = 0;
    mBackgroundView.frame = frame;
    [UIView commitAnimations];

   // [super keyBoardRemove:sender];
}

- (void)selectionDidChange:(id<UITextInput>)textInput
{
    
}
- (void) selectionWillChange:(id<UITextInput>)textInput
{
    
}
-(void) textDidChange:(id<UITextInput>)textInput
{
    
}
-(void) textWillChange:(id<UITextInput>)textInput
{
    
}
#pragma mark - RFC3920 Encode

- (NSString *)getEncodeString:(NSString*)toEncodeString
{
    NSMutableData *stringData = [[NSMutableData alloc] init];
    NSData *toEncodeData = [toEncodeString dataUsingEncoding:NSUTF8StringEncoding];
    Byte *toEncodeByte = (Byte*)[toEncodeData bytes];
    Byte aBytes[2];
    
    for( int i = 0; i < [toEncodeData length]; i++ ){
        aBytes[0] = (toEncodeByte[i] % 26) + 0x61;
        aBytes[1] = (toEncodeByte[i] / 26) + 0x61;
        [stringData appendBytes:aBytes length:2];
    }
    
    NSString *encodeString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    
    return encodeString;
}

#pragma mark - others
- (void)showAlert:(NSString*)msg
{
    /*[self showAlertMessage:msg withOkButton:[Utility NSLocalizedString:@"OK"] withCancelButton:nil withTag:0];*/
}

#pragma mark - Get/Save function
-(void)saveTourVapePassState:(Boolean)status
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString* saveStatus = status==true?@"pass":@"first";
    if (standardUserDefaults) {
        [standardUserDefaults setObject:saveStatus forKey:@"vape_tour"];
        [standardUserDefaults synchronize];
    }
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
