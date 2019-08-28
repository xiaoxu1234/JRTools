//
//  BFTimer.h
//  BigFourTools
//
//  Created by xiaoxu on 2019/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface BFTimer : NSObject
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval loopActionBlock:(void(^)(void))loopAction;
-(void)resume;
-(void)pause;
@end

NS_ASSUME_NONNULL_END
