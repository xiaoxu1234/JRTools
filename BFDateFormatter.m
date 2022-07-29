//
//  BFDateFormatter.m
//  BigFourTools
//
//  Created by xiaoxu on 2019/7/24.
//

#import "BFDateFormatter.h"

@implementation BFDateFormatter
+ (NSString *)getTimeFromTimestamp:(NSTimeInterval)timestamp{
    
    //将对象类型的时间转换为NSDate类型
    
    NSDate * myDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    //设置时间格式
    
    NSDateFormatter * formatter=[[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //将时间转换为字符串
    NSString *timeStr = [formatter stringFromDate:myDate];
    
    return timeStr;
    
}

+ (NSString *)convertCurrentTimeToUTC {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dataStr = [format stringFromDate:currentDate];
    NSLog(@"世界标准时间:%@",dataStr);
    return dataStr;
}

+ (NSString *)convertUTCTimeToCurrent:(NSString *)utcTime {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [format dateFromString:utcTime];
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];

    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];

    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];

    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;

    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    NSString *str1 = [format stringFromDate:destinationDateNow];
    NSLog(@"当前时间: %@",str1);
    return str1;
}

@end
