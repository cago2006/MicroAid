//
//  TypeTableViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/1.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//
@protocol ReturnTypeDelegate

-(void) passChoiceTypeValues:(NSString *)string;

@end

#import <UIKit/UIKit.h>
#import "CreateMissionViewController.h"

@interface TypeTableViewController : UITableViewController<PassMultiValuesDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (retain,nonatomic) id <ReturnTypeDelegate> returnTypeDelegate;
@property (nonatomic, strong) NSIndexPath *choosedIndex;

@end
