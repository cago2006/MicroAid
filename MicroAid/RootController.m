//
//  RootController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/24.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "RootController.h"
#import "MicroAidAPI.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "MainTabBarController.h"

@interface RootController ()

@property(nonatomic, strong) LoginViewController *loginViewController;
@property(nonatomic, strong) UINavigationController *homeNavigationViewController;
@property(nonatomic, strong) MainTabBarController *mainTabBarController;

@end

@implementation RootController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //获取setting中设置的URL
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ipAddr = [defaults stringForKey:@"ipAddr"];
    if (ipAddr==nil || [ipAddr isEqualToString:@""])
    {
        ipAddr =  @"218.193.130.169:8080";
    }
    NSLog(@"IP : %@", ipAddr);
    [MicroAidAPI setIpAddr:@"218.193.130.169:8080"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults stringForKey:@"username"];
    NSString *password = [userDefaults stringForKey:@"password"];
    NSLog(@"userName=%@,password=%@",username,password);
    if ((username != nil)&&(password != nil)&&!([username isEqualToString:@""]) && !([password isEqualToString:@""])) {
        //如果已登陆
        HomeViewController *homeVC = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
        self.homeNavigationViewController = [[UINavigationController alloc]initWithRootViewController:homeVC];
        [self.homeNavigationViewController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
        [self.view addSubview:self.homeNavigationViewController.view];
        
    } else {
        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.view addSubview:self.loginViewController.view];
    }
}

//从login界面到homeview界面
- (void)switchToHomeViewFromLoginView
{
    
    [self.loginViewController.view removeFromSuperview];
    self.loginViewController = nil;
    
    HomeViewController *homeVC = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    self.homeNavigationViewController = [[UINavigationController alloc]initWithRootViewController:homeVC];
    [self.homeNavigationViewController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    [self.view addSubview:self.homeNavigationViewController.view];
    
}

//从homeview到login界面
-(void) switchToLoginViewFromHomeView
{
    [self.homeNavigationViewController.view removeFromSuperview];
    self.homeNavigationViewController = nil;
    
    self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.view addSubview:self.loginViewController.view];
}

//从homeview到主界面
-(void) switchToMainTabViewFromHomeView
{
    //TODO
    [self.homeNavigationViewController.view removeFromSuperview];
    self.homeNavigationViewController = nil;
    
    /*
    MainTabBarController *mainTBC = [[MainTabBarController alloc] init];
    self.mainTabBarNavifationController = [[UINavigationController alloc]initWithRootViewController:mainTBC];
    [self.mainTabBarNavifationController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    [self.view addSubview:self.mainTabBarNavifationController.view];*/
    
    
    self.mainTabBarController = [[MainTabBarController alloc]init];
    [self.view addSubview:self.mainTabBarController.view];
    
    //navigation

}


//从主界面到login界面
- (void)switchToLoginViewFromMainTab
{
    
    //TODO
    
    //[self.navigationViewController.view removeFromSuperview];
    //self.navigationViewController = nil;
    [self.mainTabBarController.view removeFromSuperview];
    self.mainTabBarController = nil;
    
    self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.view addSubview:self.loginViewController.view];
    //[self.view.window.rootViewController presentViewController:self.loginViewController animated:NO completion:nil];

    
}

-(void) switchToHomeViewFromMainTab{
    [self.mainTabBarController.view removeFromSuperview];
    self.mainTabBarController = nil;
    
    HomeViewController *homeVC = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    self.homeNavigationViewController = [[UINavigationController alloc]initWithRootViewController:homeVC];
    [self.homeNavigationViewController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    [self.view addSubview:self.homeNavigationViewController.view];
}


@end
