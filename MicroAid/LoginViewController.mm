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
#import "SPKitExample.h"
#import "SPUtil.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.isAgree = [userDefaults boolForKey:@"isAgreePolicy"];
    if(self.isAgree){
        [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
    }else{
        [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    }
    [agreePolicyBtn setTitle:[NSString stringWithFormat:@"%@",Localized(@"同意")] forState:UIControlStateNormal];
    [agreePolicyTitleLabel setText:[NSString stringWithFormat:@"%@",Localized(@"微助用户隐私条款")]];
    [weizhuLabel setText:[NSString stringWithFormat:@"%@",Localized(@"微助")]];
    [self.policyView setHidden:YES];
    [detailTextView setText:Localized(@"隐私条款细节")];
    self.policyView.layer.cornerRadius = 10.f;
    self.policyView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) changeLanguage:(UIButton *)sender{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([[userDefaults objectForKey:@"appLanguage"]hasPrefix:@"en"]){//英文版
        [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:@"appLanguage"];
    }else if([[userDefaults objectForKey:@"appLanguage"]hasPrefix:@"zh-Hans"]){//中文版
        [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"appLanguage"];
    }
    [userDefaults synchronize];
    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
    [rootController refreshLoginView];
}

-(IBAction)agreePolicy:(UIButton *)sender{
    self.isAgree = YES;
    [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
    [self.policyView setHidden:YES];
    [self.imageView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    [self.itemView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    [self.icView setAlpha:1];
}

-(IBAction)check:(UIButton *)sender{
    if(self.isAgree){
        self.isAgree = NO;
        [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    }else{
        self.isAgree = YES;
        [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
    }
}

-(IBAction)readPolicy:(UIButton *)sender{
    [self.policyView setHidden:NO];
    [self.imageView setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5]];
    [self.itemView setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5]];
    [self.icView setAlpha:0.5];
}

-(IBAction)closePolicy:(UIButton *)sender{
    [self.policyView setHidden:YES];
    [self.imageView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    [self.itemView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:239/255.0 blue:213/255.0 alpha:1]];
    [self.icView setAlpha:1];
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
        [ProgressHUD showError:Localized(@"用户名不能为空!")];
        return;
    }
    if ([password isEqualToString:@""])
    {
        [ProgressHUD showError:Localized(@"密码不能为空！")];
        return;
    }
    if(!self.isAgree){
        [ProgressHUD showError:Localized(@"请仔细阅读用户隐私条款并同意")];
        return;
    }
    
    [ProgressHUD show:Localized(@"正在登录")];
    self.view.userInteractionEnabled = false;
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI MobileLogin:username password:password channelID:[BPush getChannelId]];
        
        if(![[resultDic objectForKey:@"onError"]boolValue]){
            if ([[resultDic objectForKey:@"userID"] integerValue] > 0 ) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setInteger:[[resultDic objectForKey:@"userID"] integerValue] forKey:@"userID"];
                [userDefaults setObject:username forKey:@"username"];
                [userDefaults setObject:password forKey:@"password"];
                NSDictionary *array = [resultDic objectForKey:@"user"];
                [userDefaults setObject:[array objectForKey:@"nickName"] forKey:@"nickName"];
                [userDefaults synchronize];
                
                [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:Localized(@"登录成功") waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(switchNextViewController) withObject:nil waitUntilDone:YES];
                return ;
            }else if([[resultDic objectForKey:@"userID"] integerValue] < 0){
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:Localized(@"账号/密码错误!") waitUntilDone:YES];
                return ;
            }
        }else{
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:Localized(@"登录失败,请检查网络!") waitUntilDone:YES];
            return ;
        }
    });
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [usernameLabel setText:[NSString stringWithFormat:@"%@:",Localized(@"账号")]];
    [usernameTextField setPlaceholder:Localized(@"手机号码")];
    [passwordLabel setText:[NSString stringWithFormat:@"%@:",Localized(@"密码")]];
    [passwordTextField setPlaceholder:Localized(@"密码")];
    [forgetBtn setTitle:Localized(@"忘记密码") forState:UIControlStateNormal];
    [readLabel setText:Localized(@"我已经阅读并同意")];
    [policyBtn setTitle:Localized(@"用户隐私条款") forState:UIControlStateNormal];
    [loginBtn setTitle:Localized(@"登陆") forState:UIControlStateNormal];
    [signUpBtn setTitle:Localized(@"注册") forState:UIControlStateNormal];
    [self.policyView setHidden:YES];
    [languageBtn setTitle:Localized(@"English version") forState:UIControlStateNormal];
}

-(void) viewWillDisappear:(BOOL)animated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    [userDefaults setBool:self.isAgree forKey:@"isAgreePolicy"];
    [userDefaults synchronize];
    self.isAgree = [[userDefaults objectForKey:@"isAgreePolicy"]boolValue];
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
    
    [registerVC.navigationItem setTitle:Localized(@"注册")];
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    
}

-(IBAction) forgetPassword:(UIButton *)sender{
    
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:Localized(@"拨打客服电话18616113266？") message:nil delegate:self cancelButtonTitle:Localized(@"取消") otherButtonTitles:Localized(@"确定"),nil];
    [dialog setAlertViewStyle:UIAlertViewStyleDefault];
    [dialog setTag:0];
    [dialog show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 0){
        if(buttonIndex == 1){
            NSMutableString *str = [[NSMutableString alloc]initWithFormat:@"tel:%@",@"18616113266"];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
        }
    }
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    
}

- (void) successWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.view endEditing:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showSuccess:message];
    
    //即时通信
    //[self _tryLogin];
    
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
