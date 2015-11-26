//
//  NotificationInfo.m
//  MicroAid
//
//  Created by jiahuaxu on 15/10/8.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "NotificationInfo.h"

@implementation NotificationInfo

+(NSMutableArray *)getNotificationInfos:(NSArray *)dataArray{
    NSMutableArray *momentsArray = [[NSMutableArray alloc] init];
    NSDictionary *dic;
    for (dic in dataArray) {
        NotificationInfo *info =[[NotificationInfo alloc] init];
        [info setNotificationID:[[dic objectForKey:@"id"] intValue]];
        [info setMissionID:[[dic objectForKey:@"taskID"] intValue]];
        [info setUserID:[[dic objectForKey:@"userID"] intValue]];
        [info setTitle:[dic objectForKey:@"title"]];
        [info setMissionTitle:[dic objectForKey:@"taskName"]];
        [info setMissionGroup:[dic objectForKey:@"taskGroup"]];
        [info setTime:[dic objectForKey:@"time"]];
        [info setStatus:[dic objectForKey:@"status"]];
        [momentsArray addObject:info];
    }
    return momentsArray;
}

@end
