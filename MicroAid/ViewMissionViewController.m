//
//  ViewMissionViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/23.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "ViewMissionViewController.h"
#import "MicroAidAPI.h"
#import "RootController.h"
#import "GTMBase64.h"
#import "MyInfoViewController.h"
#import "ViewUserViewController.h"
#import "LocationViewController.h"
#import "DateTimeUtils.h"
#import "MainTabBarController.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"

@interface ViewMissionViewController ()

@end

@implementation ViewMissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"查看任务"];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self getMission];
    toView.userInteractionEnabled = NO;
    
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [ProgressHUD dismiss];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) getMission{
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI fetchMission:self.missionID];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//获取成功
            //显示
            [self performSelectorOnMainThread:@selector(showMissionInfo:) withObject:resultDic waitUntilDone:YES];
            
        }else if ([[resultDic objectForKey:@"onError"] boolValue])//获取失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"列表获取失败,请检查网络!" waitUntilDone:YES];
            return ;
        }
    });
}

-(void) showMissionInfo:(NSDictionary *)resultDic{
    NSMutableDictionary *dic = [resultDic objectForKey:@"task"];
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic2 = [MicroAidAPI fetchPicture:[[dic objectForKey:@"userID"]integerValue]];
        if ([[resultDic2 objectForKey:@"flg"] boolValue]) {//创建成功
            NSData *picture = [resultDic2 objectForKey:@"picture"];
            [self performSelectorOnMainThread:@selector(showFromPicture:) withObject:picture waitUntilDone:YES];
        }else if ([[resultDic2 objectForKey:@"onError"] boolValue])//创建失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"头像查找失败,请检查网络!" waitUntilDone:YES];
            return ;
        }else{
            [self performSelectorOnMainThread:@selector(showFromPicture:) withObject:nil waitUntilDone:YES];
        }
    });
    self.fromID = [[dic objectForKey:@"userID"]integerValue];
    [fromNickNameView setText:[resultDic objectForKey:@"userNickName"]];
    self.toID = [[dic objectForKey:@"recUserID"]integerValue];
    if(self.toID>0){
        toNickNameView.backgroundColor = [UIColor whiteColor];
        [toNickNameView setText:[resultDic objectForKey:@"recUserNickName"]];
    }
    [titleLabel setText:[dic objectForKey:@"title"]];
    [startTimeLabel setText:[NSString stringWithFormat:@"起始时间:%@",[dic objectForKey:@"startTime"]]];
    NSString *status = [dic objectForKey:@"statusInfo"];
    status = [status stringByReplacingOccurrencesOfString:@"接受" withString:@"认领"];
    if([status isEqualToString:@"已认领"] && [DateTimeUtils isOutOfDate:[dic objectForKey:@"endTime"]]){
        status = @"已过期";
    }
    [statusLabel setText:[NSString stringWithFormat:@"任务状态:%@",status]];
//    if([status isEqualToString:@"已认领"]){
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        NSInteger userID = [userDefaults integerForKey:@"userID"];
//        if(userID == self.toID || userID == self.fromID){
//            UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
//            [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [rightBtn addTarget:self action:@selector(finishMission) forControlEvents:UIControlEventTouchUpInside];
//            [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
//            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
//            self.navigationItem.rightBarButtonItem = rightItem;
//        }
//    }
    [endTimeLabel setText:[NSString stringWithFormat:@"截止时间:%@",[dic objectForKey:@"endTime"]]];
    //截止时间<现在时间
    if([DateTimeUtils isOutOfDate:[dic objectForKey:@"endTime"]]){
        self.isAccepted = YES;
    }
    [typeLabel setText:[NSString stringWithFormat:@"任务类型:%@",[dic objectForKey:@"taskType"]]];
    [groupLabel setText:[NSString stringWithFormat:@"任务对象:%@",[dic objectForKey:@"publicity"]]];
    [bonusLabel setText:[NSString stringWithFormat:@"任务悬赏:%@",[NSString stringWithFormat:@"%ld分",(long)[[dic objectForKey:@"taskScores"]integerValue]]]];
    self.missionAddress = [dic objectForKey:@"address"];
    self.missionLatitude = [[dic objectForKey:@"latitude"]doubleValue];
    self.missionLongitude = [[dic objectForKey:@"longitude"]doubleValue];
    if(!self.isSelf){
        [addressLabel setText:[NSString stringWithFormat:@"任务地址:%@(距您%.1f米)",self.missionAddress,self.missionDistance]];
    }else{
        [addressLabel setText:[NSString stringWithFormat:@"任务地址:%@",self.missionAddress]];
    }
    [typeLabel setText:[NSString stringWithFormat:@"任务类型:%@",[dic objectForKey:@"taskType"]]];
    desTextView.text =[dic objectForKey:@"description"];
    //分享
//    UIButton *shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,20,20)];
//    [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [shareBtn addTarget:self action:@selector(shareMission) forControlEvents:UIControlEventTouchUpInside];
//    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
//    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
    if(self.toID<1){
        if(!self.isAccepted){
            UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
            [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [rightBtn addTarget:self action:@selector(acceptMission) forControlEvents:UIControlEventTouchUpInside];
            [rightBtn setTitle:@"认领" forState:UIControlStateNormal];
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
            [self.navigationItem setRightBarButtonItems:[[NSArray alloc]initWithObjects:rightItem,nil]];
        }else{
            //self.navigationItem.rightBarButtonItem = shareItem;
        }
        
    }else{
        //self.navigationItem.rightBarButtonItem = shareItem;
        toView.userInteractionEnabled = YES;
        dispatch_async(serverQueue, ^{
            NSDictionary *resultDic = [MicroAidAPI fetchPicture:[[dic objectForKey:@"recUserID"]integerValue]];
            if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
                NSData *picture = [resultDic objectForKey:@"picture"];
                [self performSelectorOnMainThread:@selector(showToPicture:) withObject:picture waitUntilDone:YES];
            }else if ([[resultDic objectForKey:@"onError"] boolValue])//创建失败
            {
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"头像查找失败,请检查网络!" waitUntilDone:YES];
                return ;
            }else{
                [self performSelectorOnMainThread:@selector(showToPicture:) withObject:nil waitUntilDone:YES];
            }
        });
    }
}

-(void) showFromPicture:(NSString *)picture{
    if(picture == nil){
        [fromView setBackgroundImage:[UIImage imageNamed:@"default_pic"] forState:UIControlStateNormal];
    }else{
        //需要转换了才能用
        NSString *formatedString = [picture stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSData *imageData = [GTMBase64 decodeString:formatedString];
        [fromView setBackgroundImage:[UIImage imageWithData:imageData scale:0.0] forState:UIControlStateNormal];
    }
}

-(void) showToPicture:(NSString *)picture{
    if(picture == nil){
        [toView setBackgroundImage:[UIImage imageNamed:@"default_pic"] forState:UIControlStateNormal];
    }else{
        //需要转换了才能用
        NSString *formatedString = [picture stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSData *imageData = [GTMBase64 decodeString:formatedString];
        [toView setBackgroundImage:[UIImage imageWithData:imageData scale:0.0] forState:UIControlStateNormal];
    }
}

-(void) shareMission{
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"新浪微博", @"微信好友",@"微信朋友圈", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:@"wxe378ace7a2b6687a" appSecret:@"e1908bdfde6b2db1513414697fe723b6" url:@"https://itunes.apple.com/cn/app/wei-zhu-hu-zhu-ping-tai-rang/id1051712193?l=en&mt=8"];
    if(buttonIndex == 0) {
        // 新浪微博
        NSString *text = @"";
        if(self.toID>0){
            text = @"我在微助平台又完成了一个任务，快来加入我吧～";
        }else{
            text =  @"我在微助平台发布了一个任务，快来帮我完成吧～";
        }
        text = [NSString stringWithFormat:@"%@     任务名称:%@     下载链接(安卓):http://www.wandoujia.com/apps/cisl.ma下载链接(IOS):https://itunes.apple.com/cn/app/wei-zhu-hu-zhu-ping-tai-rang/id1051712193?l=en&mt=8",text,titleLabel.text];
        [[UMSocialControllerService defaultControllerService] setShareText:text shareImage:fromView.currentBackgroundImage socialUIDelegate:nil];        //设置分享内容和回调对象
        [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    }else if(buttonIndex == 1) {
        // 微信好友
        if(self.toID>0){
            [UMSocialData defaultData].extConfig.wechatSessionData.title = @"我在微助平台又完成了一个任务，快来加入我吧～";
        }else{
            [UMSocialData defaultData].extConfig.wechatSessionData.title = @"我在微助平台发布了一个任务，快来帮我完成吧～";
        }

        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
        
        [[UMSocialDataService defaultDataService]
                        postSNSWithTypes:@[UMShareToWechatSession]
                                 content:titleLabel.text
                                   image:fromView.currentBackgroundImage
                                location:nil
                             urlResource:nil
                     presentedController:self
                              completion:^(UMSocialResponseEntity *response){
                                  if (response.responseCode == UMSResponseCodeSuccess) {
                                      NSLog(@"分享成功！");
                                  }
                              }];

    }else if(buttonIndex == 2){
        //微信朋友圈
        if(self.toID>0){
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"我又完成来一个任务，快来加入我吧～";
        }else{
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"我在微助发布了一个任务，快来帮我完成吧～";
        }
        
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
        
        [[UMSocialDataService defaultDataService]
                        postSNSWithTypes:@[UMShareToWechatTimeline]
                                 content:titleLabel.text
                                   image:fromView.currentBackgroundImage
                                location:nil
                             urlResource:nil
                     presentedController:self
                              completion:^(UMSocialResponseEntity *response){
                                  if (response.responseCode == UMSResponseCodeSuccess) {
                                      NSLog(@"分享成功！");
                                  }
         }];
    }
}


-(void) acceptMission{
    
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"确认要认领该任务？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
    [dialog setAlertViewStyle:UIAlertViewStyleDefault];
    [dialog show];
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger userID = [userDefaults integerForKey:@"userID"];
        dispatch_async(serverQueue, ^{
            NSDictionary *resultDic = [MicroAidAPI acceptMission:self.missionID userID:userID isFromRec:self.isFromRec];
            if ([[resultDic objectForKey:@"flg"] boolValue]) {//接受成功
                [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"任务认领成功!" waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(returnToMainTab) withObject:nil waitUntilDone:YES];
            }else if ([[resultDic objectForKey:@"onError"] boolValue]) {//接受失败
                [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"任务认领失败,请检查网络!" waitUntilDone:YES];
                return ;
            }
        });
    }
    self.view.userInteractionEnabled = true;
    [self.navigationController.navigationBar setUserInteractionEnabled:true];
    
}

-(void)finishMission{
    
}

-(void)returnToMainTab{
    
//    RootController *rootController = (RootController *)[UIApplication sharedApplication].keyWindow.rootViewController;
//    //[UIApplication sharedApplication]获得uiapplication实例，keywindow为当前主窗口，rootviewcontroller获取根控件
//    [rootController switchToMainTabViewFromHomeView];
//    
//    
    MainTabBarController *mainTBC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    [self.navigationController popToViewController:mainTBC animated:YES];
}

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

-(IBAction)fromBtnClicked:(UIButton *)sender{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    if(self.fromID == userID){
        MyInfoViewController *myInfoVC = [[MyInfoViewController alloc]initWithNibName:@"MyInfoViewController" bundle:nil];
        [self.navigationController pushViewController:myInfoVC animated:YES];
    }else{
        ViewUserViewController *viewUserVC = [[ViewUserViewController alloc]initWithNibName:@"ViewUserViewController" bundle:nil];
        viewUserVC.userID = self.fromID;
        [self.navigationController pushViewController:viewUserVC animated:YES];
    }
}
-(IBAction)toBtnClicked:(UIButton *)sender{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [userDefaults integerForKey:@"userID"];
    if(self.toID == userID){
        MyInfoViewController *myInfoVC = [[MyInfoViewController alloc]initWithNibName:@"MyInfoViewController" bundle:nil];
        [self.navigationController pushViewController:myInfoVC animated:YES];
    }else{
        ViewUserViewController *viewUserVC = [[ViewUserViewController alloc]initWithNibName:@"ViewUserViewController" bundle:nil];
        viewUserVC.userID = self.toID;
        [self.navigationController pushViewController:viewUserVC animated:YES];
    }
}
-(IBAction)addressBtnClicked:(UIButton *)sender{
    LocationViewController *locationVC = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
    locationVC.isView = YES;
    locationVC.missionLocation = self.missionAddress;
    locationVC.missionLongitude = self.missionLongitude;
    locationVC.missionLatitude = self.missionLatitude;
    [self.navigationController pushViewController:locationVC animated:YES];
}


@end
