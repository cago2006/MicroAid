//
//  MissionInfo.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/6.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MissionInfo : NSObject

@property(assign,nonatomic) int missionId;
@property(strong,nonatomic) NSString * title;
@property(strong,nonatomic) NSString * statusInfo;//任务状态
@property(assign,nonatomic) double longitude;
@property(assign,nonatomic) double latitude;
@property(assign,nonatomic) double distance;
@property(strong,nonatomic) NSString * group;//发布对象
@property(assign,nonatomic) int userId;//发布者id

+(NSMutableArray *)getMissionInfos:(NSArray *)dataArray;
+(MissionInfo *)getRecMissionInfos:(NSDictionary *)dic;

@end
