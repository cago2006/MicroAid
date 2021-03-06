//
//  FinishedMissionsViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/21.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinishedMissionsViewController : UIViewController<UITableViewDelegate>{
}

@property (nonatomic, strong) IBOutlet UITableView *pullTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
//附近任务数组(每次从服务器获取)
@property(nonatomic,strong) NSArray *missionInfoArray;
@property(nonatomic,assign) int count;
@property(nonatomic,strong) UINavigationController* parentNavController;
-(void) setParentNav:(UINavigationController *)parentNavController;
@end
