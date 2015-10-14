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
    
    self.selectedIndex = 2;
    
    
    NSLog(@"index:%i",self.currentIndex);
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

@end
