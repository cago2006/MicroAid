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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.count = 1;
    self.dataArray = [[NSMutableArray alloc]initWithCapacity:10];
    [self getNotificationInfo:self.count pageSize:20];
    self.tabBarController.tabBar.hidden = NO;
}


- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.  刷新代码放在这
     
     */
    self.count = 1;
    [self.dataArray removeAllObjects];
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
    return 99;
}

//点击显示具体信息，首先进行判断
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NotificationInfo *info = [self.dataArray objectAtIndex:indexPath.row];
    [self successWithMessage:[NSString stringWithFormat:@"%li selected",info.missionID-1]];
//    NSString *groupName = [self.dataArray objectAtIndex:indexPath.row];
//    ViewGroupViewController *viewGroupVC = [[ViewGroupViewController alloc]initWithNibName:@"ViewGroupViewController" bundle:nil];
//    
//    viewGroupVC.groupName = groupName;
//    
//    self.tabBarController.tabBar.hidden = YES;
//    
//    [self.navigationController pushViewController:viewGroupVC animated:YES];
    
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
    [[cell title]setText:[NSString stringWithFormat:@"%@ %li",info.title,info.missionID-1]];
    [[cell taskName]setText:[NSString stringWithFormat:@"%@ %li",info.missionTitle,info.missionID-1]];
    [[cell taskGroup]setText:[NSString stringWithFormat:@"%@ %li",info.missionGroup,info.missionID-1]];
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
    
    
    //test
    for(int i = 0 ; i<10;i++){
        NotificationInfo *info = [[NotificationInfo alloc]init];
        info.notificationID = i+1;
        info.missionID = i+1;
        info.userID = i+1;
        info.title = @"title";
        info.missionTitle = @"missionTitle";
        info.missionGroup = @"missionGroup";
        info.time = @"2010-01-01 08:30";
        [self.dataArray addObject:info];
    }
    
    //end test
    
    
//    dispatch_async(kBgQueue, ^{
//        NSDictionary *groupInfo = [MicroAidAPI fetchAllGroup:userID pageNo:pageNo pageSize:pageSize];
//        
//        if ([[groupInfo objectForKey:@"onError"] boolValue]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"获取数据失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alertView show];
//            });
//            return;
//        } else {
//            [self.notificationInfoArray removeAllObjects];
//            if ([[groupInfo objectForKey:@"flg"] boolValue]) {//获取成功
//                NSArray *list = [groupInfo objectForKey:@"groupInfoList"];
//                self.notificationInfoArray = [NSMutableArray arrayWithCapacity:[list count]];
//                for(int i =0; i<[list count]; i++){
//                    NSString *groupName =(NSString *)[list objectAtIndex:i];
//                    [self.notificationInfoArray addObject:groupName];
//                }
//            }
//            if ([_notificationInfoArray count] == 0) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if(self.count == 1){
//                        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"您没有通知!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                        [alertView show];
//                    }else{
//                        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"没有更多了!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                        [alertView show];
//                    }
//                });
//                return;
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.dataArray addObjectsFromArray:self.notificationInfoArray];
//                [self.pullTableView reloadData];
//            });
//            
//        }
//    });
}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

- (void) successWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [ProgressHUD showSuccess:message];
}

@end