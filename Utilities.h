//
//  Utilities.h
//  BigFourModule
//
//  Created by zhangmucoder on 2019/4/29.
//

#ifndef Utilities_h
#define Utilities_h

// 图片路径
#define BFSrcName(file, bundle) [[NSString stringWithFormat:@"%@.bundle", bundle] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@%.0fx.png",file,[UIScreen mainScreen].scale]]

#define BFFrameworkSrcName(file, bundle) [[NSString stringWithFormat:@"Frameworks/%@.framework/%@.bundle", bundle, bundle] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@%.0fx.png",file,[UIScreen mainScreen].scale]]

#define BFImageInBundle(file, bundle)  [UIImage imageNamed:BFSrcName(file, bundle)] ? : [UIImage imageNamed:BFFrameworkSrcName(file, bundle)]


static inline  NSString *BigGetGlobalcColor(NSString *colorStr) {
    return [NSString stringWithFormat:@"Global.%@",colorStr];
}
static inline  NSString *BigGetImg(NSString *imgKey) {
    return [NSString stringWithFormat:@"img.%@",imgKey];
}
static inline  NSString *BigGetimgBundle(){
    return @"imgBundle.bigWallet";
}

static inline NSString *currentdateInterval(){
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}

#endif /* Utilities_h */
