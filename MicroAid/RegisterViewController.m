//
//  RegisterViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/24.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "RegisterViewController.h"
#import "MicroAidAPI.h"
#import "RootController.h"
#import "ChoiceViewController.h"
#import "User.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    self.user= [[User alloc] init];
    
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(returnToLogin) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(returnToLogin)];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
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

-(IBAction) registerButtonClicked:(UIButton *)sender{
    
    [self.user setUsername:[NSString stringWithString:usernameTextField.text]];
    [self.user setPassword:[NSString stringWithString:passwordTextField.text]];
    [self.user setNickName:[NSString stringWithString:nickNameTextField.text]];
    
    BOOL isInfoRight = [self.user verifyInfo:[NSString stringWithString:passwordTextField2.text]];
    if (isInfoRight== TRUE) {
        if(self.choiceIDStrings == nil||[self.choiceIDStrings isEqualToString:@""]){
            [ProgressHUD showError:@"请选择您的帮助内容!"];
            return;
        }
        [ProgressHUD show:@"正在注册"];
        self.view.userInteractionEnabled = false;
        [self.navigationController.navigationBar setUserInteractionEnabled:false];
        
        dispatch_async(serverQueue, ^{
            NSDictionary *resultDic = [MicroAidAPI RegisterUser:self.user choiceID:self.choiceIDStrings];
            if ([[resultDic objectForKey:@"userID"] integerValue] > 0) {//注册成功
                
                [self.user setUserID:[[resultDic objectForKey:@"userID"] integerValue]];
                [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"注册成功" waitUntilDone:YES];
                
            }else//注册失败
            {
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"注册失败,请检查网络!" waitUntilDone:YES];
                return ;
            }
        });
    }
}


-(IBAction)choiceButtonClicked:(UIButton *)sender{
 
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI fetchAllExcel];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
            NSArray *list = [resultDic objectForKey:@"excelList"];
            self.choiceDic = [NSMutableDictionary dictionaryWithCapacity:5];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[list count]];
            for(int i =0; i<[list count]; i++){
                NSDictionary *subList = [list objectAtIndex:i];
                NSString *index = (NSString *)[subList objectForKey:@"id"];
                NSString *taskType =(NSString *)[subList objectForKey:@"taskType"];
                [array addObject:taskType];
                [self.choiceDic setObject:index forKey:taskType];
            }
            //显示
            [self performSelectorOnMainThread:@selector(openChoiceView:) withObject:array waitUntilDone:YES];

        }else//获取失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败,请检查网络!" waitUntilDone:YES];
            return ;
        }
    });
}

-(void) openChoiceView:(NSMutableArray *)array
{
    ChoiceViewController *choiceVC = [[ChoiceViewController alloc] initWithNibName:@"ChoiceViewController" bundle:nil];

    self.passValueDelegate = choiceVC;
    [self.passValueDelegate passAllChoiceValues:array choiceStrings:self.choiceStrings];
    
    [self.navigationController pushViewController:choiceVC animated:YES];
}

-(void) passChoiceValues:(NSString *)string{
    self.choiceStrings = string;
    self.choiceIDStrings = [[NSString alloc]init];
    NSArray *list = [string componentsSeparatedByString:@","];
    for(NSString *sub in list){
        if([sub isEqualToString:@""]){
            continue;
        }
        self.choiceIDStrings = [self.choiceIDStrings stringByAppendingString:[NSString stringWithFormat:@"%@", [self.choiceDic objectForKey:sub]]];
        self.choiceIDStrings = [self.choiceIDStrings stringByAppendingString:@","];
    }
    self.choiceIDStrings = [self.choiceIDStrings substringToIndex:self.choiceIDStrings.length-1];
}


-(void)returnToLogin{
    [self dismissViewControllerAnimated:NO completion:nil];
}


//点击空白区域，键盘收起
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    [self.view endEditing:YES];
}

- (void) successWithMessage:(NSString *)message {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:self.user.userID forKey:@"userID"];
    [userDefaults setObject:self.user.username forKey:@"username"];
    [userDefaults setObject:self.user.password forKey:@"password"];
    [userDefaults setObject:self.user.nickName forKey:@"nickName"];
    [userDefaults synchronize];
    
    [self.view setUserInteractionEnabled:true];
    [self.view endEditing:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showSuccess:message];
    [self returnToLogin];
}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}


@end
