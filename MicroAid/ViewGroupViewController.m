//
//  ViewGroupViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/17.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "ViewGroupViewController.h"
#import "MicroAidAPI.h"
#import "GroupViewController.h"

@interface ViewGroupViewController ()

@end

@implementation ViewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"groupName:%@",self.groupName);
    [self getGroupInfo];
    // Do any additional setup after loading the view from its nib.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)exitGroup:(UIButton *)sender{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI exitGroup:userID groupName:self.groupName];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//退出成功
            [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"退出成功!" waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(returnToGroupList) withObject:nil waitUntilDone:YES];
        }else{//退出失败
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"退出失败！" waitUntilDone:YES];
            return ;
        }
    });
}

-(void)returnToGroupList{
    GroupViewController *groupVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    [self.navigationController popToViewController:groupVC animated:YES];
    
}

-(IBAction)joinGroup:(UIButton *)sender{
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"请输入被邀请人手机号" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    [dialog show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSString *phoneNumber = [alertView textFieldAtIndex:0].text;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger userID = [userDefaults integerForKey:@"userID"];
        dispatch_async(serverQueue, ^{
            NSDictionary *resultDic = [MicroAidAPI joinGroup:userID groupName:self.groupName phoneNumber:phoneNumber];
            if ([[resultDic objectForKey:@"flg"] boolValue]) {//邀请成功
                [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"邀请加入成功!" waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(getGroupInfo) withObject:nil waitUntilDone:YES];
            }else if([[resultDic objectForKey:@"type"]integerValue]==0){//失败，已经加入
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"对方已经加入该群！" waitUntilDone:YES];
                return ;
            }else{//邀请失败
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"查无此人！" waitUntilDone:YES];
                return ;
            }
        });
    }
    
}

-(void) getGroupInfo{
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI getGroupInfo:self.groupName];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
            NSDictionary *dic = [resultDic objectForKey:@"group"];
            [self performSelectorOnMainThread:@selector(showGroupInfo:) withObject:dic waitUntilDone:YES];
        }else//创建失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"查找失败！" waitUntilDone:YES];
            return ;
        }
    });
}

-(void) showGroupInfo:(NSDictionary *)dic{
    self.groupCreateTime = [dic objectForKey:@"creatTime"];
    self.groupMembers = [[dic objectForKey:@"size"]integerValue];
    self.groupCreatorNickName = [dic objectForKey:@"creatorNickName"];
    self.groupID = [[dic objectForKey:@"size"]integerValue];
    self.groupCreator = [dic objectForKey:@"creator"];
    NSLog(@"groupCreateTime%@",self.groupCreateTime);
    groupMembersLabel.text = [NSString stringWithFormat:@"%li",(long)self.groupMembers];
    groupNameLabel.text = self.groupName;
    createTimeLabel.text = self.groupCreateTime;
    creatorLabel.text = self.groupCreatorNickName;
}


- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

- (void) successWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [ProgressHUD showSuccess:message];
}

@end
