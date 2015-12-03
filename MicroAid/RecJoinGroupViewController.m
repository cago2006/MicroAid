//
//  RecJoinGroupViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/11/10.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import "RecJoinGroupViewController.h"
#import "ViewGroupViewController.h"
#import "MicroAidAPI.h"
#import "User.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface RecJoinGroupViewController ()

@end

@implementation RecJoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(saveChange) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    //多选
    self.pullTableView.allowsMultipleSelectionDuringEditing = YES;
    [self.pullTableView setEditing:YES animated:YES];
    
    self.dataArray = [[NSMutableArray alloc] init];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.count = 1;
    //self.dataArray = [[NSMutableArray alloc]initWithCapacity:10];
    [self getUnjoinedUserInfo:self.count pageSize:20];
    self.tabBarController.tabBar.hidden = YES;
}

-(void)saveChange{
    
    [self.view setUserInteractionEnabled:false];
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    NSArray *selectedRows = [self.pullTableView indexPathsForSelectedRows];
    BOOL choosedSpecificRows = selectedRows.count > 0;
    if (choosedSpecificRows)
    {
        NSString *choosedID = [[NSString alloc]init];
        choosedID = [choosedID stringByAppendingString:@"["];
        for (NSIndexPath *selectionIndex in selectedRows){
            User *user = [self.dataArray objectAtIndex:selectionIndex.row];
            choosedID = [choosedID stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)user.userID]];
            choosedID = [choosedID stringByAppendingString:@","];
        }
        choosedID = [choosedID substringToIndex:choosedID.length-1];
        choosedID = [choosedID stringByAppendingString:@"]"];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *phoneNumber = [userDefaults objectForKey:@"username"];
        
        [ProgressHUD show:@"正在邀请..."];
        dispatch_async(serverQueue, ^{
            
            
            NSDictionary *resultDic = [MicroAidAPI joinGroup:self.groupName applicantName:phoneNumber userIDs:choosedID];
            if ([[resultDic objectForKey:@"flg"] boolValue]) {//邀请成功
                [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"邀请加入成功!" waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(returnToViewGroup) withObject:nil waitUntilDone:YES];
            }else{//邀请失败
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"邀请加入失败,请检查网络!" waitUntilDone:YES];
                return ;
            }
        });
        
    }
}

-(void)returnToViewGroup{
    ViewGroupViewController *vgVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    [self.navigationController popToViewController:vgVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.  刷新代码放在这
     
     */
    self.count = 1;
    //[self.dataArray removeAllObjects];
    [self getUnjoinedUserInfo:self.count pageSize:20];
    
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.  加载更多实现代码放在在这
     
     */
    self.count++;
    [self getUnjoinedUserInfo:self.count pageSize:20];
    
    self.pullTableView.pullTableIsLoadingMore = NO;
    
}

-(void)getUnjoinedUserInfo:(int)pageNo pageSize:(int)pageSize{
    
    dispatch_async(kBgQueue, ^{
        NSDictionary *userInfo = [MicroAidAPI getUnjoinedUser:self.groupName pageNo:pageNo pageSize:pageSize];
        
        if ([[userInfo objectForKey:@"onError"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"获取数据失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
            return;
        } else {
            //[self.userInfoArray removeAllObjects];
            _userInfoArray = [User getUserInfos:[userInfo objectForKey:@"unjoinedUser"]];
            if ([_userInfoArray count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.count == 1){
                        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"所有用户都已经加入该群组!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)",user.nickName,user.username];
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
