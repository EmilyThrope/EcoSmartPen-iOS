//
//  MyCameraViewController.m
//  ECOSmartPen
//
//  Created by apple on 8/16/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import "CartImageViewController.h"
#import "Const.h"
@interface CartImageViewController ()
{
    NSString *imgFilename;
    UIImagePickerController *picker;
}
@end

@implementation CartImageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    imgFilename = defaultImageName;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
     [_imgView setImage:[self getImage]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)photoLibraryClick:(id)sender {
    [self setImageName:[self getImageName]];
    [self openCameraRoll];
}

- (void)finishedImportImage
{
    [_imgView setImage:[self getImage]];
}

- (IBAction)cameraButtonClick:(id)sender {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentModalViewController:picker animated:YES];
}
- (IBAction)doneButtonClick:(id)sender {
    
    UIImage *image = [self getImage];
    if(image != nil)
        getImageStatus = true;
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cancleButtonClick:(id)sender {
    NSString *filePath2 = [self getImageName];
    
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSError *err;
    if([fm fileExistsAtPath:filePath2 isDirectory:nil])
    {
        [fm removeItemAtPath:filePath2 error:&err];
    }
    getImageStatus = false;
    [self.navigationController popViewControllerAnimated:YES];
}




- (NSString *)getImageName
{
    NSArray *paths          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [paths objectAtIndex:0];
    NSString *imgfileName   = [NSString stringWithFormat:@"img_%s_thumb.jpg", imgFilename.UTF8String];
    directoryPath = [directoryPath stringByAppendingPathComponent:@"CatridgeImage"];
    NSString *dstPath = [directoryPath stringByAppendingPathComponent:imgfileName];
    
    return dstPath;
}

- (UIImage *)getImage
{
    UIImage *cartImage = [UIImage imageWithContentsOfFile:[self getImageName]];
    
    return cartImage;
}

- (void)imagePickerController: (UIImagePickerController *)picker_new
didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    UIImage* image = [info objectForKey: @"UIImagePickerControllerEditedImage"];
    [_imgView setImage:image];
    
    NSString *str = [self getImageName];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:str atomically:YES];
    
    [self dismissModalViewControllerAnimated:YES];
}
@end
