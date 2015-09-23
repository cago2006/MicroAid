//
//  ViewMissionViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/23.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "ViewMissionViewController.h"
#import "MicroAidAPI.h"
#import "GTMBase64.h"

@interface ViewMissionViewController ()

@end

@implementation ViewMissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"查看任务"];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) getMission{
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI fetchMission:self.missionID];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
            NSMutableDictionary *dic = [resultDic objectForKey:@"task"];
            //显示
            [self performSelectorOnMainThread:@selector(showMissionInfo:) withObject:dic waitUntilDone:YES];
            
        }else//获取失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败！" waitUntilDone:YES];
            return ;
        }
    });
}

-(void) showMissionInfo:(NSMutableDictionary *)dic{
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI fetchPicture:[[dic objectForKey:@"userID"]integerValue]];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
            NSData *picture = [resultDic objectForKey:@"picture"];
            [self performSelectorOnMainThread:@selector(showToPicture:) withObject:picture waitUntilDone:YES];
        }else//创建失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"头像查找失败！" waitUntilDone:YES];
            return ;
        }
    });
    [titleLabel setText:[dic objectForKey:@"title"]];
    [startTimeLabel setText:[NSString stringWithFormat:@"起始时间:%@",[dic objectForKey:@"startTime"]]];
    [statusLabel setText:[NSString stringWithFormat:@"任务状态:%@",[dic objectForKey:@"statusInfo"]]];
    [endTimeLabel setText:[NSString stringWithFormat:@"截止时间:%@",[dic objectForKey:@"endTime"]]];
    [typeLabel setText:[NSString stringWithFormat:@"任务类型:%@",[dic objectForKey:@"taskType"]]];
    [groupLabel setText:[NSString stringWithFormat:@"任务对象:%@",[dic objectForKey:@"publicity"]]];
    [bonusLabel setText:[NSString stringWithFormat:@"任务悬赏:%@",[NSString stringWithFormat:@"%ld分",(long)[[dic objectForKey:@"taskScores"]integerValue]]]];
    [addressLabel setText:[NSString stringWithFormat:@"任务地址:%@(距您%.1f米)",[dic objectForKey:@"address"],self.missionDistance]];
    [typeLabel setText:[NSString stringWithFormat:@"任务类型:%@",[dic objectForKey:@"taskType"]]];
    desTextView.text =[dic objectForKey:@"description"];
    if([[dic objectForKey:@"recUserID"]integerValue]<1){
        UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
        [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(acceptMission) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitle:@"接受任务" forState:UIControlStateNormal];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }else{
        dispatch_async(serverQueue, ^{
            NSDictionary *resultDic = [MicroAidAPI fetchPicture:[[dic objectForKey:@"recUserID"]integerValue]];
            if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
                NSData *picture = [resultDic objectForKey:@"picture"];
                [self performSelectorOnMainThread:@selector(showToPicture:) withObject:picture waitUntilDone:YES];
            }else//创建失败
            {
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"头像查找失败！" waitUntilDone:YES];
                return ;
            }
        });
    }
}

-(void) showFromPicture:(NSString *)picture{
    
    //需要转换了才能用
    NSString *formatedString = [picture stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSData *imageData = [GTMBase64 decodeString:formatedString];
    [fromView setBackgroundImage:[UIImage imageWithData:imageData scale:0.0] forState:UIControlStateNormal];
    
}

-(void) showToPicture:(NSString *)picture{
    
    //需要转换了才能用
    NSString *formatedString = [picture stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSData *imageData = [GTMBase64 decodeString:formatedString];
    [toView setBackgroundImage:[UIImage imageWithData:imageData scale:0.0] forState:UIControlStateNormal];

}

-(void) acceptMission{
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI fetchMission:self.missionID];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
            NSMutableDictionary *dic = [resultDic objectForKey:@"task"];
            //显示
            [self performSelectorOnMainThread:@selector(showMissionInfo:) withObject:dic waitUntilDone:YES];
            
        }else//获取失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败！" waitUntilDone:YES];
            return ;
        }
    });
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
