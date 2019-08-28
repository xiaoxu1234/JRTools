//
//  BFRegex.h
//  BigFourTools
//
//  Created by xiaoxu on 2019/6/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFRegex : NSObject
+ (BOOL)validateEOSAccount:(NSString *)account;
+ (BOOL)validatePassword:(NSString *)passWord;
@end

NS_ASSUME_NONNULL_END
