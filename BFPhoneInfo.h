//
//  BFPhoneInfo.h
//  BigFourTools
//
//  Created by xiaoxu on 2019/6/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface BFPhoneInfo : NSObject
@property (nonatomic, strong) NSString *language;
+ (instancetype)sharedInfo;
+ (NSString *)getDeviceID;
@end

NS_ASSUME_NONNULL_END
