//
//  ViewUserViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/24.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "ViewUserViewController.h"
#import "MicroAidAPI.h"
#import "GTMBase64.h"

@interface ViewUserViewController ()

@end

@implementation ViewUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self findUser];
    photoBtn.userInteractionEnabled = NO;
    phoneBtn.layer.cornerRadius = phoneBtn.frame.size.width/2.0;
    phoneBtn.layer.masksToBounds = phoneBtn.frame.size.width/2.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)findUser{
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI findUser:self.userID];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//查找成功
            NSDictionary *user = [resultDic objectForKey:@"user"];
            [self performSelectorOnMainThread:@selector(showMyInfo:) withObject:user waitUntilDone:YES];
        }else if([[resultDic objectForKey:@"onError"] boolValue])//失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"信息查找失败,请检查网络!" waitUntilDone:YES];
            return ;
        }
    });
    
    dispatch_async(serverQueue, ^{
        NSDictionary *resultDic = [MicroAidAPI fetchPicture:self.userID];
        if ([[resultDic objectForKey:@"flg"] boolValue]) {//创建成功
            NSData *picture = [resultDic objectForKey:@"picture"];
            [self performSelectorOnMainThread:@selector(showPicture:) withObject:picture waitUntilDone:YES];
        }else if([[resultDic objectForKey:@"onError"] boolValue])//创建失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"头像查找失败！" waitUntilDone:YES];
            return ;
        }else{
            [self performSelectorOnMainThread:@selector(showPicture:) withObject:nil waitUntilDone:YES];
        }
    });
}

-(void) showPicture:(NSString *)picture{
    if(picture == nil){
        [photoBtn setBackgroundImage:[UIImage imageNamed:@"default_pic"] forState:UIControlStateNormal];
    }else{
        //需要转换了才能用
        NSString *formatedString = [picture stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSData *imageData = [GTMBase64 decodeString:formatedString];
        [photoBtn setBackgroundImage:[UIImage imageWithData:imageData scale:0.0] forState:UIControlStateNormal];
    }
}

-(void) showMyInfo:(NSMutableDictionary *)dic{
    self.phoneNumber = [dic objectForKey:@"userName"];
    
    nameLabel.text = [dic objectForKey:@"nickName"];
    NSString *gender = [dic objectForKey:@"gender"];
    if(![gender isKindOfClass:[NSString class]]){
        genderLabel.text = @"此人没有填写";
    }else{
        genderLabel.text = gender;
    }
    
    NSString *email = [dic objectForKey:@"email"];
    if(![email isKindOfClass:[NSString class]]){
        emailLabel.text = @"此人没有填写";
    }else{
        emailLabel.text = email;
    }
}

- (void) errorWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [ProgressHUD showError:message];
}

- (void) successWithMessage:(NSString *)message {
    [self.view setUserInteractionEnabled:true];
    [ProgressHUD showSuccess:message];
}

-(IBAction)phoneBtnClicked:(UIButton *)sender{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.phoneNumber];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
    [callWebview release];
    [str release];
}

@end