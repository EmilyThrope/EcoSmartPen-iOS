//
//  SwitchSlideView.h
//  SwitchSlideView
//
//  Created by B.H. Liu on 12-5-14.
//  Copyright (c) 2012年 Appublisher. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LastPageDelegate

@optional
- (void)lastPage;
- (void)notLastPage;

@end


@interface SwitchSlideView : UIView<UIScrollViewDelegate>
{
    id<LastPageDelegate>    mDelegate;
}
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,retain) UIPageControl *pageControl;
@property (nonatomic,readwrite) NSInteger currentIndex;
@property (nonatomic,readwrite) NSInteger totalPages;

- (void) setDelegate:(id<LastPageDelegate>)delegate;
- (void)setImagesWithArray:(NSArray*)array;
- (void)setViewsWithArray:(NSArray*)array;
- (id)initWithFrame:(CGRect)frame height:(int)height;
@end
