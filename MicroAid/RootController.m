//
//  RootController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/24.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "RootController.h"
#import "MicroAidAPI.h"
#import "BPush.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "MainTabBarController.h"
#import "SPUtil.h"
#import "SPKitExample.h"

@interface RootController ()

@property(nonatomic, strong) LoginViewController *loginViewController;
@property(nonatomic, strong) UINavigationController *homeNavigationViewController;
//@property(nonatomic, strong) UINavigationController *conversationNavigationViewController;
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
        //ipAddr =  @"10.131.241.184:8080";
    }
    NSLog(@"IP : %@", ipAddr);
    [MicroAidAPI setIpAddr:@"218.193.130.169:8080"];
    //[MicroAidAPI setIpAddr:@"10.131.241.184:8080"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults stringForKey:@"username"];
    NSString *password = [userDefaults stringForKey:@"password"];
    bool isAgree = [userDefaults boolForKey:@"isAgreePolicy"];
    NSLog(@"userName=%@,password=%@",username,password);
    if (isAgree&&(username != nil)&&(password != nil)&&!([username isEqualToString:@""]) && !([password isEqualToString:@""])) {
        //如果已登陆,不用输入，直接登录
        dispatch_async(serverQueue, ^{
            NSDictionary *resultDic = [MicroAidAPI MobileLogin:username password:password channelID:[BPush getChannelId]];
            if ([[resultDic objectForKey:@"userID"] integerValue] > 0 ) {
                [self performSelectorOnMainThread:@selector(switchNextViewController) withObject:nil waitUntilDone:YES];
                return ;
            }
            else//登录出错
            {
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"登录失败,请检查网络!" waitUntilDone:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSDictionary *dictionary = [userDefaults dictionaryRepresentation];
                    for(NSString* key in [dictionary allKeys]){
                        [userDefaults removeObjectForKey:key];
                        [userDefaults synchronize];
                    }
                    if(self.loginViewController == nil){
                       self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                    }
                    [self.view addSubview:self.loginViewController.view];
                    return ;
                });
                return ;
            }
        });
    } else {
        if(self.loginViewController == nil){
            self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        }
        [self.view addSubview:self.loginViewController.view];
    }
}

-(void)switchNextViewController{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    
    dispatch_async(serverQueue, ^{
        [MicroAidAPI updateChannelID:userID channelID:[BPush getChannelId]];
    });
    
    [self _tryLogin];
    //如果已登陆
    if(self.homeNavigationViewController == nil){
        HomeViewController *homeVC = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
        self.homeNavigationViewController = [[UINavigationController alloc]initWithRootViewController:homeVC];
        [self.homeNavigationViewController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    }
    [self.view addSubview:self.homeNavigationViewController.view];
}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

//从login界面到homeview界面
- (void)switchToHomeViewFromLoginView
{
    [self.loginViewController.view removeFromSuperview];
    //self.loginViewController = nil;
    if(self.homeNavigationViewController == nil){
        HomeViewController *homeVC = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
        self.homeNavigationViewController = [[UINavigationController alloc]initWithRootViewController:homeVC];
        [self.homeNavigationViewController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    }
    [self.view addSubview:self.homeNavigationViewController.view];
    
}

//从homeview到login界面
-(void) switchToLoginViewFromHomeView
{
    [self.homeNavigationViewController.view removeFromSuperview];
    self.homeNavigationViewController = nil;
    self.loginViewController = nil;
    self.mainTabBarController = nil;
    if(self.loginViewController==nil){
       self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }
    [self.view addSubview:self.loginViewController.view];
}

//从homeview到主界面
-(void) switchToMainTabViewFromHomeView
{
    //TODO
    [self.homeNavigationViewController.view removeFromSuperview];
    //self.homeNavigationViewController = nil;
    
    /*
    MainTabBarController *mainTBC = [[MainTabBarController alloc] init];
    self.mainTabBarNavifationController = [[UINavigationController alloc]initWithRootViewController:mainTBC];
    [self.mainTabBarNavifationController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    [self.view addSubview:self.mainTabBarNavifationController.view];*/
    
    if(self.mainTabBarController == nil){
        self.mainTabBarController = [[MainTabBarController alloc]init];
    }
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
    //self.mainTabBarController.viewControllers = nil;
    self.mainTabBarController = nil;
    
    if(self.loginViewController == nil){
        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }
    [self.view addSubview:self.loginViewController.view];
    //[self.view.window.rootViewController presentViewController:self.loginViewController animated:NO completion:nil];

    
}

-(void) switchToHomeViewFromMainTab{
    [self.mainTabBarController.view removeFromSuperview];
    //self.mainTabBarController.viewControllers = nil;
    //self.mainTabBarController = nil;
    
    if(self.homeNavigationViewController == nil){
        HomeViewController *homeVC = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
        self.homeNavigationViewController = [[UINavigationController alloc]initWithRootViewController:homeVC];
        [self.homeNavigationViewController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    }
    [self.view addSubview:self.homeNavigationViewController.view];
}

//-(void) switchToListFromMainTab:(YWConversationListViewController *)conversationListController{
//    [self.mainTabBarController.view removeFromSuperview];
//    
//    if(self.conversationNavigationViewController == nil){
//        self.conversationNavigationViewController = [[UINavigationController alloc]initWithRootViewController:conversationListController];
//        [self.conversationNavigationViewController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
//    }
//    [self.view addSubview:self.conversationNavigationViewController.view];
//}


-(void) startLoginView{
    if(self.loginViewController == nil){
        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }
    [self.view addSubview:self.loginViewController.view];
}


-(void) startMainTabView{
    self.mainTabBarController = nil;
    self.mainTabBarController = [[MainTabBarController alloc]init];
    self.mainTabBarController.selectedIndex = 3;
    [self.view addSubview:self.mainTabBarController.view];
}



//OpenIM
- (void)_tryLogin
{
    __weak typeof(self) weakSelf = self;
    
    [[SPUtil sharedInstance] setWaitingIndicatorShown:YES withKey:self.description];
    
    //这里先进行应用的登录
    
    //应用登陆成功后，登录IMSDK
    [[SPKitExample sharedInstance] callThisAfterISVAccountLoginSuccessWithYWLoginId:@"visitor43"
                                                                           passWord:@"taobao1234"
                                                                    preloginedBlock:^{
                                                                        [[SPUtil sharedInstance] setWaitingIndicatorShown:NO withKey:weakSelf.description];
                                                                        [weakSelf _pushMainControllerAnimated:YES];
                                                                    } successBlock:^{
                                                                        
                                                                        //  到这里已经完成SDK接入并登录成功，你可以通过exampleMakeConversationListControllerWithSelectItemBlock获得会话列表
                                                                        [[SPUtil sharedInstance] setWaitingIndicatorShown:NO withKey:weakSelf.description];
                                                                        
                                                                        [weakSelf _pushMainControllerAnimated:YES];
#if DEBUG
                                                                        // 自定义轨迹参数均为透传
                                                                        //                                                                        [YWExtensionServiceFromProtocol(IYWExtensionForCustomerService) updateExtraInfoWithExtraUI:@"透传内容" andExtraParam:@"透传内容"];
#endif
                                                                    } failedBlock:^(NSError *aError) {
                                                                        [[SPUtil sharedInstance] setWaitingIndicatorShown:NO withKey:weakSelf.description];
                                                                        
                                                                        if (aError.code == YWLoginErrorCodePasswordError || aError.code == YWLoginErrorCodePasswordInvalid || aError.code == YWLoginErrorCodeUserNotExsit) {
                                                                            
                                                                            //                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                            //                                                                                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"登录失败, 可以使用游客登录。\n（如在调试，请确认AppKey、帐号、密码是否正确。）" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"游客登录", nil];
                                                                            //                                                                                [as showInView:weakSelf.view];
                                                                            //                                                                            });
                                                                        }
                                                                        
                                                                    }];
}


- (void)_pushMainControllerAnimated:(BOOL)aAnimated
{
    //如果是pad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self _presentSplitControllerAnimated:aAnimated];
    } else {
        if (self.navigationController.topViewController != self) {
            /// 已经进入主页面
            return;
        }
        //UMFuncListsViewController *tabController = [[UMFuncListsViewController alloc] init];
        
        //[self.navigationController pushViewController:tabController animated:aAnimated];
    }
}

- (void)_presentSplitControllerAnimated:(BOOL)aAnimated
{
    if (self.navigationController.topViewController != self) {
        /// 已经进入主页面
        return;
    }
    
    UISplitViewController *splitController = [[UISplitViewController alloc] init];
    
    if ([splitController respondsToSelector:@selector(setPreferredDisplayMode:)]) {
        [splitController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
    }
    
    /// 各个页面
    
    UINavigationController *detailController = nil;
    
    {
        /// 消息列表页面
        
        UIViewController *viewController = [[UIViewController alloc] init];
        [viewController.view setBackgroundColor:[UIColor whiteColor]];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        detailController = nvc;
    }
    
}

@end
