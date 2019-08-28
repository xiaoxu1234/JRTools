//
//  BFRegex.m
//  BigFourTools
//
//  Created by xiaoxu on 2019/6/18.
//

#import "BFRegex.h"

@implementation BFRegex
+ (BOOL)validateEOSAccount:(NSString *)account {
    NSString *accountRegex = @"^[12345abcdefghijklmnopqrstuvwxyz]{12}$";
    NSPredicate *accountTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", accountRegex];
    return [accountTest evaluateWithObject:account];
}

+ (BOOL)validatePassword:(NSString *)passWord {
    NSString *passWordRegex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,20}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}
@end
