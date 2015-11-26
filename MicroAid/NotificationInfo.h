//
//  NotificationInfo.h
//  MicroAid
//
//  Created by jiahuaxu on 15/10/8.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationInfo : NSObject

@property(nonatomic)NSInteger notificationID;
@property(nonatomic)NSInteger missionID;
@property(nonatomic)NSInteger userID;
@property(strong,nonatomic)NSString *title;//通知标题
@property(strong,nonatomic)NSString *missionTitle;//任务标题
@property(strong,nonatomic)NSString *missionGroup;//任务群组
@property(strong,nonatomic)NSString *time;//通知时间
@property(strong,nonatomic)NSString *status;//任务状态

+(NSMutableArray *)getNotificationInfos:(NSArray *)dataArray;

@end
