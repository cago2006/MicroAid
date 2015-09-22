//
//  FilterBonusTVC.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/16.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//
@protocol ReturnFilterBonusDelegate

-(void) passFilterBonusValues:(NSString *)string;

@end

#import <UIKit/UIKit.h>
#import "FilterViewController.h"

@interface FilterBonusTVC : UITableViewController<PassFilterValuesDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (retain,nonatomic) id <ReturnFilterBonusDelegate> returnFilterBonusDelegate;
@property (nonatomic, strong) NSIndexPath *choosedIndex;

@end
