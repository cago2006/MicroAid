//
//  GroupViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/29.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "GroupViewController.h"
#import "MicroAidAPI.h"
#import "ViewGroupViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface GroupViewController ()

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@",Localized(@"我的群组")]];
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithCustomView:addBtn];
    //[addBtn release];
    
    self.navigationItem.rightBarButtonItem = addItem;
    
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor whiteColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
    
    self.dataArray = [[NSMutableArray alloc] init];
    [self firstReflesh];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

-(void) firstReflesh{
    self.count = 1;
    //self.dataArray = [[NSMutableArray alloc]initWithCapacity:10];
    [self getGroupInfo:self.count pageSize:20];
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

-(void) createGroup{
    self.view.userInteractionEnabled = false;
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:Localized(@"创建新群组") message:Localized(@"请输入群组名称") delegate:self cancelButtonTitle:[NSString stringWithFormat:@"%@",Localized(@"取消")] otherButtonTitles:[NSString stringWithFormat:@"%@",Localized(@"添加")],nil];
    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    [dialog show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSString *groupName = [alertView textFieldAtIndex:0].text;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userName = [userDefaults objectForKey:@"username"];
        NSInteger userID = [userDefaults integerForKey:@"userID"];
        dispatch_async(serverQueue, ^{
            NSDictionary *resultDic = [MicroAidAPI createGroup:userID userName:userName groupName:groupName];
            if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
                [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:Localized(@"群组创建成功!") waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
            }else//创建失败
            {
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:Localized(@"群组创建失败,请检查网络!") waitUntilDone:YES];
                return ;
            }
        });
    }
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    
}

- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.  刷新代码放在这
     
     */
    [self.dataArray removeAllObjects];
    self.count = 1;
    //[self.dataArray removeAllObjects];
    [self getGroupInfo:self.count pageSize:20];
    
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.  加载更多实现代码放在在这
     
     */
    self.count++;
    [self getGroupInfo:self.count pageSize:20];
    
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
    NSString *groupName = [self.dataArray objectAtIndex:indexPath.row];
    ViewGroupViewController *viewGroupVC = [[ViewGroupViewController alloc]initWithNibName:@"ViewGroupViewController" bundle:nil];
    
    viewGroupVC.groupName = groupName;
    
    self.tabBarController.tabBar.hidden = YES;
    
    [self.navigationController pushViewController:viewGroupVC animated:YES];
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
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

-(void)getGroupInfo:(int)pageNo pageSize:(int)pageSize{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    
    
    dispatch_async(kBgQueue, ^{
        NSDictionary *groupInfo = [MicroAidAPI fetchAllGroup:userID pageNo:pageNo pageSize:pageSize];
        
        if ([[groupInfo objectForKey:@"onError"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:Localized(@"获取数据失败") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
            return;
        } else {
            [self.groupInfoArray removeAllObjects];
            if ([[groupInfo objectForKey:@"flg"] boolValue]) {//获取成功
                NSArray *list = [groupInfo objectForKey:@"groupInfoList"];
                self.groupInfoArray = [NSMutableArray arrayWithCapacity:[list count]];
                for(int i =0; i<[list count]; i++){
                    NSString *groupName =(NSString *)[list objectAtIndex:i];
                    [self.groupInfoArray addObject:groupName];
                }
            }
            if ([_groupInfoArray count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.count == 1){
//                        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"您没有加入任何群组!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                        [alertView show];
                        [self showMessage:Localized(@"您没有加入任何群组!")];
                    }else{
//                        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"没有更多了!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                        [alertView show];
                        [self showMessage:Localized(@"没有更多了!")];
                    }
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.count == 1){
                    [self.dataArray removeAllObjects];
                }
                [self.dataArray addObjectsFromArray:self.groupInfoArray];
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

-(void)showMessage:(NSString *)message
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    CGSize LabelSize = [message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(290, 9000)];
    label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [showview addSubview:label];
    showview.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - LabelSize.width - 20)/2, [[UIScreen mainScreen] bounds].size.height - 100, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:1.5 animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}

@end
