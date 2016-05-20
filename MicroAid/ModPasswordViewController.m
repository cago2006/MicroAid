//
//  ModPasswordViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/18.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "ModPasswordViewController.h"
#import "MicroAidAPI.h"
#import "RootController.h"

@interface ModPasswordViewController ()

@end

@implementation ModPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [self.navigationItem setTitle:Localized(@"修改密码")];
    
    UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(savePassword) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    //[saveBtn release];
    self.navigationItem.rightBarButtonItem = saveItem;
    //[saveItem release];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [oldPasswordLabel setText:Localized(@"原始密码")];
    [passwordLabel setText:Localized(@"新密码")];
    [passwordLabel2 setText:Localized(@"确认密码")];
    [oldPasswordTextField setPlaceholder:Localized(@"请输入原始密码")];
    [passwordTextField setPlaceholder:Localized(@"6-16位新密码")];
    [passwordTextField2 setPlaceholder:Localized(@"再次输入新密码")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)savePassword{
    [self.view setUserInteractionEnabled:false];
    [self.navigationController.navigationBar setUserInteractionEnabled:false];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    NSString *password = [userDefaults objectForKey:@"password"];
    if([self verifyInfo:password oldPassword:oldPasswordTextField.text newPassword:passwordTextField.text newPassword2:passwordTextField2.text]){
        dispatch_async(serverQueue, ^{
            NSDictionary *resultDic = [MicroAidAPI modPassword:userID password:oldPasswordTextField.text newPassword:passwordTextField.text];
            if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
                [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"密码修改成功,请重新登录!" waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(returnToLogin) withObject:nil waitUntilDone:YES];
            }else//创建失败
            {
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"密码修改失败,请检查网络！" waitUntilDone:YES];
                return ;
            }
        });
    }else{
        [self.view setUserInteractionEnabled:true];
        [self.navigationController.navigationBar setUserInteractionEnabled:true];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

- (void) successWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.view endEditing:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showSuccess:message];
}

-(BOOL) verifyInfo:(NSString*)password oldPassword:(NSString*)oldPassword newPassword:(NSString *)newPassword newPassword2:(NSString *)newPassword2{
    if (![oldPassword isEqualToString:password]) {
        [ProgressHUD showError:@"原始密码错误！"];
        return FALSE;
    }
    if ([newPassword isEqualToString:@""]) {
        [ProgressHUD showError:@"密码不能为空！"];
        return FALSE;
    }
    if(newPassword.length < 6) {
        [ProgressHUD showError:@"密码过短！"];
        return FALSE;
    }
    if(newPassword.length > 16) {
        [ProgressHUD showError:@"密码过长！"];
        return FALSE;
    }
    if ([oldPassword isEqualToString:newPassword]) {
        [ProgressHUD showError:@"新旧密码一致,请重新输入新密码!"];
        return FALSE;
    }
    if ([newPassword2 isEqualToString:@""]) {
        [ProgressHUD showError:@"再次输入密码不能为空！"];
        return FALSE;
    }
    if(![newPassword isEqualToString:newPassword2]){
        [ProgressHUD showError:@"两次输入密码不一致，请重新输入！"];
        return FALSE;
    }
    return TRUE;
}

-(void)returnToLogin{
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefaults dictionaryRepresentation];
    for(NSString* key in [dictionary allKeys]){
        [userDefaults removeObjectForKey:key];
        [userDefaults synchronize];
    }
    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
    [rootController switchToLoginViewFromMainTab];
}

@end
