//
//  BonusTableViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/31.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//
@protocol ReturnBonusDelegate

-(void) passChoiceBonusValues:(NSString *)string;

@end

#import <UIKit/UIKit.h>
#import "CreateMissionViewController.h"

@interface BonusTableViewController : UITableViewController<PassMultiValuesDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (retain,nonatomic) id <ReturnBonusDelegate> returnBonusDelegate;
@property (nonatomic, strong) NSIndexPath *choosedIndex;

@property (nonatomic, assign) bool isParentEditMission;
@property (nonatomic, assign) bool isParentFromHomeView;
@property (nonatomic, assign) bool isParentFromMyMission;

@end
