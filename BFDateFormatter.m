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

@end
