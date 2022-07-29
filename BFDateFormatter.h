//
//  BFDateFormatter.h
//  BigFourTools
//
//  Created by xiaoxu on 2019/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFDateFormatter : NSObject
+ (NSString *)getTimeFromTimestamp:(NSTimeInterval)timestamp;

+ (NSString *)convertCurrentTimeToUTC;

+ (NSString *)convertUTCTimeToCurrent:(NSString *)utcTime;
@end

NS_ASSUME_NONNULL_END
