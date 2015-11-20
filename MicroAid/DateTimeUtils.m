//
//  DateTimeUtils.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/1.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "DateTimeUtils.h"

@implementation DateTimeUtils

+(NSDate *)getCurrentTime{
    NSDate *date = [NSDate date];
    /*NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:interval];*/
    return date;
}


+(NSDate *)getCurrentTimeAfterAnHour{
    NSDate *date = [NSDate date];
    date = [[NSDate alloc] initWithTimeInterval:3600 sinceDate:date];
    /*NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:interval];*/
    return date;
}


//例如 2015-09-01 10:20
+(NSDate *)changeStringIntoDate:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    return [dateFormatter dateFromString:dateString];
}


+(NSString *)changeDateIntoString:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    return [dateFormatter stringFromDate:date];
}

+(BOOL)isOutOfDate:(NSString *)dateString{
    NSDate *currentDate = [self getCurrentTime];
    NSDate *testDate = [self changeStringIntoDate:dateString];
    if([currentDate timeIntervalSinceDate:testDate]> 0.0){
        return YES;
    }else{
        return NO;
    }
}



@end
