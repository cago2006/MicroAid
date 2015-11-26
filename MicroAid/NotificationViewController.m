//
//  NotificationViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/29.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "NotificationViewController.h"
#import "MicroAidAPI.h"
#import "NotificationInfo.h"
#import "NotificationListCell.h"
#import "ViewMissionViewController.h"
#import "CreateMissionViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [self.navigationItem setTitle:@"我的通知"];
    
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor whiteColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
    self.dataArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.count = 1;
    //self.dataArray = [[NSMutableArray alloc]initWithCapacity:10];
    [self getNotificationInfo:self.count pageSize:20];
    self.tabBarController.tabBar.hidden = NO;
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //self.dataArray = nil;
}


- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.  刷新代码放在这
     
     */
    self.count = 1;
    
    [self getNotificationInfo:self.count pageSize:20];
    
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.  加载更多实现代码放在在这
     
     */
    self.count++;
    [self getNotificationInfo:self.count pageSize:20];
    
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

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

//点击显示具体信息，首先进行判断
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationInfo *info = [self.dataArray objectAtIndex:indexPath.row];
    if([info.status isEqualToString:@"未接受"]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger userID = [userDefaults integerForKey:@"userID"];
        //再加一个任务状态判断
        //todo
        if(info.userID==userID){
            CreateMissionViewController *cmVC = [[CreateMissionViewController alloc]initWithNibName:@"CreateMissionViewController" bundle:nil];
            
            self.tabBarController.tabBar.hidden = YES;
            cmVC.isEditMission = YES;
            cmVC.missionID = info.missionID;
            [self.navigationController pushViewController:cmVC animated:YES];
        }else{
            ViewMissionViewController *viewMissionVC = [[ViewMissionViewController alloc]initWithNibName:@"ViewMissionViewController" bundle:nil];
            
            viewMissionVC.missionID = info.missionID;
            viewMissionVC.isAccepted = NO;
            viewMissionVC.isSelf = true;
            
            self.tabBarController.tabBar.hidden = YES;
            
            [self.navigationController pushViewController:viewMissionVC animated:YES];
        }
    }else{
        ViewMissionViewController *viewMissionVC = [[ViewMissionViewController alloc]initWithNibName:@"ViewMissionViewController" bundle:nil];
        
        viewMissionVC.missionID = info.missionID;
        viewMissionVC.isAccepted = YES;
        viewMissionVC.isSelf = true;
        self.tabBarController.tabBar.hidden = YES;
        
        [self.navigationController pushViewController:viewMissionVC animated:YES];
    }
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CustomCellIdentifier";
    
    NotificationListCell *cell = (NotificationListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"NotificationListCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    // cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];

    
    NotificationInfo *info = [self.dataArray objectAtIndex:indexPath.row];
    //[[cell title]setText:info.title];
    if([info.status isEqualToString:@"已完成"]){
        [[cell statusView]setImage:[UIImage imageNamed:@"green.png"]];
    }else if([info.status isEqualToString:@"已接受"]){
        [[cell statusView]setImage:[UIImage imageNamed:@"yellow.png"]];
    }else if([info.status isEqualToString:@"已过期"]){
        [[cell statusView]setImage:[UIImage imageNamed:@"gray.png"]];
    }else if([info.status isEqualToString:@"未接受"]){
        [[cell statusView]setImage:[UIImage imageNamed:@"red.png"]];
    }
    [[cell taskName]setText:info.missionTitle];
    [[cell taskGroup]setText:info.missionGroup];
    [[cell time]setText:info.time];
    
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

-(void)getNotificationInfo:(int)pageNo pageSize:(int)pageSize{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    
    
    dispatch_async(kBgQueue, ^{
        NSDictionary *dic = [MicroAidAPI fetchNotification:userID pageNo:pageNo pageSize:pageSize];
        
        if ([[dic objectForKey:@"onError"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"获取数据失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
            return;
        } else {
            _notificationInfoArray = [NotificationInfo getNotificationInfos:[dic objectForKey:@"notifications"]];
            if ([_notificationInfoArray count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.count == 1){
                        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"您没有通知!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                    }else{
                        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"没有更多了!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(self.count == 1){
                    [self.dataArray removeAllObjects];
                }
                [self.dataArray addObjectsFromArray:self.notificationInfoArray];
                [self.pullTableView reloadData];
            });
            
        }
    });
}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

- (void) successWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.view endEditing:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showSuccess:message];
}

@end
