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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.isAgree = [userDefaults boolForKey:@"isAgreePolicy"];
    if(self.isAgree){
        [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
    }else{
        [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    }
    [self.policyView setHidden:YES];
    [detailTextView setText:@"     一、引言\n     微助重视用户的隐私，隐私权是您重要的权利。您在使用我们的服务时，我们可能会收集和使用您的相关信息。我们希望通过本《隐私条款》向您说明，在使用我们的服务时，我们如何收集、使用、储存和分享这些信息，以及我们为您提供的访问、更新、控制和保护这些信息的方式。本《隐私条款》与您所使用的其明服务息息相关，希望您仔细阅读，在需要时，按照本《隐私条款》的指引，作出您认为适当的选择\n     您使用或继续使用我们的服务，即意味着同意我们按照本《隐私条款》收集、使用、储存和分享您的相关信息。\n     如对本《隐私政策》或相关事宜有任何问题，请通过cago2015@163.com与我们联系。\n\n     二、我们可能收集的信息\n     我们提供服务时，可能会收集、储存和使用下列与您有关的信息。如果您不提供相关信息，可能无法注册成为我们的用户或无法享受我们提供的某些服务，或者无法达到相关服务拟达到的效果。您在注册账户或使用我们的服务时，向我们提供的相关个人信息，例如电话号码、昵称、电子邮件等；您使用服务时我们可能收集如下信息：日志信息，指您使用我们的服务时，系统可能通过操作等或其他方式自动采集的技术信息，包括：设备或软件信息，例如您的移动设备所提供的配置信息和移动设备所用的版本和设备识别码；位置信息，指您开启设备定位功能并使用我们基于位置提供的相关服务时，收集的有关您位置的信息，您可以通过关闭定位功能，停止对您的地理位置信息的收集。\n\n     三、我们可能如何使用信息\n     我们可能将在向您提供服务的过程之中所收集的信息用作下列用途：①向您提供服务。在我们提供服务时，用于身份验证、客户服务、安全防范、诈骗监测、存档和备份用途，确保我们向您提供的产品和服务的安全性；②帮助我们设计新服务，改善我们现有服务；使我们更加了解您如何接入和使用我们的服务，从而针对性地回应您的个性化需求，例如排行榜显示、语言设定、位置设定、个性化的帮助服务和指示，或对您和其他用户作出其他方面的回应。为了让您有更好的体验、改善我们的服务或您同意的其他用途，在符合相关法律法规的前提下，我们可能将通过某一项服务所收集的信息，以汇集信息或者个性化的方式，用于我们的其他服务。例如，在您使用我们的一项服务时所收集的信息，可能在另一服务中用于向您提供特定内容，或向您展示与您相关的、非普遍推送的信息。如果我们在相关服务中提供了相应选项，您也可以授权我们将该服务所提供和储存的信息用于我们的其他服务。\n\n     四、我们可能如何收集信息\n     我们可能通过cookies和您的操作来收集和使用您的信息，并将该等信息储存为日志信息。我们使用自己的cookies，目的是为您提供更个性化的用户体验和服务，并用于以下用途：①记住您的身份。例如：cookies有助于我们辨认您作为我们的注册用户的身份，或保存您向我们提供的有关您的喜好或其他信息；②分析您使用我们服务的情况。例如，我们可利用cookies和您的操作行为来了解您使用我们的服务进行什么活动，或那些服务最受您的欢迎;\n\n        五、我们可能向您发送的邮件和推送信息\n     您在使用我们的服务时，我们可能使用您的信息向您的设备发送电子邮件、推送通知。如您不希望收到这些信息，可以关闭推送通知。"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [ProgressHUD showError:@"用户名不能为空"];
        return;
    }
    if ([password isEqualToString:@""])
    {
        [ProgressHUD showError:@"密码不能为空"];
        return;
    }
    if(!self.isAgree){
        [ProgressHUD showError:@"请仔细阅读用户隐私条款并同意"];
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
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"登录失败,请检查网络!" waitUntilDone:YES];
            return ;
        }
    });
    
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
    
    [registerVC.navigationItem setTitle:@"注册"];
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    
}

-(IBAction) forgetPassword:(UIButton *)sender{
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"拨打客服电话18616113266？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
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
