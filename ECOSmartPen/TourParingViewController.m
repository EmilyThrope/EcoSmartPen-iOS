//
//  TourParingViewController.m
//  ECOSmartPen
//
//  Created by apple on 04/04/2018.
//  Copyright © 2018 mac. All rights reserved.
//

#import "TourParingViewController.h"
#import "Const.h"


@interface TourParingViewController ()
{
    NSMutableArray  *deviceArray;
    CBPeripheral    *device;
}
@end

@implementation TourParingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    deviceArray =  [[NSMutableArray alloc] init];

    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(scanDevices) userInfo:nil repeats:NO];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickSkipTour:(id)sender {
    [self performSegueWithIdentifier:@"segueDosageTracker" sender:self];
}

-(void) scanDevices
{
    [mBLEComm startScanDevicesWithInterval:10.0 CompleteBlock:^(NSArray *devices)
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
     }];
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
    cell.textLabel.text = [dev name];
    cell.textLabel.textColor = [UIColor colorWithRed:0.8 green:0.623 blue:0.32 alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20.0];
    
    [cell.imageView setImage:nil];
    //UIImageView *myView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ble_img"]];
    cell.imageView.image  = [UIImage imageNamed:@"ble_img"];
    
    
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
    device = [deviceArray objectAtIndex:indexPath.section];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* address = [device.identifier UUIDString];
    NSLog(@"connect addr:%@",address);
    [self saveDeviceName:device.name];
    [self saveDeviceAddress:address];
    
    [self performSegueWithIdentifier:@"segueTourCartridge" sender:self];
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

@end
