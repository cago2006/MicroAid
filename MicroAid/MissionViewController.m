//
//  MissionViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/29.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "MissionViewController.h"
#import "RootController.h"
#import "CreateMissionViewController.h"
#import "PullTableView.h"
#import "MissionListCell.h"
#import "MicroAidAPI.h"
#import "MissionInfo.h"
#import "ProgressHUD.h"
#import "FilterViewController.h"
#import "ViewMissionViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface MissionViewController ()

@end

@implementation MissionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [self.navigationItem setTitle:@"可认领任务"];
    
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(createMission) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithCustomView:addBtn];
    //[addBtn release];
    
    UIButton *filterBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [filterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [filterBtn addTarget:self action:@selector(filterMission) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn setBackgroundImage:[UIImage imageNamed:@"filter.png"] forState:UIControlStateNormal];
    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc]initWithCustomView:filterBtn];
    //[filterBtn release];
    
    UIButton *locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [locationBtn addTarget:self action:@selector(returnToLocation) forControlEvents:UIControlEventTouchUpInside];
    [locationBtn setBackgroundImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    UIBarButtonItem *locationItem = [[UIBarButtonItem alloc]initWithCustomView:locationBtn];
    //[locationBtn release];
    
    NSArray *itemArray=[[NSArray alloc]initWithObjects:addItem,filterItem,locationItem, nil];
    //[addItem release];
    //[filterItem release];
    //[locationItem release];
    [self.navigationItem setRightBarButtonItems:itemArray];
    
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor whiteColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
  

    self.dataArray = [[NSMutableArray alloc] init];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.count = 1;
    //self.dataArray = [[NSMutableArray alloc]initWithCapacity:10];
    [self searchNearby:self.count pageSize:20];
    self.tabBarController.tabBar.hidden = NO;
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //self.dataArray = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) returnToLocation{
    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
    [rootController switchToHomeViewFromMainTab];
}

-(void) createMission{
    CreateMissionViewController *createMissionVC = [[CreateMissionViewController alloc] initWithNibName:@"CreateMissionViewController" bundle:nil];
    
    self.tabBarController.tabBar.hidden = YES;
    createMissionVC.isEditMission = NO;
    [self.navigationController pushViewController:createMissionVC animated:YES];
}

-(void) filterMission{
    self.view.userInteractionEnabled = false;
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    FilterViewController *filterVC = [[FilterViewController alloc]initWithNibName:@"FilterViewController" bundle:nil];
    
    self.tabBarController.tabBar.hidden = YES;
    
    [self.navigationController pushViewController:filterVC animated:YES];
}


- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.  刷新代码放在这
     
     */
    [self.dataArray removeAllObjects];
    self.count = 1;
    //[self.dataArray removeAllObjects];
    [self searchNearby:self.count pageSize:20];
    
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.  加载更多实现代码放在在这
     
     */
    self.count++;
    [self searchNearby:self.count pageSize:20];
    
    self.pullTableView.pullTableIsLoadingMore = NO;
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

//点击显示具体信息，首先进行判断
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    MissionInfo *info = [self.dataArray objectAtIndex:indexPath.row];
    if(info.userId == userID){
        CreateMissionViewController *cmVC = [[CreateMissionViewController alloc]initWithNibName:@"CreateMissionViewController" bundle:nil];
        
        self.tabBarController.tabBar.hidden = YES;
        cmVC.isEditMission = YES;
        cmVC.missionID = info.missionId;
        [self.navigationController pushViewController:cmVC animated:YES];
    }else{
        ViewMissionViewController *viewMissionVC =[[ViewMissionViewController alloc]initWithNibName:@"ViewMissionViewController" bundle:nil];
        if(([info.statusInfo isEqualToString:@"未接受"] || [info.statusInfo isEqualToString:@"未认领"] )){
            viewMissionVC.isAccepted = NO;
        }else{
            viewMissionVC.isAccepted = YES;
        }
        viewMissionVC.missionID = info.missionId;
        viewMissionVC.missionDistance = info.distance;
        self.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:viewMissionVC animated:YES];
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CustomCellIdentifier";
    
    MissionListCell *cell = (MissionListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"MissionListCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    // cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    MissionInfo *info = [self.dataArray objectAtIndex:indexPath.row];
    [[cell title]setText:info.title];
    [[cell distance]setText:[NSString stringWithFormat:@"%.1fm",info.distance]];
    [[cell group]setText:info.group];
    
    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:0.0f];
}

-(void)searchNearby:(int)pageNo pageSize:(int)pageSize{
    
    NSArray *statusArray = [NSArray arrayWithObjects:@"0", nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    double distance = [userDefaults doubleForKey:@"missionDistance"];
    NSLog(@"mission:%f",distance);
    if(distance < 0.1){
        distance = 1000;
    }
    double latitude = [userDefaults doubleForKey:@"latitude"];
    double longitude = [userDefaults doubleForKey:@"longitude"];
    NSString *endTime = [userDefaults objectForKey:@"missionEndTime"];
    NSString *group = [userDefaults objectForKey:@"missionGroup"];
    NSString *bonus = [userDefaults objectForKey:@"missionBonus"];
    NSString *type = [userDefaults objectForKey:@"missionType"];
    if(endTime==nil || [endTime isEqualToString:@""]){
        endTime = @"全部";
    }
    if(group==nil || [group isEqualToString:@""]){
        group = @"全部";
    }
    if(bonus==nil || [bonus isEqualToString:@""]){
        bonus = @"全部";
    }
    if(type==nil || [type isEqualToString:@""]){
        type = @"全部";
    }
    
    dispatch_async(kBgQueue, ^{
        NSDictionary *nearbyMissions = [MicroAidAPI getMissionList:statusArray distance:distance type:type group:group bonus:bonus longitude:longitude latitude:latitude endTime:endTime pageNo:pageNo pageSize:pageSize userID:userID];
        
        if ([[nearbyMissions objectForKey:@"onError"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"获取数据失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
            return;
        } else {
            
            _missionInfoArray = [MissionInfo getMissionInfos:[nearbyMissions objectForKey:@"taskInfoList"]];
            /*
            if ([_missionInfoArray count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"没有更多了!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.count == 1){
                    [self.dataArray removeAllObjects];
                }
                [self.dataArray addObjectsFromArray:self.missionInfoArray];
                [self.pullTableView reloadData];
            });*/
            if([_missionInfoArray count] < 20){
                [self performSelectorOnMainThread:@selector(getAllOtherMission:) withObject:_missionInfoArray waitUntilDone:YES];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.count == 1){
                        [self.dataArray removeAllObjects];
                    }
                    [self.dataArray addObjectsFromArray:self.missionInfoArray];
                    [self.pullTableView reloadData];
                });
            }
        }
    });
}


-(void) getAllOtherMission:(NSArray *)missionArray{
    if(self.count == 1){
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:missionArray];
    NSArray *statusArray = [NSArray arrayWithObjects:@"0", nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    double latitude = [userDefaults doubleForKey:@"latitude"];
    double longitude = [userDefaults doubleForKey:@"longitude"];
    NSString *endTime = [userDefaults objectForKey:@"missionEndTime"];
    if(endTime==nil || [endTime isEqualToString:@""]){
        endTime = @"全部";
    }
    dispatch_async(kBgQueue, ^{
        NSDictionary *nearbyMissions = [MicroAidAPI getMissionList:statusArray distance:999999999 type:@"全部" group:@"全部" bonus:@"全部" longitude:longitude latitude:latitude endTime:endTime pageNo:1 pageSize:999 userID:userID];
        
        if ([[nearbyMissions objectForKey:@"onError"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"获取数据失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
            return;
        } else {
            _othersMissionInfoArray = [MissionInfo getMissionInfos:[nearbyMissions objectForKey:@"taskInfoList"]];
            NSMutableArray *array = [[NSMutableArray alloc]initWithArray:_othersMissionInfoArray];
            for(NSUInteger i = 0; i< array.count; i++){
                MissionInfo *temp1 = [array objectAtIndex:i];
                for(MissionInfo *temp2 in self.dataArray){
                    if(temp1.missionId == temp2.missionId){
                        [array removeObjectAtIndex:i];
                        i--;
                        break;
                    }
                }
            }
            if ([missionArray count]== 0 && [array count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"没有更多了!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self.dataArray addObjectsFromArray:array];
                 [self.pullTableView reloadData];
            });
        }
    });
}

@end
