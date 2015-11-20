//
//  RecJoinGroupViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/11/10.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"

@interface RecJoinGroupViewController : UIViewController<PullTableViewDelegate>{
    
}
@property (nonatomic, strong) IBOutlet PullTableView *pullTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
//附近任务数组(每次从服务器获取)
@property(nonatomic,strong) NSMutableArray *userInfoArray;
@property(nonatomic,assign) int count;
@property(nonatomic,strong) NSString *groupName;

@end
