//
//  FilterTypeTVC.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/16.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//
@protocol ReturnFilterTypeDelegate

-(void) passFilterTypeValues:(NSString *)string;

@end

#import <UIKit/UIKit.h>
#import "FilterViewController.h"

@interface FilterTypeTVC : UITableViewController<PassFilterValuesDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (retain,nonatomic) id <ReturnFilterTypeDelegate> returnFilterTypeDelegate;

@end
