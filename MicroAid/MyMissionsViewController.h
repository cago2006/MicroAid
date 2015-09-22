//
//  MyMissionsViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/21.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JPTabViewControllerDelegate <NSObject>

@optional
- (void)currentTabHasChanged:(NSInteger)selIndex;

@end

@interface MyMissionsViewController : UIViewController<UIScrollViewDelegate>
{
    NSInteger selectedTab;
}

@property (nonatomic, assign) id<JPTabViewControllerDelegate> delegate;

@property (nonatomic, assign) float menuHeight;

- (void)selectTabNum:(NSInteger)index;

- (NSInteger)selectedTab;

@end
