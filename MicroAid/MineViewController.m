//
//  MineViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/29.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "MineViewController.h"
#import "RootController.h"
#import "MyInfoCell.h"
#import "ModPasswordViewController.h"
#import "MyInfoViewController.h"
#import "GTMBase64.h"
#import "MicroAidAPI.h"
#import "MyMissionsViewController.h"
#import "MySettingViewController.h"
#import "RankingViewController.h"

@interface MineViewController ()

@end

@implementation MineViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        [self findUser];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [self.navigationItem setTitle:@"我"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.userName = [userDefaults objectForKey:@"username"];
    self.nickName = [userDefaults objectForKey:@"nickName"];
    [_myTableView reloadData];
    [self findUser];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _imageView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void) findUser{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    
    dispatch_sync(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI fetchPicture:userID];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
            NSData *picture = [resultDic objectForKey:@"picture"];
            [self performSelectorOnMainThread:@selector(showPicture:) withObject:picture waitUntilDone:YES];
        }else if ([[resultDic objectForKey:@"onError"] boolValue])//创建失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"头像查找失败！" waitUntilDone:YES];
            return ;
        }else{
            [self performSelectorOnMainThread:@selector(showPicture:) withObject:nil waitUntilDone:YES];
        }
    });
}

-(void) showPicture:(NSString *)picture{
    if(picture == nil){
        self.imageView = [UIImage imageNamed:@"default_pic"];
    }else{
        //需要转换了才能用
        NSString *formatedString = [picture stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSData *imageData = [GTMBase64 decodeString:formatedString];
        self.imageView = [UIImage imageWithData:imageData scale:0.0];
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 || section ==2){
        return 1;
    }else{
        return 4;
    }
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 84;
    }
    return 44;
}
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 17;
}
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 17;
}

//点击显示具体信息，首先进行判断
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    long section = indexPath.section;
    long row = indexPath.row;
    self.tabBarController.tabBar.hidden = YES;
    switch(section){
        case 0:{
            MyInfoViewController *myInfoVC = [[MyInfoViewController alloc]initWithNibName:@"MyInfoViewController" bundle:nil];
            
            [self.navigationController pushViewController:myInfoVC animated:YES];
            break;
        }
        case 1:{
            if(row == 0){//我的任务
                MyMissionsViewController *myMissionsVC = [[MyMissionsViewController alloc]initWithNibName:@"MyMissionsViewController" bundle:nil];
                [self.navigationController pushViewController:myMissionsVC animated:YES];
            }
            else if(row == 1){//修改密码
                ModPasswordViewController *modPasswordVC = [[ModPasswordViewController alloc]initWithNibName:@"ModPasswordViewController" bundle:nil];
                
                [self.navigationController pushViewController:modPasswordVC animated:YES];
            }else if(row == 2){//设置
                MySettingViewController *mySettingVC = [[MySettingViewController alloc]initWithNibName:@"MySettingViewController" bundle:nil];
                [self.navigationController pushViewController:mySettingVC animated:YES];
            }else if(row == 3){//排行榜
                RankingViewController *rankingVC = [[RankingViewController alloc]initWithNibName:@"RankingViewController" bundle:nil];
                [self.navigationController pushViewController:rankingVC animated:YES];
            }
            break;
        }
        case 2:{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *dictionary = [userDefaults dictionaryRepresentation];
            for(NSString* key in [dictionary allKeys]){
                [userDefaults removeObjectForKey:key];
                [userDefaults synchronize];
            }
            RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
            [rootController switchToLoginViewFromMainTab];
            break;
        }
        default:
            break;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CustomCellIdentifier";
    
    long section = indexPath.section;
    
    if(section == 0){
        MyInfoCell *cell = (MyInfoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil) {
            NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"MyInfoCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        // cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
        [[cell portrait]setImage:self.imageView];
        [[cell userName]setText:self.userName];
        [[cell nickName]setText:self.nickName];
        cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }else if(section ==1){
        static NSString *kCellID = @"cellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        }
        if(indexPath.row == 0){
            cell.textLabel.text = @"我的任务";
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"修改密码";
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"设置";
        }else if(indexPath.row == 3){
            cell.textLabel.text = @"排行榜";
        }
        
        cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }else{
        static NSString *kCellID = @"cellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        }
        cell.textLabel.text = @"登出";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor = [UIColor redColor];
        
        return cell;
    }

}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

@end
