//
//  StartedMissionsViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/21.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "StartedMissionsViewController.h"
#import "MicroAidAPI.h"
#import "MissionInfo.h"
#import "MissionListCell.h"
#import "MyMissionsViewController.h"
#import "CreateMissionViewController.h"
#import "ViewMissionViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface StartedMissionsViewController ()

@end

@implementation StartedMissionsViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        
        
    }
    return self;
}

-(void) setParentNav:(UINavigationController *)parentNavController{
    self.parentNavController = parentNavController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden = YES;
    
    // Do any additional setup after loading the view from its nib.
    self.count = 1;
    self.dataArray = [[NSMutableArray alloc]initWithCapacity:10];
    [self fetchMissionInfo:self.count pageSize:100];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.dataArray = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if(info.userId == userID && [info.statusInfo isEqualToString:@"未接受"]){
        CreateMissionViewController *cmVC = [[CreateMissionViewController alloc]initWithNibName:@"CreateMissionViewController" bundle:nil];
        
        self.tabBarController.tabBar.hidden = YES;
        cmVC.isEditMission = YES;
        cmVC.missionID = info.missionId;
        cmVC.isFromMyMission = YES;
        [self.parentNavController pushViewController:cmVC animated:YES];
    }else{
        ViewMissionViewController *viewMissionVC =[[ViewMissionViewController alloc]initWithNibName:@"ViewMissionViewController" bundle:nil];
        if([info.statusInfo isEqualToString:@"未接受"]){
            viewMissionVC.isAccepted = NO;
        }else{
            viewMissionVC.isAccepted = YES;
        }
        viewMissionVC.missionDistance = info.distance;
        viewMissionVC.missionID = info.missionId;
        self.tabBarController.tabBar.hidden = YES;
        [self.parentNavController pushViewController:viewMissionVC animated:YES];
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


-(void)fetchMissionInfo:(int)pageNo pageSize:(int)pageSize{
    
    NSArray *statusArray = [NSArray arrayWithObjects:@"0",@"1", nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    double latitude = [userDefaults doubleForKey:@"latitude"];
    double longitude = [userDefaults doubleForKey:@"longitude"];
    
    dispatch_async(kBgQueue, ^{
        NSDictionary *finishedMissions = [MicroAidAPI getMissionList2:userID recUserID:0 statusList:statusArray longitude:longitude latitude:latitude pageNo:pageNo pageSize:pageSize];
        
        if ([[finishedMissions objectForKey:@"onError"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"获取数据失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
            return;
        } else {
            _missionInfoArray = [MissionInfo getMissionInfos:[finishedMissions objectForKey:@"taskInfoList"]];
            if ([_missionInfoArray count] == 0) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataArray addObjectsFromArray:self.missionInfoArray];
                [self.pullTableView reloadData];
            });
        }
    });
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
