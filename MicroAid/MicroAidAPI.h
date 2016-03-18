//
//  MicroAidAPI.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/24.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Mission.h"

@interface MicroAidAPI : NSObject
+ (void)setIpAddr:(NSString *)setting;
+(NSString *)GetIPAddress;

//1 用户帐户登录
+(NSDictionary *)MobileLogin:(NSString *)email password:(NSString *)password channelID:(NSString *)channelID;

//2 注册用户
+(NSDictionary *)RegisterUser:(User *)user choiceID:(NSString *)strings;

//3 获取所有擅长内容
+(NSDictionary *)fetchAllExcel;

//4 获取用户所在群组
+(NSDictionary *)fetchAllGroup:(NSInteger)userID pageNo:(int)pageNo pageSize:(int)pageSize;

//5 新建任务
+(NSDictionary *)createMission:(NSMutableDictionary *)dic;

//6 获取附近任务列表
+(NSDictionary *)getMissionList:(NSArray *)statusList distance:(double)distance type:(NSString *)type group:(NSString *)group bonus:(NSString *)bonus longitude:(double)longitude latitude:(double)latitude endTime:(NSString *)endTime pageNo:(NSInteger)pageNo pageSize:(NSInteger)pageSize userID:(NSInteger)userID;

//7 新建群组
+(NSDictionary *)createGroup:(NSInteger)userID userName:(NSString *)userName groupName:(NSString *)groupName;

//8 查看群信息
+(NSDictionary *)getGroupInfo:(NSString *)groupName;

//9 邀请加入群
+(NSDictionary *)joinGroup:(NSString *)groupName applicantName:(NSString *)phoneNumber userIDs:(NSString *)userIDs;

//10 退出群
+(NSDictionary *)exitGroup:(NSInteger)userID groupName:(NSString *)groupName;

//11 修改密码
+(NSDictionary *)modPassword:(NSInteger)userID password:(NSString *)password newPassword:(NSString *)newPassword;

//12 得到用户信息
+(NSDictionary *)findUser:(NSInteger)userID;

//13 修改用户信息
+(NSDictionary *)updateUser:(NSInteger)userID nickName:(NSString *)nickName gender:(NSString *)gender message:(NSString *)message address:(NSString *)address email:(NSString *)email;

//14 上传用户头像
+(NSDictionary *)savePicture:(NSMutableDictionary *)dic;

//15 获取用户头像
+(NSDictionary *)fetchPicture:(NSInteger)userID;

//16 获取附近任务列表2(已完成、已发起等)
+(NSDictionary *)getStaredMissionList:(NSInteger)userID recUserID:(NSInteger)recUserID statusList:(NSArray *)statusList longitude:(double)longitude latitude:(double)latitude pageNo:(NSInteger)pageNo pageSize:(NSInteger)pageSize;

//17 获取任务信息
+(NSDictionary *)fetchMission:(NSInteger)missionID;

//18 修改任务
+(NSDictionary *)updateMission:(NSMutableDictionary *)dic;

//19 接受任务
+(NSDictionary *)acceptMission:(NSInteger )missionID userID:(NSInteger)userID;

//20 获取通知
+(NSDictionary *)fetchNotification:(NSInteger )userID pageNo:(int)pageNo pageSize:(int)pageSize;

//21 修改用户channelID
+(NSDictionary *)updateChannelID:(NSInteger)userID channelID:(NSString *)channelID;

//22 获得没有加入群组的用户列表
+(NSDictionary *)getUnjoinedUser:(NSString *)groupName pageNo:(int)pageNo pageSize:(int)pageSize;

//23 获取我认领的任务列表
+(NSDictionary *)getcClaimedAndFinishedMissionList:(NSInteger)userID recUserID:(NSInteger)recUserID statusList:(NSArray *)statusList longitude:(double)longitude latitude:(double)latitude pageNo:(NSInteger)pageNo pageSize:(NSInteger)pageSize;

//24 获得加入群组的用户列表
+(NSDictionary *)getJoinedUser:(NSString *)groupName pageNo:(int)pageNo pageSize:(int)pageSize;

//25 获取积分排行
+(NSDictionary *)getUserInfoOrderByScore:(int)pageNo pageSize:(int)pageSize;

//26 比较版本
+(NSDictionary *)compareVersion:(NSString *)versionNum;

//27 添加无障碍设施
+(NSDictionary *)createBarrierFree:(NSInteger)userID dic:(NSMutableDictionary *)dic;

//28 按照距离获取附近的无障碍设施
+(NSDictionary *)getFreeBarrierByDistance:(double)distance longitude:(double)longitude latitude:(double)latitude pageNo:(NSInteger)pageNo pageSize:(NSInteger)pageSize;

//29 更新无障碍设施
+(NSDictionary *)updateBarrierFree:(NSInteger)userID dic:(NSMutableDictionary *)dic;
@end
