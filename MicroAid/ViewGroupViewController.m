//
//  ViewGroupViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/17.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "ViewGroupViewController.h"
#import "MicroAidAPI.h"
#import "GroupViewController.h"
#import "RecJoinGroupViewController.h"
#import "MyInfoViewController.h"
#import "ViewUserViewController.h"
#import "UserTableViewCell.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface ViewGroupViewController ()

@end

@implementation ViewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(joinGroup) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithCustomView:addBtn];
    //[addBtn release];
    
    UIButton *exitBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [exitBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exitGroup) forControlEvents:UIControlEventTouchUpInside];
    [exitBtn setBackgroundImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
    UIBarButtonItem *exitItem = [[UIBarButtonItem alloc]initWithCustomView:exitBtn];
    //[filterBtn release];
    
    
    NSArray *itemArray=[[NSArray alloc]initWithObjects:exitItem,addItem, nil];

    [self.navigationItem setRightBarButtonItems:itemArray];
    
    self.dataArray = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self getGroupInfo];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)exitGroup{
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:Localized(@"确定要退出该群?") message:nil delegate:self cancelButtonTitle:Localized(@"取消") otherButtonTitles:Localized(@"确定"),nil];
    [dialog setAlertViewStyle:UIAlertViewStyleDefault];
    [dialog show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [ProgressHUD show:Localized(@"正在退出...")];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger userID = [userDefaults integerForKey:@"userID"];
        dispatch_async(serverQueue, ^{
            NSDictionary *resultDic = [MicroAidAPI exitGroup:userID groupName:self.groupName];
            if ([[resultDic objectForKey:@"flg"] boolValue]) {//退出成功
                [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:Localized(@"退出成功!") waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(returnToGroupList) withObject:nil waitUntilDone:YES];
            }else{//退出失败
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:Localized(@"退出失败,请检查网络!") waitUntilDone:YES];
                return ;
            }
        });
    }
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    
}

-(void)returnToGroupList{
    GroupViewController *groupVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    [self.navigationController popToViewController:groupVC animated:YES];
    
}

-(void)joinGroup{
    RecJoinGroupViewController *rjgVC = [[RecJoinGroupViewController alloc]initWithNibName:@"RecJoinGroupViewController" bundle:nil];
    rjgVC.groupName = self.groupName;
    [self.navigationController pushViewController:rjgVC animated:YES];
}

-(void) getGroupInfo{
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI getGroupInfo:self.groupName];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//查找成功
            NSDictionary *dic = [resultDic objectForKey:@"group"];
            [self performSelectorOnMainThread:@selector(showGroupInfo:) withObject:dic waitUntilDone:YES];
        }else//查找失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:Localized(@"查找失败,请检查网络!") waitUntilDone:YES];
            return ;
        }
    });
}

-(void) showGroupInfo:(NSDictionary *)dic{
    self.groupCreateTime = [dic objectForKey:@"creatTime"];
    self.groupMembers = [[dic objectForKey:@"size"]integerValue];
    self.groupCreatorNickName = [dic objectForKey:@"creatorNickName"];
    self.groupID = [[dic objectForKey:@"size"]integerValue];
    self.groupCreator = [dic objectForKey:@"creator"];
    
    //title
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@(%li)",self.groupName,(long)self.groupMembers]];
    [self getJoinedUserInfo:1 pageSize:999];
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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([[userDefaults objectForKey:@"defaultMissionGroup"] isEqualToString:self.groupName]){
        [userDefaults setObject:@"公开" forKey:@"defaultMissionGroup"];
        [userDefaults synchronize];
    }
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
    
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    if([user.username isEqualToString:self.groupCreator]){
        MyInfoViewController *myInfoVC = [[MyInfoViewController alloc]initWithNibName:@"MyInfoViewController" bundle:nil];
        [self.navigationController pushViewController:myInfoVC animated:YES];
    }else{
        ViewUserViewController *viewUserVC = [[ViewUserViewController alloc]initWithNibName:@"ViewUserViewController" bundle:nil];
        viewUserVC.userID = user.userID;
        [self.navigationController pushViewController:viewUserVC animated:YES];
    }
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CustomCellIdentifier";
    
    UserTableViewCell *cell = (UserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"UserTableViewCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    // cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    //[[cell title]setText:info.title];
    if([user.username isEqualToString:self.groupCreator]){
        [[cell creatorTag]setImage:[UIImage imageNamed:@"creator.png"]];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)",user.nickName,user.username];
    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


-(void)getJoinedUserInfo:(int)pageNo pageSize:(int)pageSize{
    
    dispatch_async(kBgQueue, ^{
        NSDictionary *userInfo = [MicroAidAPI getJoinedUser:self.groupName pageNo:pageNo pageSize:pageSize];
        
        if ([[userInfo objectForKey:@"onError"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:Localized(@"获取数据失败") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
            return;
        } else {
            //[self.userInfoArray removeAllObjects];
            _userInfoArray = [User getUserInfos:[userInfo objectForKey:@"joinedUser"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:self.userInfoArray];
                [self orderDataArray];
                [self.myTableView reloadData];
            });
            
        }
    });
}

-(void) orderDataArray{
    for(int index = 0; index < [self.dataArray count]; index++){
        User *temp = [self.dataArray objectAtIndex:index];
        if([temp.username isEqualToString:self.groupCreator]){
            [self.dataArray removeObjectAtIndex:index];
            [self.dataArray insertObject:temp atIndex:0];
            break;
        }
    }
}


@end
