//
//  TourCartridgeViewController.m
//  ECOSmartPen
//
//  Created by apple on 04/04/2018.
//  Copyright © 2018 mac. All rights reserved.
//

#import "TourCartridgeViewController.h"
#import "Const.h"
@interface TourCartridgeViewController ()

@end

@implementation TourCartridgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)clickHere:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:learnSiteURL]];
}

- (IBAction)clickKURE:(id)sender {
    [self saveCatridgeName:@"KURE"];
    gotoVapeSkip = 1;
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)clickNIGHTCAP:(id)sender {
    [self saveCatridgeName:@"NIGHT CAP"];
    gotoVapeSkip = 1;
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)clickWAKE:(id)sender {
    [self saveCatridgeName:@"WAKE"];
    gotoVapeSkip = 1;
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)clickCRUSECONTROL:(id)sender {
    [self saveCatridgeName:@"CRUISE CONTROL"];
    gotoVapeSkip = 1;
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)clickBLAZED:(id)sender {
    [self saveCatridgeName:@"BLAZED"];
    gotoVapeSkip = 1;
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)clickSkipTour:(id)sender {
    gotoVapeSkip = 1;
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)clickSIGNATURESERIES:(id)sender {
    [self saveCatridgeName:@"SIGNATRE SERIES"];
    gotoVapeSkip = 1;
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)saveCatridgeName:(NSString*)myCat
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:myCat forKey:@"catridge_name"];
        [standardUserDefaults synchronize];
    }
}



@end
