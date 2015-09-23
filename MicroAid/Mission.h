//
//  Mission.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/6.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mission : NSObject

@property(nonatomic)NSInteger missionID;
@property(nonatomic)NSInteger userID;
@property(nonatomic)NSInteger status;
@property(strong,nonatomic)NSString *title;
@property(strong,nonatomic)NSString *type;
@property(strong,nonatomic)NSString *bonus;
@property(strong,nonatomic)NSString *startTime;
@property(strong,nonatomic)NSString *endTime;
@property(strong,nonatomic)NSString *descript;
@property(strong,nonatomic)NSString *address;
@property(strong,nonatomic)NSString *group;
@property(nonatomic)double longitude;
@property(nonatomic)double latitude;

-(BOOL) verifyInfo;


@end
