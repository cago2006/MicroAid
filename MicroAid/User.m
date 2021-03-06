//
//  User.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/25.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "User.h"
#import "ProgressHUD.h"

@implementation User

//用于unjoineduser解析
+(NSMutableArray *)getUserInfos:(NSArray *)dataArray{
    NSMutableArray *momentsArray = [[NSMutableArray alloc] init];
    NSDictionary *dic = [[NSDictionary alloc]init];
    for (dic in dataArray) {
        User *info =[[User alloc] init];
        [info setUserID:[[dic objectForKey:@"id"] intValue]];
        [info setUsername:[dic objectForKey:@"userName"]];
        [info setNickName:[dic objectForKey:@"nickName"]];
        [momentsArray addObject:info];
    }
    return momentsArray;
}

//用于积分排行解析
+(NSMutableArray *)getUserInfosByScore:(NSArray *)dataArray pageNo:(NSInteger)pageNo pageSize:(NSInteger)pageSize{
    NSMutableArray *momentsArray = [[NSMutableArray alloc] init];
    NSDictionary *dic = [[NSDictionary alloc]init];
    int i = 1;
    for (dic in dataArray) {
        User *info =[[User alloc] init];
        [info setUserID:[[dic objectForKey:@"id"] intValue]];
        [info setNickName:[dic objectForKey:@"nickName"]];
        [info setScores:[[dic objectForKey:@"scores"] integerValue]];
        [info setRank:i+(pageNo-1)*pageSize];
        i++;
        [momentsArray addObject:info];
    }
    return momentsArray;
}


-(BOOL) verifyInfo:(NSString*)verifyPassword{
    if ([_username isEqualToString:@""]) {
        [ProgressHUD showError:Localized(@"用户名不能为空!")];
        return FALSE;
    }
//    if ([_question isEqualToString:@""]) {
//        [ProgressHUD showError:@"密码提示不能为空！"];
//        return FALSE;
//    }
//    if ([_answer isEqualToString:@""]) {
//        [ProgressHUD showError:@"密码提示回答不能为空！"];
//        return FALSE;
//    }
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:_username];
    if(!isMatch){
        [ProgressHUD showError:Localized(@"不是正确的手机号！")];
        return FALSE;
    }
    if ([_password isEqualToString:@""]) {
        [ProgressHUD showError:Localized(@"密码不能为空！")];
        return FALSE;
    }
    if(_password.length < 6) {
        [ProgressHUD showError:Localized(@"密码过短！")];
        return FALSE;
    }
    if(_password.length > 16) {
        [ProgressHUD showError:Localized(@"密码过长！")];
        return FALSE;
    }
    if ([verifyPassword isEqualToString:@""]) {
        [ProgressHUD showError:Localized(@"再次输入密码不能为空！")];
        return FALSE;
    }
    if(![_password isEqualToString:verifyPassword]){
        [ProgressHUD showError:Localized(@"两次输入密码不一致，请重新输入！")];
        return FALSE;
    }
    regex = @"^[a-zA-Z0-9_\u4e00-\u9fa5]{2,6}$";
    pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    isMatch = [pred evaluateWithObject:_nickName];
    if(!isMatch){
        [ProgressHUD showError:Localized(@"昵称应该由2-6位中英文、数字或下滑线组成！")];
        return FALSE;
    }
    return TRUE;
}


@end
