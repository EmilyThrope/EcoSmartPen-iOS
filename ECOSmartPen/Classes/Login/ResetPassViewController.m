//
//  LoginViewController.m
//  SmartHub
//
//  Created by Anaconda on 11/25/14.
//  Copyright (c) 2014 Panda. All rights reserved.
//

#import "ResetPassViewController.h"
#import "Utility.h"
#import "Const.h"

#define KEY_SERVERIP        @"ServerIP"
#define KEY_SERVERPORT      @"ServerPort"
#define KEY_REMEMBER        @"Remember"


#define CMD_LOGIN       1

@interface ResetPassViewController ()
{
    Byte        mCurrecntCmd;
}
@end

@implementation ResetPassViewController
@synthesize HUD;
@synthesize mProgressLabel;
@synthesize maskView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _txtEmail.text = @"";
    
    [self progressInit];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}



#pragma mark - Click Buttons
- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSubmitBtn:(id)sender
{
    NSString *username = _txtEmail.text;
    
    if([username length]<1)
    {
        [self showToastLong:@"Please input email address."];
        return;
    }
    
    
    NSString *myMail = username;
    
    NSString *SEND_URL = @"http://opuluslabs.com/password_reset.php";
    NSURL *url = [NSURL URLWithString:SEND_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    [jsonDic setValue:myMail forKey:@"email"];
    
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
            if([[jDic objectForKey:@"error"] intValue] == 0)
            {
                /*NSDictionary *temp = [jDic objectForKey:@"result"];
                NSString *linkAddress = [temp objectForKey:@"link"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkAddress]];*/
                [self showToastLong:@"Please check your mail"];
                 [self.navigationController popViewControllerAnimated:YES];
            }
            else if([jDic objectForKey:@"error_msg"])
            {
                [self showToastLong:[jDic objectForKey:@"error_msg"]];
            }
            else
            {
                [self showToastLong:@"Please input correct email"];
            }
        });
    }] resume];
}



-(void) loginStartTimer:(NSTimer*) timer
{
    [self cancelProgress];
   
}

-(void) cancelProgress
{
    mCurrecntCmd = 0;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;// return [super textFieldShouldBeginEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
   // return [super textFieldShouldReturn:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
    //return [super textFieldShouldEndEditing:textField];
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
