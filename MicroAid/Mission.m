//
//  Mission.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/6.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "Mission.h"
#import "ProgressHUD.h"
#import "DateTimeUtils.h"

@implementation Mission

-(NSString *) verifyInfo{
    if ([_title isEqualToString:@""]) {
        //[ProgressHUD showError:@"任务标题不能为空！"];
        return Localized(@"任务标题不能为空！");
    }
    if ([_startTime isEqualToString:Localized(@"点击选择")]) {
        //[ProgressHUD showError:@"请选择开始时间!"];
        return Localized(@"请选择开始时间!");
    }
    if ([_endTime isEqualToString:Localized(@"点击选择")]) {
        //[ProgressHUD showError:@"请选择结束时间!"];
        return Localized(@"请选择结束时间!");
    }
    if([[[DateTimeUtils changeStringIntoDate:_startTime] earlierDate:[DateTimeUtils changeStringIntoDate:_endTime]] isEqualToDate:[DateTimeUtils changeStringIntoDate:_endTime]]){
        //[ProgressHUD showError:@"时间不正确!"];
        return Localized(@"时间不正确!");
    }
    if ([_type isEqualToString:Localized(@"点击选择")]) {
        //[ProgressHUD showError:@"请选择任务类型!"];
        return Localized(@"请选择任务类型!");
    }
    if ([_group isEqualToString:Localized(@"点击选择")]) {
        //[ProgressHUD showError:@"请选择任务对象!"];
        return Localized(@"请选择任务对象!");
    }
    if ([_bonus isEqualToString:Localized(@"点击选择")]) {
        //[ProgressHUD showError:@"请选择悬赏金额!"];
        return Localized(@"请选择悬赏金额!");
    }
    if ([_descript isEqualToString:Localized(@"请在此输入任务描述")]) {
        //[ProgressHUD showError:@"任务描述不能为空！"];
        return Localized(@"任务描述不能为空！");
    }
    if ([_address isEqualToString:Localized(@"点击选择")]) {
        //[ProgressHUD showError:@"请选择任务地址！"];
        return Localized(@"请选择任务地址！");
    }
    return @"yes";
}

@end
