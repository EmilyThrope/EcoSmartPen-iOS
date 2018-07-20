//
//  SignUpViewController.m
//  ECOSmartPen
//
//  Created by apple on 8/7/17.
//  Copyright © 2017 mac. All rights reserved.
//


#import "SignUpViewController.h"
#import "Const.h"
#import "PopoverViewController.h"
#import "UIPopoverController+iPhone.h"

@interface SignUpViewController ()
{
    PopoverViewController *viewPopController;
    UIPopoverController *popover;
    UIDatePicker *datePicker1;
    UIView *mkView1;
}

@property (weak, nonatomic) IBOutlet CalendarView *calenView;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrHeights=@[@"4 Feet",@"4 Feet 1 Inches",@"4 Feet 2 Inches",@"4 Feet 3 Inches",@"4 Feet 4 Inches",@"4 Feet 5 Inches",@"4 Feet 6 Inches",@"4 Feet 7 Inches",@"4 Feet 8 Inches",@"4 Feet 9 Inches",@"4 Feet 10 Inches",@"4 Feet 11 Inches",@"5 Feet",@"5 Feet 1 Inches",@"5 Feet 2 Inches",@"5 Feet 3 Inches",@"5 Feet 4 Inches",@"5 Feet 5 Inches",@"5 Feet 6 Inches",@"5 Feet 7 Inches",@"5 Feet 8 Inches",@"5 Feet 9 Inches",@"5 Feet 10 Inches",@"5 Feet 11 Inches",@"6 Feet",@"6 Feet 1 Inches",@"6 Feet 2 Inches",@"6 Feet 3 Inches",@"6 Feet 4 Inches",@"6 Feet 5 Inches",@"6 Feet 6 Inches",@"6 Feet 7 Inches",@"6 Feet 8 Inches",@"6 Feet 9 Inches",@"6 Feet 10 Inches",@"6 Feet 11 Inches",@"7 Feet"];
    actoinHeight=[[UIActionSheet alloc] initWithTitle:@"Height" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"4 Feet",@"4 Feet 1 Inches",@"4 Feet 2 Inches",@"4 Feet 3 Inches",@"4 Feet 4 Inches",@"4 Feet 5 Inches",@"4 Feet 6 Inches",@"4 Feet 7 Inches",@"4 Feet 8 Inches",@"4 Feet 9 Inches",@"4 Feet 10 Inches",@"4 Feet 11 Inches",@"5 Feet",@"5 Feet 1 Inches",@"5 Feet 2 Inches",@"5 Feet 3 Inches",@"5 Feet 4 Inches",@"5 Feet 5 Inches",@"5 Feet 6 Inches",@"5 Feet 7 Inches",@"5 Feet 8 Inches",@"5 Feet 9 Inches",@"5 Feet 10 Inches",@"5 Feet 11 Inches",@"6 Feet",@"6 Feet 1 Inches",@"6 Feet 2 Inches",@"6 Feet 3 Inches",@"6 Feet 4 Inches",@"6 Feet 5 Inches",@"6 Feet 6 Inches",@"6 Feet 7 Inches",@"6 Feet 8 Inches",@"6 Feet 9 Inches",@"6 Feet 10 Inches",@"6 Feet 11 Inches",@"7 Feet", nil];
    
    actionGender=[[UIActionSheet alloc] initWithTitle:@"Gender" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Male",@"Female", nil];
    
    [self progressInit];
    [self initBirthDatePicker];
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
bool isLoging = NO;
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    if(isLoging)
    {
        [self.navigationController popViewControllerAnimated:YES];
        isLoging = NO;
    }
}
- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)createAccountButtonClick:(id)sender {
    
    NSString *lastname = _txtName.text;
    NSString *firstname = _txtUsername.text;
    NSString *password = _txtPassword.text;
    NSString *confirm  = _txtConfirm.text;
    NSString *email = _txtEmail.text;
    NSString *sex = _txtSex.text;
    NSString *birth = _txtBirth.text;
    //int weight = [_txtWeight.text intValue];
    NSString *height = _txtHeight.text;
    NSString *weight = _txtWeight.text;
    /*if([username length]<1)
    {
        [self showToastLong:@"Please input user name."];
        return;
    }
    
    if([username length]<6)
    {
        [self showToastLong:@"Username should be between 6 to 30 characters."];
        return;
    }*/
    
    if([email length]<1)
    {
        [self showToastLong:@"Please input email address."];
        return;
    }
    
    if([password length]<1)
    {
        [self showToastLong:@"Please input password."];
        return;
    }
    
    if([password length]<6)
    {
        [self showToastLong:@"Password should be between 6 to 30 characters."];
        return;
    }
    
    if(![password isEqualToString:confirm])
    {
        [self showToastLong:@"Password do not match."];
        return;
    }
    
    if([sex length]<1)
    {
        [self showToastLong:@"Please input gender."];
        return;
    }
    
    if([birth length] != 10)
    {
        [self showToastLong:@"Date Input Error"];
        return;
    }
    
    NSString *post =[NSString stringWithFormat:@"firstname=%@&lastname=%@&password=%@&email=%@&gender=%@&date=%@&height=\"%@\"&weight=\"%@\"",firstname, lastname,password,email,sex,birth,height, weight];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postlength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    NSString  *REGISTER_URL = @"http://opuluslabs.com/register.php";
    NSURL *url = [NSURL URLWithString:REGISTER_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postlength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [self showProgress];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jDic = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
        NSLog(@"Sign Up reply: %@", jDic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgress];
            if([jDic objectForKey:@"user"])
            {
                NSDictionary *temp = [jDic objectForKey:@"user"];
                NSString *gener = [temp objectForKey:@"gender"];
                NSString *birth = [temp objectForKey:@"date"];
                NSString *fname = [temp objectForKey:@"firstname"];
                NSString *lname = [temp objectForKey:@"lastname"];
                NSString *height = [temp objectForKey:@"height"];
                NSString *weight = [temp objectForKey:@"weight"];
                NSString * coinStr =[temp objectForKey:@"coin"];
                coinValue = (int)[coinStr integerValue];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:email forKey:KEY_EMAIL];
                [defaults setObject:password forKey:KEY_PASSWORD];
                [defaults setObject:gener forKey:KEY_GENDER];
                [defaults setObject:birth forKey:KEY_BIRTH];
                [defaults setObject:fname forKey:KEY_FIRSTNAME];
                [defaults setObject:lname forKey:KEY_LASTNAME];
                [defaults setObject:height forKey:KEY_HEIGHT];
                [defaults setObject:weight forKey:KEY_WEIGHT];
                
                NSString *res = [self getTourVapePassState];
                if(![res isEqualToString:@"pass"])
                {
                    [self performSegueWithIdentifier:@"segueTourVape" sender:nil];
                }
                else{
                    [self performSegueWithIdentifier:@"segueHome" sender:nil];
                }
                
                isLoging = YES;
            }
            else if([jDic objectForKey:@"error_msg"])
            {
                [self showToastLong:[jDic objectForKey:@"error_msg"]];
            }
        });
    }] resume];
}


#pragma mark - text filed event

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    int tag = (int)textField.tag;
    
    if(textField !=_txtSex && textField !=_txtHeight && textField != _txtBirth ){
        if(tag>803)
        {
            CGRect frame = _viewWorkStation.frame;
            if (frame.origin.y > -100)
            {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.35];
                frame.origin.y = -180;
                _viewWorkStation.frame = frame;
                [UIView commitAnimations];
            }
        }
    }
    
    if(textField==_txtSex){
        [textField resignFirstResponder];
        [self.txtUsername resignFirstResponder];
        [self.txtEmail resignFirstResponder];
        [self.txtPassword resignFirstResponder];
        [self.txtBirth resignFirstResponder];
        [self.txtHeight resignFirstResponder];
        [self.txtConfirm resignFirstResponder];
        [self.txtWeight resignFirstResponder];
        [actionGender showInView:self.view];
        return false;
    } else if (textField==_txtHeight){
        [textField resignFirstResponder];
        [self.txtUsername resignFirstResponder];
        [self.txtEmail resignFirstResponder];
        [self.txtPassword resignFirstResponder];
        [self.txtBirth resignFirstResponder];
        [self.txtHeight resignFirstResponder];
        [self.txtConfirm resignFirstResponder];
        [self.txtWeight resignFirstResponder];
        
        [actoinHeight showInView:self.view];
        return false;
        
    }
    /*else if(textField == _txtBirth)
    {
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.year = 2018;
        comps.month= 3;
        comps.day = 3;
        NSDate *toDate = [cal dateFromComponents:comps];
        [self.calenView setCurrentDate:toDate];
        [_mCalendarView setHidden:NO];
        
        [textField resignFirstResponder];
        [self.txtUsername resignFirstResponder];
        [self.txtEmail resignFirstResponder];
        [self.txtPassword resignFirstResponder];
        [self.txtBirth resignFirstResponder];
        [self.txtHeight resignFirstResponder];
        [self.txtConfirm resignFirstResponder];
        [self.txtWeight resignFirstResponder];
        
        return false;

    }*/
    
    return true;// return [super textFieldShouldBeginEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int tag = (int)textField.tag;
    
    if(tag>803)
    {
        CGRect frame = _viewWorkStation.frame;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35];
        frame.origin.y = 0;
        _viewWorkStation.frame = frame;
        [UIView commitAnimations];
        [textField resignFirstResponder];
        return true;
    }
    [textField resignFirstResponder];
    return NO;
    // return [super textFieldShouldReturn:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return true;
    //return [super textFieldShouldEndEditing:textField];
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
    
    [_txtBirth setInputView:datePicker1];
    
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    [_txtBirth setInputAccessoryView:toolBar];
    
}


-(void) dateTextField:(id)sender
{
    
}

-(void) ShowSelectedDate
{
    UIDatePicker *picker = (UIDatePicker*)_txtBirth.inputView;
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
    _txtBirth.text = [NSString stringWithFormat:@"%04d-%02d-%02d",(int)year, (int)month, (int)day];
    [_txtBirth resignFirstResponder];
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


@end
