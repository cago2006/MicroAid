//
//  RankingViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/12/5.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"

@interface RankingViewController : UIViewController<PullTableViewDelegate,UITableViewDelegate,UIAlertViewDelegate>{
    
}
@property (nonatomic, strong) IBOutlet PullTableView *pullTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
//附近任务数组(每次从服务器获取)
@property(nonatomic,strong) NSMutableArray *userInfoArray;
@property(nonatomic,assign) int count;

@end
