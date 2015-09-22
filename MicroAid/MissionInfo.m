//
//  MissionInfo.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/6.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "MissionInfo.h"

@implementation MissionInfo

+(NSMutableArray *)getMissionInfos:(NSArray *)dataArray{
    NSMutableArray *momentsArray = [[NSMutableArray alloc] init];
    NSDictionary *dic;
    for (dic in dataArray) {
        MissionInfo *info =[[MissionInfo alloc] init];
        [info setMissionId:[[dic objectForKey:@"id"] intValue]];
        [info setDistance:[[dic objectForKey:@"distance"] doubleValue]];
        [info setTitle:[dic objectForKey:@"title"]];
        [info setGroup:[dic objectForKey:@"publicity"]];
        [info setStatusInfo:[dic objectForKey:@"statusInfo"]];
        [info setLongitude:[[dic objectForKey:@"longitude"] doubleValue]];
        [info setLatitude:[[dic objectForKey:@"latitude"] doubleValue]];
        [info setUserId:[[dic objectForKey:@"userID"] intValue]];
        [momentsArray addObject:info];
    }
    return momentsArray;
}

@end
