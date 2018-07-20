//
//  AddCatrideViewController.m
//  ECOSmartPen
//
//  Created by apple on 8/8/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import "AddCatrideViewController.h"
#import "Const.h"
#import <sqlite3.h>
#import "MBProgressHUD.h"

float color_array[] = {93,0,128,0,24,255,0,153,36,255,233,0,229,79,0,138,26,255,0,183,255,103,229,23,255,191,38,229,44,34,224,224,224,0,0,0};


@interface AddCatrideViewController ()
{
    NSString *oldImageName;
    NSString *oldSampleName;
}
@end



@implementation AddCatrideViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    oldImageName =@"";
    /*for(int i=200; i<207; i++)
    {
        ((UITextField*)[self.view viewWithTag:i]).layer.borderColor = [[UIColor whiteColor] CGColor];
        ((UITextField*)[self.view viewWithTag:i]).layer.borderWidth = 1.0f;
    }
    for(int j=300; j<307; j++)
    {
        ((UITextField*)[self.view viewWithTag:j]).layer.borderColor = [[UIColor whiteColor] CGColor];
        ((UITextField*)[self.view viewWithTag:j]).layer.borderWidth = 1.0f;
    }
    
    _txtSampleID.layer.borderWidth = 1.0f;
    _txtSampleID.layer.borderColor = [[UIColor whiteColor] CGColor];
    _txtSampleName.layer.borderWidth = 1.0f;
    _txtSampleName.layer.borderColor = [[UIColor whiteColor] CGColor];*/
    // Do any additional setup after loading the view.
    
    
    [self addGestureRecogniser:_mColorView];
    [self progressInit];
}

-(void)addGestureRecogniser:(UIView *)touchView{
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maskViewTouch)];
    [touchView addGestureRecognizer:singleTap];
}

-(void)maskViewTouch{
    [_mColorView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    switch (sendMode)
    {
        case SEND_CATRIDGE_ADDMODE:
            _txtSampleName.text = @"";
            _txtSampleID.text = @"";
            oldSampleName= @"";
            break;
        case SEND_CATRIDGE_DEFAULT:
            [_txtSampleName setEnabled:false];
            _txtSampleName.text = defaultCatridgeName;
            oldSampleName = defaultCatridgeName;
            sendCatName = defaultCatridgeName;
            [self loadCatridge];
            break;
        case SEND_CATRIDGE_EDITMODE:
            [_txtSampleName setEnabled:true];
            [self loadCatridge];
            break;
    }
    
    if(getImageStatus == true)
    {
        UIImage *image = [self getImage:defaultImageName];
        if(image != nil)
        {
            [_imgCartridge setImage:image];
            oldImageName = defaultImageName;
            getImageStatus = false;
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Event;
- (IBAction)doneButtonClick:(id)sender {
    
    if([_txtSampleName.text length] < 1)
    {
        [self showToastShort:@"Please input sample name."];
        return;
    }
    else if ([_txtSampleID.text length] < 1)
    {
         [self showToastShort:@"Please input sample ID."];
        return;
    }
    if(sendMode == SEND_CATRIDGE_ADDMODE)
    {
        [self addData];
    }
    else
    {
        [self modifyData];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cancelButtonClick:(id)sender {
    
    NSString *filePath2 = [self getImageName:defaultImageName];
    
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSError *err;
    if([fm fileExistsAtPath:filePath2 isDirectory:nil])
    {
        [fm removeItemAtPath:filePath2 error:&err];
         NSLog(@"Remove file (cancelbutton):%@", filePath2);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)colorSelectButtonClick:(id)sender {
    [_mColorView setHidden:NO];
}

- (IBAction)colorButtonClick:(id)sender {
    
    UIButton *but = (UIButton*)sender;
    int color = (int)but.tag - 400;
    
    _lblColor.backgroundColor = [UIColor colorWithRed:color_array[color*3]/255.0f green:color_array[color*3 + 1]/255.0f blue:color_array[color*3+2]/255.0f alpha:1.0];
    colorCount = color;
    [_mColorView setHidden:YES];
}

- (IBAction)cameraButtonClick:(id)sender {
    getImageStatus = false;
    
    UIImage *image = [self getImage:oldImageName];
    if(image != nil && ![oldImageName isEqualToString:@""])
    {
        NSString *filePath1 = [self getImageName:defaultImageName];
        NSString *filePath2 = [self getImageName:oldImageName];
        
        NSFileManager * fm = [[NSFileManager alloc] init];
        NSError *err;
        if([fm fileExistsAtPath:filePath2 isDirectory:nil])
        {
            Boolean res = [fm copyItemAtPath:filePath2 toPath:filePath1 error:&err];
            if(res == false)
                NSLog(@"Error:%@", err);
        }
    }
    [self performSegueWithIdentifier:@"segueSelectCartImage" sender:self];
}

#pragma mark - text filed event
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - database processing

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
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    const char *dbpath =  [paths UTF8String];
    sqlite3_stmt    *statement;
    static sqlite3 *database = nil;
    
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
                if([sampleName isEqualToString:sendCatName])
                {
                    _txtSampleName.text = sampleName;
                    oldSampleName = sampleName;
                    _txtSampleID.text = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                  
                    [((UITextField*)[self.view viewWithTag:200]) setText:[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)]];
                    [((UITextField*)[self.view viewWithTag:300]) setText:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 3)]];
                    [((UITextField*)[self.view viewWithTag:201]) setText:[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)]];
                    [((UITextField*)[self.view viewWithTag:301]) setText:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 5)]];
                    [((UITextField*)[self.view viewWithTag:202]) setText:[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)]];
                    [((UITextField*)[self.view viewWithTag:302]) setText:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 7)]];
                    [((UITextField*)[self.view viewWithTag:203]) setText:[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)]];
                    [((UITextField*)[self.view viewWithTag:303]) setText:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 9)]];
                    [((UITextField*)[self.view viewWithTag:204]) setText:[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)]];
                    [((UITextField*)[self.view viewWithTag:304]) setText:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 11)]];
                    [((UITextField*)[self.view viewWithTag:205]) setText:[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)]];
                    [((UITextField*)[self.view viewWithTag:305]) setText:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 13)]];
                    
                    int color = sqlite3_column_int(statement, 14);
                    _lblColor.backgroundColor = [UIColor colorWithRed:color_array[color*3]/255.0f green:color_array[color*3 + 1]/255.0f blue:color_array[color*3+2]/255.0f alpha:1.0];
                    colorCount = color;
                    break;
                }
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    
    if(getImageStatus == false)
    {
        NSString *filePath = [self getImageName:sendCatName];
        NSFileManager * fm = [[NSFileManager alloc] init];
        NSLog(@"\nfilePath : %@ \n", filePath);
        if([fm fileExistsAtPath:filePath isDirectory:nil])
        {
            _imgCartridge.image = [self getImage:sendCatName];
            oldImageName = sendCatName;
        }
    }
    
}

- (void) addData
{
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    sqlite3_stmt    *statement;
    static sqlite3 *database = nil;

    if(sqlite3_open_v2([paths cStringUsingEncoding:NSUTF8StringEncoding], &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        NSString *samID = _txtSampleID.text;
       NSString *samName = _txtSampleName.text;
        
        int val1 = [((UITextView*)[self.view viewWithTag:300]).text intValue];
        int val2 = [((UITextView*)[self.view viewWithTag:301]).text intValue];
        int val3 = [((UITextView*)[self.view viewWithTag:302]).text intValue];
        int val4 = [((UITextView*)[self.view viewWithTag:303]).text intValue];
        int val5 = [((UITextView*)[self.view viewWithTag:304]).text intValue];
        int val6 = [((UITextView*)[self.view viewWithTag:305]).text intValue];
        
        NSString *txt1 = ((UITextView*)[self.view viewWithTag:200]).text;
        NSString *txt2 = ((UITextView*)[self.view viewWithTag:201]).text;
        NSString *txt3 = ((UITextView*)[self.view viewWithTag:202]).text;
        NSString *txt4 = ((UITextView*)[self.view viewWithTag:203]).text;
        NSString *txt5 = ((UITextView*)[self.view viewWithTag:204]).text;
        NSString *txt6 = ((UITextView*)[self.view viewWithTag:205]).text;
        
        NSString *sql1 = [NSString stringWithFormat: @"INSERT INTO CatridgeInfo (SampleID, SampleName, TXT1, VAL1, TXT2, VAL2, TXT3, VAL3, TXT4, VAL4, TXT5, VAL5, TXT6, VAL6, colorID,days) VALUES('%@','%@','%@',%d,'%@',%d,'%@',%d,'%@',%d,'%@',%d,'%@',%d,%d,'10|10|10|10|10|10|10');",samID, samName,txt1,val1, txt2, val2, txt3, val3, txt4, val4, txt5, val5, txt6, val6, colorCount];
        const char *query_stmt51 = [sql1 UTF8String];
        sqlite3_busy_timeout(database, 500);
        if(sqlite3_prepare_v2(database, query_stmt51, -1, &statement, NULL) != SQLITE_OK)
        {
            NSLog(@"INSERT CatridgeInfo: %s", sqlite3_errmsg(database));
        }
        
        if(sqlite3_step(statement) != SQLITE_DONE ) {
            NSLog( @"INSERT CatridgeInfo: %s", sqlite3_errmsg(database) );
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        UIImage *image = [self getImage:oldImageName];
        if(image == nil)
        {
            oldImageName = @"Empty";
            image = [UIImage imageNamed:@"cat_0"];
            NSString *path =[self getImageName:oldImageName];
            [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
        }
        
        if(image != nil && ![oldImageName isEqualToString:@""])
        {
            if([samName isEqualToString: oldImageName])
                return;
            
            NSString *filePath1 = [self getImageName:samName];
            NSString *filePath2 = [self getImageName:oldImageName];
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
        
        ////////////////////////////////////////////////////
        NSString *email = [self getSavedEmail];
        
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        [jsonDic setValue:email forKey:@"email"];
        [jsonDic setValue:samID forKey:@"sampleID"];
        [jsonDic setValue:samName forKey:@"sampleName"];
        [jsonDic setValue:samName forKey:@"cartridge"];
       [jsonDic setValue:txt1 forKey:@"TXT1"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val1] forKey:@"VAL1"];
        [jsonDic setValue:txt2 forKey:@"TXT2"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val2] forKey:@"VAL2"];
        [jsonDic setValue:txt3 forKey:@"TXT3"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val3] forKey:@"VAL3"];
        [jsonDic setValue:txt4 forKey:@"TXT4"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val4] forKey:@"VAL4"];
        [jsonDic setValue:txt5 forKey:@"TXT5"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val5] forKey:@"VAL5"];
        [jsonDic setValue:txt6 forKey:@"TXT6"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val6] forKey:@"VAL6"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",colorCount] forKey:@"colorID"];
        [jsonDic setValue:@"10|10|10|10|10|10|10" forKey:@"days"];
        
        [self sendCartridge:jsonDic isModify:false];
    }
}
- (void) modifyData
{
    [self createEditableCopyOfDatabaseIfNeeded];
    NSString * paths=[self getWritableDBPath];
    sqlite3_stmt    *statement;
    static sqlite3 *database = nil;
    
    if(sqlite3_open_v2([paths cStringUsingEncoding:NSUTF8StringEncoding], &database, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        NSString *samID = _txtSampleID.text;
        NSString *samName = _txtSampleName.text;
        int val1 = [((UITextView*)[self.view viewWithTag:300]).text intValue];
        int val2 = [((UITextView*)[self.view viewWithTag:301]).text intValue];
        int val3 = [((UITextView*)[self.view viewWithTag:302]).text intValue];
        int val4 = [((UITextView*)[self.view viewWithTag:303]).text intValue];
        int val5 = [((UITextView*)[self.view viewWithTag:304]).text intValue];
        int val6 = [((UITextView*)[self.view viewWithTag:305]).text intValue];
        
        NSString *txt1 = ((UITextView*)[self.view viewWithTag:200]).text;
        NSString *txt2 = ((UITextView*)[self.view viewWithTag:201]).text;
        NSString *txt3 = ((UITextView*)[self.view viewWithTag:202]).text;
        NSString *txt4 = ((UITextView*)[self.view viewWithTag:203]).text;
        NSString *txt5 = ((UITextView*)[self.view viewWithTag:204]).text;
        NSString *txt6 = ((UITextView*)[self.view viewWithTag:205]).text;
        
        NSString *sql2 = [NSString stringWithFormat: @"UPDATE CatridgeInfo SET SampleID = '%@', SampleName = '%@', TXT1 = '%@', VAL1 = '%d', TXT2 = '%@', VAL2 = '%d', TXT3 = '%@', VAL3 = '%d', TXT4 = '%@', VAL4 = '%d', TXT5 = '%@', VAL5 = '%d', TXT6 = '%@', VAL6 = '%d', colorID = '%d' WHERE SampleName = '%@'", samID, samName, txt1, val1, txt2, val2, txt3, val3, txt4, val4, txt5, val5, txt6, val6, colorCount,oldSampleName];
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
        
        
        UIImage *image = [self getImage:oldImageName];
        if(image != nil && ![oldImageName isEqualToString:@""])
        {
            if([samName isEqualToString: oldImageName])
                return;
            
            NSString *filePath1 = [self getImageName:samName];
            NSString *filePath2 = [self getImageName:oldImageName];
            NSLog(@"filePath1:%@, filePath2:%@", filePath1, filePath2);
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
                 NSLog(@"Remove file (modify):%@", filePath2);
            }
        }
        
        /////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////
        NSString *email = [self getSavedEmail];;
        
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        [jsonDic setValue:email forKey:@"email"];
        [jsonDic setValue:samID forKey:@"sampleID"];
        [jsonDic setValue:samName forKey:@"sampleName"];
        [jsonDic setValue:oldSampleName forKey:@"cartridge"];
        [jsonDic setValue:samName forKey:@"rename"];
        [jsonDic setValue:txt1 forKey:@"TXT1"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val1] forKey:@"VAL1"];
        [jsonDic setValue:txt2 forKey:@"TXT2"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val2] forKey:@"VAL2"];
        [jsonDic setValue:txt3 forKey:@"TXT3"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val3] forKey:@"VAL3"];
        [jsonDic setValue:txt4 forKey:@"TXT4"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val4] forKey:@"VAL4"];
        [jsonDic setValue:txt5 forKey:@"TXT5"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val5] forKey:@"VAL5"];
        [jsonDic setValue:txt6 forKey:@"TXT6"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",val6] forKey:@"VAL6"];
        [jsonDic setValue:[NSString stringWithFormat:@"%d",colorCount] forKey:@"colorID"];
        [self sendCartridge:jsonDic isModify:false];
        
    }
}

#pragma mark - WebApi

-(void) sendCartridge:(NSMutableDictionary*)jsonDic isModify:(Boolean)isModify
{
    
    NSString *strName = [self getSavedName];
    if([strName isEqualToString:@"Guest"])
    {
         return;
    }
    
    NSString *SEND_URL = @"http://opuluslabs.com/cartridge_add.php";
    if(isModify)
        SEND_URL = @"http://opuluslabs.com/cartridge_modify.php";
    
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

#pragma mark - Progress methods
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
@end
