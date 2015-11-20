//
//  User.h
//  MicroAid
//
//  Created by jiahuaxu on 15/8/25.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User:NSObject

@property(strong,nonatomic)NSString *username;
@property(strong,nonatomic)NSString *password;
@property(strong,nonatomic)NSString *nickName;//昵称
@property(strong,nonatomic)NSString *address;//家庭住址
@property(strong,nonatomic)NSString *email;
@property(strong,nonatomic)NSString *choiceString;//擅长内容
@property(strong,nonatomic)NSString *gender;
@property(strong,nonatomic)NSString *location;//现在所处位置
@property(strong,nonatomic)NSString *pictureString;//头像
@property(nonatomic)double longitude;
@property(nonatomic)double latitude;
@property(nonatomic)NSInteger userID;
@property(nonatomic)NSInteger scores;//积分

+(NSMutableArray *)getUserInfos:(NSArray *)dataArray;//用于unjoineduser解析
-(BOOL) verifyInfo:(NSString*)verifyPassword;
//-(void) saveUserInfo:(NSInteger)userId;

@end
