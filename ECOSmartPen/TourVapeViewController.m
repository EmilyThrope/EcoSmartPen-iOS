//
//  TourVapeViewController.m
//  ECOSmartPen
//
//  Created by apple on 04/04/2018.
//  Copyright © 2018 mac. All rights reserved.
//

#import "TourVapeViewController.h"
#import "Const.h"

@interface TourVapeViewController ()
@property (nonatomic,retain) SwitchSlideView *switchSlide;
@end

@implementation TourVapeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *images= [NSArray arrayWithObjects:@"vape_0", @"vape_1",@"vape_2",nil];
    
    CGRect frame = self.view.frame;
    int h_w = frame.size.width;
    //int h_h = frame.size.height;
    int width = 200;
    int height = 300;
    self.switchSlide = [[SwitchSlideView alloc] initWithFrame:CGRectMake((h_w - width)/2, 200, width, height) height:30];
    [self.switchSlide setImagesWithArray:images];
    [self.switchSlide setDelegate:self];
    
    [self.view insertSubview:self.switchSlide atIndex:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if(gotoVapeSkip == 1)
    {
        gotoVapeSkip = 0;
        selectScreenIndex = SCREEN_HOME;
        [self saveTourVapePassState:true];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (IBAction)clickSkipTour:(id)sender {
    [self saveTourVapePassState:true];
    selectScreenIndex = SCREEN_HOME;
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)clickPair:(id)sender {
    [self saveTourVapePassState:true];
    [self performSegueWithIdentifier:@"segueTourPairing" sender:self];
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


#pragma mark - last delegate
- (void)lastPage
{
   
}

- (void)notLastPage
{
   
}

@end
