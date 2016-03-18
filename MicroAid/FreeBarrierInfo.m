//
//  FreeBarrierInfo.m
//  MicroAid
//
//  Created by jiahuaxu on 16/3/17.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import "FreeBarrierInfo.h"

@implementation FreeBarrierInfo


+(NSMutableArray *)getFreeBarrierInfos:(NSArray *)dataArray{
    NSMutableArray *momentsArray = [[NSMutableArray alloc] init];
    NSDictionary *dic;
    for (dic in dataArray) {
        FreeBarrierInfo *info =[[FreeBarrierInfo alloc] init];
        NSDictionary *userDic = [[NSDictionary alloc]init];
        [info setInfoID:[[dic objectForKey:@"id"] intValue]];
        [info setTitle:[dic objectForKey:@"name"]];
        [info setTel:[dic objectForKey:@"tel"]];
        [info setInfoDescription:[dic objectForKey:@"description"]];
        [info setLocation:[dic objectForKey:@"address"]];
        [info setTime:[dic objectForKey:@"createTime"]];
        [info setLatitude:[[dic objectForKey:@"latitude"] doubleValue]];
        [info setLongitude:[[dic objectForKey:@"longitude"] doubleValue]];
        userDic = [dic objectForKey:@"user"];
        [info setUserName:[userDic objectForKey:@"nickName"]];
        [momentsArray addObject:info];
    }
    return momentsArray;
}

@end
