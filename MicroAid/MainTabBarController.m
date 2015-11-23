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
    
    self.viewControllers=@[missionNav,groupNav,notifyNav,mineNav];
    
//    missionNav = nil;
//    missionVC = nil;
//    groupNav = nil;
//    groupVC = nil;
//    notifyNav = nil;
//    notifyVC = nil;
//    mineNav = nil;
//    mineVC = nil;
}

-(void) viewWillDisappear:(BOOL)animated{
    self.viewControllers = nil;
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    self.viewControllers = nil;
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    self.viewControllers = nil;
    // Dispose of any resources that can be recreated.
}



@end
