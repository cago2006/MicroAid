//
//  SearchTableViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/11/22.
//  Copyright © 2015年 Strikingly. All rights reserved.
//
@protocol passChoosedItemDelegate
-(void) passItemValue:(NSString *)values;
@end


#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface SearchTableViewController : UITableViewController{
    
}

@property (nonatomic, strong) NSArray *recordArray;
@property (nonatomic, strong) UIViewController *superView;
@property (nonatomic, retain) id<passChoosedItemDelegate> passValueDelegate;

- (id)initWithStyle:(UITableViewStyle)style superView:(UIViewController *)home;

@end
