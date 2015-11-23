//
//  LoginViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/26.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "LoginViewController.h"
#import "ProgressHUD.h"
#import "RootController.h"
#import "BPush.h"
#import "RegisterViewController.h"
#import "HomeViewController.h"
#import "MicroAidAPI.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)loginButtonClicked:(id)sender {
    
    NSString *username;
    NSString *password;
    
    username = [NSString stringWithString:usernameTextField.text];
    password = [NSString stringWithString:passwordTextField.text];
    
    
    //测试
    //[self switchNextViewController];
    
    //用来测试用的用户名密码
    if ([username isEqualToString:@""])
    {
        [ProgressHUD showError:@"用户名不能为空"];
        return;
    }
    if ([password isEqualToString:@""])
    {
        [ProgressHUD showError:@"密码不能为空"];
        return;
    }
    
    [ProgressHUD show:@"正在登录"];
    self.view.userInteractionEnabled = false;
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI MobileLogin:username password:password channelID:[BPush getChannelId]];
        
        if ([[resultDic objectForKey:@"userID"] integerValue] > 0 ) {
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setInteger:[[resultDic objectForKey:@"userID"] integerValue] forKey:@"userID"];
            [userDefaults setObject:username forKey:@"username"];
            [userDefaults setObject:password forKey:@"password"];
            NSDictionary *array = [resultDic objectForKey:@"user"];
            [userDefaults setObject:[array objectForKey:@"nickName"] forKey:@"nickName"];
            [userDefaults synchronize];
            
            [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"登录成功" waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(switchNextViewController) withObject:nil waitUntilDone:YES];
            return ;
        }
        else//登录出错
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"登录失败！" waitUntilDone:YES];
            return ;
        }
    });
    
}

-(void) viewWillDisappear:(BOOL)animated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    
    dispatch_async(serverQueue, ^{
        [MicroAidAPI updateChannelID:userID channelID:[BPush getChannelId]];
    });
    [super viewWillDisappear:animated];
}

//点击空白区域，键盘收起
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)registerUser:(UIButton *)sender {
    RegisterViewController *registerVC = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    
    //[self.view addSubview:registerVC.view];
    //[self.view.window.rootViewController presentViewController:registerVC animated:NO completion:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:registerVC];
    [nav.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    
    [registerVC.navigationItem setTitle:@"注册"];
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    
}

- (void) successWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.view endEditing:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showSuccess:message];
}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

- (void)switchNextViewController
{
    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
    [rootController switchToHomeViewFromLoginView];
}

@end
