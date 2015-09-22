//
//  GroupViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/29.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"

@interface GroupViewController : UIViewController<PullTableViewDelegate,UITableViewDelegate,UIAlertViewDelegate>{
    
}
@property (nonatomic, strong) IBOutlet PullTableView *pullTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
//附近任务数组(每次从服务器获取)
@property(nonatomic,strong) NSMutableArray *groupInfoArray;
@property(nonatomic,assign) int count;

@end
