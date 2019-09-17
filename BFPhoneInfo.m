//
//  BFPhoneInfo.m
//  BigFourTools
//
//  Created by xiaoxu on 2019/6/11.
//

#import "BFPhoneInfo.h"
@implementation BFPhoneInfo
@synthesize language = _language;

+ (instancetype)sharedInfo {
    static BFPhoneInfo *_sharedInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInfo = [[self alloc] init];
    });
    return _sharedInfo;
}


+ (NSString *)getDeviceID {
    NSString *deviceID = [[NSUserDefaults standardUserDefaults] objectForKey:@"BFDeviceID"];
    if (!deviceID) {
        deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:deviceID?:@"" forKey:@"BFDeviceID"];
    }
    return deviceID;
}

- (NSString *)language {
    if (!_language) {
        //获取当前设备语言
        _language = [[NSUserDefaults standardUserDefaults] objectForKey:@"lang"];
        if (!_language) {
            NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
            _language = [appLanguages objectAtIndex:0];
            if ([_language hasPrefix:@"en"]) {
                _language = @"en_US";
            } else {
                _language = @"zh_CN";
            }
        }
    }
    return _language;
}

- (void)setLanguage:(NSString *)language {
    if (_language != language) {
        _language = language;
        [[NSUserDefaults standardUserDefaults] setObject:_language forKey:@"lang"];
    }
}
@end
