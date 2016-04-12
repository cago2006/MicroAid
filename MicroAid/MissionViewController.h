//
//  MissionViewController.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/29.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
#import "PullTableView.h"
#import "ViewMissionViewController.h"
#import "MissionInfo.h"
#import "MicroAidAPI.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface MissionViewController : UIViewController<PullTableViewDelegate,UITableViewDelegate,BMKLocationServiceDelegate>{
    BMKLocationService* _locService;
}

@property (nonatomic, strong) IBOutlet PullTableView *pullTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
//附近任务数组(每次从服务器获取)
@property(nonatomic,strong) NSArray *missionInfoArray;
@property(nonatomic,strong) NSArray *othersMissionInfoArray;
@property(nonatomic,assign) int count;

//当前纬度
@property (nonatomic, assign) double latitude;
//当前经度
@property (nonatomic, assign) double longitude;

@property (nonatomic, retain) NSTimer *timer;

@end
