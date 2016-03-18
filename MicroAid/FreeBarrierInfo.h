//
//  FreeBarrierInfo.h
//  MicroAid
//
//  Created by jiahuaxu on 16/3/17.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FreeBarrierInfo : NSObject

@property(nonatomic)NSInteger infoID;
@property(strong,nonatomic)NSString *title;//标题
@property(strong,nonatomic)NSString *infoDescription;//描述
@property(strong,nonatomic)NSString *location;//位置
@property(strong,nonatomic)NSString *time;//最后修改时间
@property(assign,nonatomic)double latitude;
@property(assign,nonatomic)double longitude;
@property(strong,nonatomic)NSString *tel;//电话
@property(strong,nonatomic)NSString *userName;//修改人名称

+(NSMutableArray *)getFreeBarrierInfos:(NSArray *)dataArray;

@end
