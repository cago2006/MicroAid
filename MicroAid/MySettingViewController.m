//
//  MySettingViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/12/3.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import "MySettingViewController.h"
#import "MicroAidAPI.h"
#import "SettingBonusTVC.h"
#import "SettingGroupTVC.h"
#import "SettingTypeTVC.h"
#import "MainTabBarController.h"

@interface MySettingViewController ()

@end

@implementation MySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"设置默认值"];
    //self.tabBarController.tabBar.hidden = YES;
    
    UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveFilter) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    //[saveBtn release];
    
    
    NSArray *itemArray=[[NSArray alloc]initWithObjects:saveItem, nil];

    [self.navigationItem setRightBarButtonItems:itemArray];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.missionGroup = [userDefaults objectForKey:@"defaultMissionGroup"];
    self.missionBonus = [userDefaults objectForKey:@"defaultMissionBonus"];
    self.missionType = [userDefaults objectForKey:@"defaultMissionType"];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.missionGroup == nil || [self.missionGroup isEqualToString:@""]){
        self.missionGroup = @"公开";
    }
    [objectBtn setTitle:self.missionGroup forState:UIControlStateNormal];
    if(self.missionBonus == nil || [self.missionBonus isEqualToString:@""]){
        self.missionBonus = @"0分";
    }
    [bonusBtn setTitle:self.missionBonus forState:UIControlStateNormal];
    
    if(self.missionType == nil || [self.missionType isEqualToString:@""]){
        self.missionType = @"拿快递";
    }
    [typeBtn setTitle:self.missionType forState:UIControlStateNormal];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) buttonClicked:(UIButton *)sender{
    switch (sender.tag) {
        case 0:
        {
            self.view.userInteractionEnabled = false;
            [self.navigationController.navigationBar setUserInteractionEnabled:false];
            dispatch_async(serverQueue, ^{
                NSDictionary *resultDic = [MicroAidAPI fetchAllExcel];
                if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
                    NSArray *list = [resultDic objectForKey:@"excelList"];
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[list count]+1];
                    for(int i =0; i<[list count]; i++){
                        NSDictionary *subList = [list objectAtIndex:i];
                        NSString *taskType =(NSString *)[subList objectForKey:@"taskType"];
                        [array addObject:taskType];
                    }
                    //显示
                    [self performSelectorOnMainThread:@selector(openTypeView:) withObject:array waitUntilDone:YES];
                    
                }else//获取失败
                {
                    [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败,请检查网络!" waitUntilDone:YES];
                    return ;
                }
            });
            break;
        }
        case 1:
        {
            SettingBonusTVC *bonusVC = [[SettingBonusTVC alloc] initWithNibName:@"SettingBonusTVC" bundle:nil];
            
            bonusVC.bonusString = self.missionBonus;
            
            [self.navigationController pushViewController:bonusVC animated:YES];
            break;
        }
        case 2:
        {
            self.view.userInteractionEnabled = false;
            [self.navigationController.navigationBar setUserInteractionEnabled:false];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSInteger userID = [userDefaults integerForKey:@"userID"];
            
            dispatch_async(serverQueue, ^{
                NSDictionary *resultDic = [MicroAidAPI fetchAllGroup:userID pageNo:1 pageSize:10];
                if ([[resultDic objectForKey:@"onError"] boolValue]) {//获取成功
                    [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败,请检查网络!" waitUntilDone:YES];
                    return ;
                }else//获取失败
                {
                    if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
                        NSArray *list = [resultDic objectForKey:@"groupInfoList"];
                        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[list count]];
                        [array addObject:@"公开"];
                        for(int i =0; i<[list count]; i++){
                            NSString *groupName =(NSString *)[list objectAtIndex:i];
                            [array addObject:groupName];
                        }
                        //显示
                        [self performSelectorOnMainThread:@selector(openGroupView:) withObject:array waitUntilDone:YES];
                    }else{
                        NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
                        [array addObject:@"全部"];
                        [array addObject:@"公开"];
                        //显示
                        [self performSelectorOnMainThread:@selector(openGroupView:) withObject:array waitUntilDone:YES];
                    }
                }
            });
            break;
        }
        default:
            break;
    }
}


-(void) openTypeView:(NSMutableArray *)array{
    SettingTypeTVC *typeVC = [[SettingTypeTVC alloc] initWithNibName:@"SettingTypeTVC" bundle:nil];
    
    typeVC.dataArray = array;
    typeVC.typeString = self.missionType;
    
    [self.navigationController pushViewController:typeVC animated:YES];
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
}

-(void) openGroupView:(NSMutableArray *)array{
    SettingGroupTVC *groupVC = [[SettingGroupTVC alloc] initWithNibName:@"SettingGroupTVC" bundle:nil];
    
    groupVC.dataArray = array;
    groupVC.groupString = self.missionGroup;
    
    [self.navigationController pushViewController:groupVC animated:YES];
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}


-(void)saveFilter{

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.missionGroup forKey:@"defaultMissionGroup"];
    [userDefaults setObject:self.missionBonus forKey:@"defaultMissionBonus"];
    [userDefaults setObject:self.missionType forKey:@"defaultMissionType"];
    [userDefaults synchronize];
    
    //    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
    //    [rootController switchToMainTabViewFromHomeView];
    MainTabBarController *mainTBC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    [self.navigationController popToViewController:mainTBC animated:YES];
}

@end
