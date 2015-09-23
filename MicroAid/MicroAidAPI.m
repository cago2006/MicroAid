//
//  MicroAidAPI.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/24.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "MicroAidAPI.h"
#import "DateTimeUtils.h"

NSString *ipAddr;
@implementation MicroAidAPI


+ (void)setIpAddr:(NSString *)setting
{
    ipAddr = setting;
}

+ (NSDictionary *)toDictionary:(NSData *)data
{
    NSError *error;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return json;
}

+(NSString *)GetIPAddress
{
    return ipAddr;
}

//1 登录
+ (NSDictionary *)MobileLogin:(NSString *)username password:(NSString *)password
{
    NSError *error = nil;
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/user/login.action?userName=%@&password=%@",ipAddr,username,password];
    NSLog(@"loginURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    NSLog(@"error = %@",error);
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
    
    
}

//2 注册用户
+(NSDictionary *)RegisterUser:(User *)user choiceID:(NSString *)strings{
    NSError *error = nil;

    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/user/signup.action?userPOString={\"nickName\":\"%@\",\"userName\":\"%@\",\"password\":\"%@\"}&userExcelString=%@&separator=%@",ipAddr,@"新用户",user.username,user.password,strings,@","];
    
    NSLog(@"RegisterUserURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];

    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[SmartHomeAPIs toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}


//3 获取所有擅长内容

+(NSDictionary *)fetchAllExcel{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/excel/findAll.action",ipAddr];
    
    NSLog(@"fetchAllExcelURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    //NSLog(@"data-----%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//4 获取用户所在群组
+(NSDictionary *)fetchAllGroup:(NSInteger)userID pageNo:(int)pageNo pageSize:(int)pageSize{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/group/getAllJoinedGroupName.action?userID=%ld&pageNo=%i&pageSize=%i",ipAddr,(long)userID,pageNo,pageSize];
    
    NSLog(@"fetchAllURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    //NSLog(@"data-----%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//5 新建任务
+(NSDictionary *)createMission:(Mission *)mission{
    
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/task/createTask.action?taskPOString={\"userID\":\"%ld\",\"title\":\"%@\",\"taskType\":\"%@\",\"taskScores\":\"%@\",\"startTime\":\"%@\",\"endTime\":\"%@\",\"status\":\"0\",\"description\":\"%@\",\"address\":\"%@\",\"longitude\":\"%f\",\"latitude\":\"%f\",\"publicity\":\"%@\"}",ipAddr,(long)mission.userID,mission.title,mission.type,mission.bonus,mission.startTime,mission.endTime,mission.descript,mission.address,mission.longitude,mission.latitude,mission.group];
    
    NSLog(@"createMissionUserURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[SmartHomeAPIs toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//6 获取附近任务列表
+(NSDictionary *)getMissionList:(NSArray *)statusList distance:(double)distance type:(NSString *)type group:(NSString *)group bonus:(NSString *)bonus longitude:(double)longitude latitude:(double)latitude endTime:(NSString *)endTime pageNo:(NSInteger)pageNo pageSize:(NSInteger)pageSize{
    NSError *error = nil;
    
    NSString *status = [[NSString alloc]init];
    status = @"[";
    for(int i=0; i<statusList.count; i++){
        status = [status stringByAppendingString:[statusList objectAtIndex:i]];
    }
    status = [status stringByAppendingString:@"]"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/task/getTaskWithFilter.action?taskFilterString={\"statusList\":%@,\"distance\":\"%f\",\"longitude\":\"%f\",\"latitude\":\"%f\"",ipAddr,status,distance,longitude,latitude];
    if(![type isEqualToString:@"全部"]){
        NSArray *list = [type componentsSeparatedByString:@","];
        type = @"[";
        for(int i = 0; i< list.count; i++){
            type = [type stringByAppendingFormat:@"\"%@\",",[list objectAtIndex:i]];
        }
        type = [type substringToIndex:type.length-1];
        type = [type stringByAppendingString:@"]"];
        urlString = [urlString stringByAppendingFormat:@",\"taskType\":%@",type];
    }
    if(![group isEqualToString:@"全部"]){
        NSArray *list = [group componentsSeparatedByString:@","];
        group = @"[";
        for(int i = 0; i< list.count; i++){
            group = [group stringByAppendingFormat:@"\"%@\",",[list objectAtIndex:i]];
        }
        group = [group substringToIndex:group.length-1];
        group = [group stringByAppendingString:@"]"];
        urlString = [urlString stringByAppendingFormat:@",\"publicity\":%@",group];
    }
    if(![bonus isEqualToString:@"全部"]){
        urlString = [urlString stringByAppendingFormat:@",\"taskScores\":\"%@\"",bonus];
    }
    if(![endTime isEqualToString:@"全部"]){
        urlString = [urlString stringByAppendingFormat:@",\"endTime\":\"%@\"",endTime];
    }else{
        urlString = [urlString stringByAppendingFormat:@",\"endTime\":\"%@\"",[DateTimeUtils changeDateIntoString:[DateTimeUtils getCurrentTime]]];
    }
    urlString = [urlString stringByAppendingFormat:@"}&pageNo=%ld&pageSize=%ld",(long)pageNo,(long)pageSize];
    
    NSLog(@"getMissionListURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//7 新建群组
+(NSDictionary *)createGroup:(NSInteger)userID userName:(NSString *)userName groupName:(NSString *)groupName{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/group/signup.action?groupPOString={\"creator\":\"%@\",\"groupName\":\"%@\"}&userID=%ld",ipAddr,userName,groupName,(long)userID];
    
    NSLog(@"createGroupURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[SmartHomeAPIs toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//8 查看群信息
+(NSDictionary *)getGroupInfo:(NSString *)groupName{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/group/getGroupByGroupName.action?groupName=%@",ipAddr,groupName];
    
    NSLog(@"getGroupInfoURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}


//9 邀请加入群
+(NSDictionary *)joinGroup:(NSInteger)userID groupName:(NSString *)groupName phoneNumber:(NSString *)phoneNumber{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/group/recommendJoinGroup.action?refereesID=%ld&groupName=%@&applicantName=%@",ipAddr,(long)userID,groupName,phoneNumber];
    
    NSLog(@"joinGroupURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//10 退出群
+(NSDictionary *)exitGroup:(NSInteger)userID groupName:(NSString *)groupName{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/group/leaveGroup.action?userID=%ld&groupName=%@",ipAddr,(long)userID,groupName];
    
    NSLog(@"exitGroupURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}


//11 修改密码
+(NSDictionary *)modPassword:(NSInteger)userID password:(NSString *)password newPassword:(NSString *)newPassword{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/user/updateUser.action?userPOString={\"id\":\"%ld\",\"password\":\"%@\"}&newPassword=%@",ipAddr,(long)userID,password,newPassword];
    
    NSLog(@"modPasswordURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//12 得到用户信息
+(NSDictionary *)findUser:(NSInteger)userID{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/user/findUser.action?userID=%ld",ipAddr,(long)userID];
    
    NSLog(@"findUserURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}


//13 修改用户信息
+(NSDictionary *)updateUser:(NSInteger)userID nickName:(NSString *)nickName gender:(NSString *)gender message:(NSString *)message address:(NSString *)address email:(NSString *)email{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/user/updateUser.action?userPOString={\"id\":\"%ld\",\"nickName\":\"%@\",\"gender\":\"%@\",\"message\":\"%@\",\"address\":\"%@\",\"email\":\"%@\"}&newPassword=",ipAddr,(long)userID,nickName,gender,message,address,email];
    
    NSLog(@"updateUserURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//14 上传用户头像
+(NSDictionary *)savePicture:(NSMutableDictionary *)dic{
    NSError *error = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [@"picturePOString=" stringByAppendingString:[[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding]];
    
    //NSLog(@"jsonString:::%@",jsonString);
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/user/savePicture.action",ipAddr];
    //    NSLog(@"urlString:::%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];//请求这个地址， timeoutInterval:10 设置为10s超时：请求时间超过10s会被认为连接不上，连接超时
    
    [request setHTTPMethod:@"POST"];//POST请求
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];//body 数据
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];//请求头
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];//异步发送request，成功后会得到服务器返回的数据
    
    
    if (returnData)
    {
        NSLog(@"returndata = %@", [MicroAidAPI toDictionary:returnData]);
        return [MicroAidAPI toDictionary:returnData];
        
    }else{
        NSLog(@"returndata = %@", @"服务器无响应");
        
    }
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
    
}


//15 获取用户头像
+(NSDictionary *)fetchPicture:(NSInteger)userID{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/user/findPictuerByUserID.action?userID=%ld",ipAddr,(long)userID];
    
    NSLog(@"fetchPictureURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//16 获取附近任务列表2(已完成、已发起、已接受等)
+(NSDictionary *)getMissionList2:(NSInteger)userID recUserID:(NSInteger)recUserID statusList:(NSArray *)statusList longitude:(double)longitude latitude:(double)latitude pageNo:(NSInteger)pageNo pageSize:(NSInteger)pageSize{
    NSError *error = nil;
    
    NSString *status = [[NSString alloc]init];
    status = @"[";
    for(int i=0; i<statusList.count; i++){
        status = [status stringByAppendingString:[statusList objectAtIndex:i]];
        status = [status stringByAppendingString:@","];
    }
    status = [status substringToIndex:status.length-1];
    status = [status stringByAppendingString:@"]"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/task/getTaskWithFilter?taskFilterString={",ipAddr];
    
    if(userID != 0){
        urlString = [urlString stringByAppendingFormat:@"\"userID\":\"%ld\",",(long)userID];
    }
    if(recUserID !=0){
        urlString = [urlString stringByAppendingFormat:@"\"recUserID\":\"%ld\",",(long)recUserID];
    }
    urlString = [urlString stringByAppendingFormat:@"\"longitude\":\"%f\",\"latitude\":\"%f\",\"statusList\":%@}&pageNo=%ld&pageSize=%ld",longitude,latitude,status,(long)pageNo,(long)pageSize];
    
    
    NSLog(@"getMissionList2URL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//17 获取任务信息
+(NSDictionary *)fetchMission:(NSInteger)missionID{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/task/getTaskByTaskID?taskID=%ld",ipAddr,(long)missionID];
    
    NSLog(@"fetchMissionURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[MicroAidAPI toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

//18 修改任务
+(NSDictionary *)updateMission:(Mission *)mission{
    NSError *error = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/MICRA_AID/task/updateTask.action?taskPOString={\"id\":\"%ld\",\"userID\":\"%ld\",\"title\":\"%@\",\"taskType\":\"%@\",\"taskScores\":\"%@\",\"startTime\":\"%@\",\"endTime\":\"%@\",\"status\":\"%ld\",\"description\":\"%@\",\"address\":\"%@\",\"longitude\":\"%f\",\"latitude\":\"%f\",\"publicity\":\"%@\"}",ipAddr,(long)mission.missionID,(long)mission.userID,mission.title,mission.type,mission.bonus,mission.startTime,mission.endTime,mission.status,mission.descript,mission.address,mission.longitude,mission.latitude,mission.group];
    
    NSLog(@"updateMissionUserURL:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (data)
    {
        return [MicroAidAPI toDictionary:data];
    }
    
    //NSLog(@"result: %@",[SmartHomeAPIs toDictionary:data]);
    
    return [[NSDictionary alloc]initWithObjectsAndKeys:@"fail",@"result",nil];
}

@end
