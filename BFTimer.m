//
//  BFTimer.m
//  BigFourTools
//
//  Created by xiaoxu on 2019/6/26.
//

#import "BFTimer.h"
@interface BFTimer()
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property(nonatomic,strong) dispatch_source_t timer;
@property (nonatomic, copy) dispatch_block_t loopAction;
@end

@implementation BFTimer
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval loopActionBlock:(void(^)(void))loopAction {
    if (self = [super init]) {
        self.timeInterval = timeInterval;
        self.loopAction = loopAction;
    }
    return self;
}

- (void)loadTimer:(NSTimeInterval)loopTime {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    dispatch_queue_t queue = dispatch_get_main_queue();
    //创建一个定时器（dispatch_source_t本质上还是一个OC对象）
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    //设置定时器的各种属性
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0*NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(loopTime*NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    
    //设置回调
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
        //定时器需要执行的操作
        weakSelf.loopAction();
    });
    //启动定时器（默认是暂停）
    dispatch_resume(self.timer);
}

-(void)resume{
    //重新加载一次定时器
    [self loadTimer:self.timeInterval];
}

-(void)pause{
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)dealloc {
    NSLog(@"BFTimer --- dealloc");
}
@end
