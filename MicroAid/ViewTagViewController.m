//
//  ViewTagViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 16/3/15.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import "ViewTagViewController.h"
#import "AddTagViewController.h"
#import "MicroAidAPI.h"

@interface ViewTagViewController ()

@end

@implementation ViewTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"查看设施信息"];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    rectifyBtn.layer.cornerRadius = rectifyBtn.frame.size.width/2.0;
    rectifyBtn.layer.masksToBounds = rectifyBtn.frame.size.width/2.0;
    [self findTag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)rectifyBtnClicked:(UIButton *)sender{
    AddTagViewController *modTag = [[AddTagViewController alloc]initWithNibName:@"AddTagViewController" bundle:nil];
    modTag.isEdit = YES;
    modTag.resultDic = self.resultDic;
    [self.navigationController pushViewController:modTag animated:YES];
}

-(void) findTag{
    dispatch_async(serverQueue, ^{
        self.resultDic = [MicroAidAPI fetchMission:self.tagID];
        if ([[self.resultDic objectForKey:@"flg"] boolValue]) {//获取成功
            //显示
            [self performSelectorOnMainThread:@selector(showInfo) withObject:nil waitUntilDone:YES];
            
        }else if ([[self.resultDic objectForKey:@"onError"] boolValue])//获取失败
        {
            [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"信息获取失败,请检查网络!" waitUntilDone:YES];
            return ;
        }
    });
}

-(void)showInfo{
    NSMutableDictionary *dic = [self.resultDic objectForKey:@"task"];
    [descriptTextView setText:@"描述"];
    [typeLabel setText:@"type"];
    [locationLabel setText:@"type"];
    [titleLabel setText:@"type"];
    [timeLebel setText:@"type"];
    [remarkTextView setText:@"type"];
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

@end
