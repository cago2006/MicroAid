//
//  GroupTableViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/1.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//
@protocol ReturnGroupDelegate

-(void) passChoiceGroupValues:(NSString *)string;

@end

#import <UIKit/UIKit.h>
#import "CreateMissionViewController.h"

@interface GroupTableViewController : UITableViewController<PassMultiValuesDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (retain,nonatomic) id <ReturnGroupDelegate> returnGroupDelegate;
@property (nonatomic, strong) NSIndexPath *choosedIndex;

@property (nonatomic, assign) bool isParentEditMission;
@property (nonatomic, assign) bool isParentFromHomeView;
@property (nonatomic, assign) bool isParentFromMyMission;

@end
