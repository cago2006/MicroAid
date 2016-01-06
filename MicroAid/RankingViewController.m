//
//  RankingViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/12/5.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import "RankingViewController.h"
#import "MicroAidAPI.h"
#import "ViewUserViewController.h"
#import "MyInfoViewController.h"
#import "RankingTableViewCell.h"
#import "User.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface RankingViewController ()

@end

@implementation RankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [self.navigationItem setTitle:@"排行榜"];

    //[addBtn release];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    

    self.dataArray = [[NSMutableArray alloc] init];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.count = 1;
    //self.dataArray = [[NSMutableArray alloc]initWithCapacity:10];
    [self getUserInfoOrderByScore:self.count pageSize:20];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.  刷新代码放在这
     
     */
    self.count = 1;
    //[self.dataArray removeAllObjects];
    [self getUserInfoOrderByScore:self.count pageSize:20];
    
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.  加载更多实现代码放在在这
     
     */
    self.count++;
    [self getUserInfoOrderByScore:self.count pageSize:20];
    
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
    
    User *info = [self.dataArray objectAtIndex:indexPath.row];
    
    if(userID == info.userID){
        MyInfoViewController *myInfoVC = [[MyInfoViewController alloc]initWithNibName:@"MyInfoViewController" bundle:nil];
        [self.navigationController pushViewController:myInfoVC animated:YES];
    }else{
        ViewUserViewController *viewUserVC = [[ViewUserViewController alloc]initWithNibName:@"ViewUserViewController" bundle:nil];
        viewUserVC.userID = info.userID;
        [self.navigationController pushViewController:viewUserVC animated:YES];
    }
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CustomCellIdentifier";
    
    RankingTableViewCell *cell = (RankingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"RankingTableViewCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    // cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    
    User *info = [self.dataArray objectAtIndex:indexPath.row];
    //[[cell title]setText:info.title];
    if(info.rank == 1){
        [cell.rankNum setTitle:@"" forState:UIControlStateNormal];
        [cell.rankNum setBackgroundImage:[UIImage imageNamed:@"gold_medal"] forState:UIControlStateNormal];
    }else if(info.rank == 2){
        [cell.rankNum setTitle:@"" forState:UIControlStateNormal];
        [cell.rankNum setBackgroundImage:[UIImage imageNamed:@"silver_medal"] forState:UIControlStateNormal];
    }else if(info.rank == 3){
        [cell.rankNum setTitle:@"" forState:UIControlStateNormal];
        [cell.rankNum setBackgroundImage:[UIImage imageNamed:@"copper_medal"] forState:UIControlStateNormal];
    }else{
        [cell.rankNum setTitle:[NSString stringWithFormat:@"%li",(long)info.rank] forState:UIControlStateNormal];
    }

    [[cell nickName]setText:info.nickName];
    [[cell score]setText:[NSString stringWithFormat:@"%li",(long)info.scores]];
    
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

-(void)getUserInfoOrderByScore:(int)pageNo pageSize:(int)pageSize{

    dispatch_async(kBgQueue, ^{
        NSDictionary *userInfo = [MicroAidAPI getUserInfoOrderByScore:pageNo pageSize:pageSize];
        
        if ([[userInfo objectForKey:@"onError"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"获取数据失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
            return;
        } else {
            //[self.userInfoArray removeAllObjects];
            _userInfoArray = [User getUserInfosByScore:[userInfo objectForKey:@"users"] pageNo:pageNo pageSize:pageSize];
            if ([_userInfoArray count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.count == 1){
                        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"没有用户!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
                [self.dataArray addObjectsFromArray:self.userInfoArray];
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
