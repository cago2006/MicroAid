//
//  DateTimeUtils.h
//  MicroAid
//
//  Created by jiahuaxu on 15/9/1.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeUtils : NSObject

+(NSDate *)getCurrentTime;
+(NSDate *)getCurrentTimeAfterAnHour;
+(NSDate *)changeStringIntoDate:(NSString *)dateString;//例如 2015-09-01 10:20
+(NSString *)changeDateIntoString:(NSDate *)date;
+(BOOL)isOutOfDate:(NSString *)dateString;

@end
