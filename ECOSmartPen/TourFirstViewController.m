//
//  TourFirstViewController.m
//  ECOSmartPen
//
//  Created by apple on 04/04/2018.
//  Copyright © 2018 mac. All rights reserved.
//

#import "TourFirstViewController.h"
#import "Const.h"

@interface TourFirstViewController ()

@property (nonatomic,retain) SwitchSlideView *switchSlide;

@end

@implementation TourFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *res = [self getTourPassState];
    
    if([res isEqualToString:@"pass"])
    {
        [self performSegueWithIdentifier:@"segueLoginWindow" sender:self];
        return;
    }
    
    
    
    [_btnGetStart setHidden:YES];
    NSArray *images= [NSArray arrayWithObjects:@"tour_0", @"tour_1",@"tour_2",@"tour_3" ,nil];
    
    CGRect frame = self.view.frame;
    self.switchSlide = [[SwitchSlideView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) height:150];
    [self.switchSlide setImagesWithArray:images];
    
    [self.switchSlide setDelegate:self];
    
    [self.view insertSubview:self.switchSlide atIndex:1];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickGetStart:(id)sender {
    [self performSegueWithIdentifier:@"segueLoginWindow" sender:self];
    [self saveTourPassState:true];
    
}

- (IBAction)clickSkipTour:(id)sender {
    [self performSegueWithIdentifier:@"segueLoginWindow" sender:self];
    [self saveTourPassState:true];
}

- (IBAction)clickECOSmartPen:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:learnSiteURL]];
}

#pragma mark - save/get
-(void)saveTourPassState:(Boolean)status
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString* saveStatus = status==true?@"pass":@"first";
    if (standardUserDefaults) {
        [standardUserDefaults setObject:saveStatus forKey:@"first_tour"];
        [standardUserDefaults synchronize];
    }
}

-(NSString*)getTourPassState
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = @"first";
    if (standardUserDefaults) {
        result=(NSString*)[standardUserDefaults valueForKey:@"first_tour"];
    }
    return result;
}

#pragma mark - last delegate
- (void)lastPage
{
    [_btnGetStart setHidden:NO];
}

- (void)notLastPage
{
    [_btnGetStart setHidden:YES];
}
@end
