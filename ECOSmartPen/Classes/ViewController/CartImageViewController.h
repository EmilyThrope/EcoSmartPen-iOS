//
//  MyCameraViewController.h
//  ECOSmartPen
//
//  Created by apple on 8/16/17.
//  Copyright © 2017 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageBaseViewController.h"
@interface CartImageViewController : ImageBaseViewController<UIImagePickerControllerDelegate>
{
    
}

@property (strong, nonatomic) IBOutlet UIImageView *imgView;

@end
