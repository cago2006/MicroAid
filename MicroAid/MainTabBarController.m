//
//  MainTabBarController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/29.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//
#import "RootController.h"
#import "MainTabBarController.h"
#import "MissionViewController.h"
#import "GroupViewController.h"
#import "NotificationViewController.h"
#import "MineViewController.h"
#import "RankingViewController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    MissionViewController *missionVC=[[MissionViewController alloc]initWithNibName:@"MissionViewController" bundle:nil];
    //missionNav.tabBarItem.badgeValue=@"123";//通知数目
    UINavigationController *missionNav = [[UINavigationController alloc]initWithRootViewController:missionVC];
    [missionNav.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    missionNav.title = @"任务";
    missionNav.tabBarItem.image = [UIImage imageNamed:@"menu_mission"];
    
    GroupViewController *groupVC=[[GroupViewController alloc]initWithNibName:@"GroupViewController" bundle:nil];
    //groupNav.view.backgroundColor=[UIColor brownColor];//背景颜色
    UINavigationController *groupNav = [[UINavigationController alloc]initWithRootViewController:groupVC];
    [groupNav.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    groupNav.title = @"群组";
    groupNav.tabBarItem.image = [UIImage imageNamed:@"menu_group"];
    
    
    NotificationViewController *notifyVC=[[NotificationViewController alloc]initWithNibName:@"NotificationViewController" bundle:nil];
    //groupNav.view.backgroundColor=[UIColor brownColor];//背景颜色
    UINavigationController *notifyNav = [[UINavigationController alloc]initWithRootViewController:notifyVC];
    [notifyNav.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    notifyNav.title = @"通知";
    notifyNav.tabBarItem.image = [UIImage imageNamed:@"menu_notification"];
    
    MineViewController *mineVC=[[MineViewController alloc]initWithNibName:@"MineViewController" bundle:nil];
    //groupNav.view.backgroundColor=[UIColor brownColor];//背景颜色
    UINavigationController *mineNav = [[UINavigationController alloc]initWithRootViewController:mineVC];
    [mineNav.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    mineNav.title = @"我";
    mineNav.tabBarItem.image = [UIImage imageNamed:@"menu_mine"];
    
    RankingViewController *rankVC=[[RankingViewController alloc]initWithNibName:@"RankingViewController" bundle:nil];
    //groupNav.view.backgroundColor=[UIColor brownColor];//背景颜色
    UINavigationController *rankNav = [[UINavigationController alloc]initWithRootViewController:rankVC];
    [rankNav.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    rankNav.title = @"排行";
    rankNav.tabBarItem.image = [UIImage imageNamed:@"menu_rank"];
    
    
    NSArray *controllers = [NSArray arrayWithObjects:missionNav,groupNav,rankNav,notifyNav,mineNav,nil];
    
    self.viewControllers=controllers;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
