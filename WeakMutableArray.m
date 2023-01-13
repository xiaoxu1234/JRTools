//
//  WeakMutableArray.m
//  TestDemo
//
//  Created by xiao xu on 2021/4/14.
//

#import "WeakMutableArray.h"

@interface WeakMutableArray ()
@property (nonatomic, strong) NSPointerArray  *pointerArray;
@end

@implementation WeakMutableArray

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.pointerArray = [NSPointerArray weakObjectsPointerArray];
}

- (void)addObject:(id)object {
    [self.pointerArray addPointer:(__bridge void *)(object)];
}

- (id)objectAtWeakMutableArrayIndex:(NSUInteger)index {
    return [self.pointerArray pointerAtIndex:index];
}

#pragma mark - 重写getter方法
@synthesize allObjects = _allObjects;
- (NSArray *)allObjects {
    return self.pointerArray.allObjects;
}
@synthesize usableCount = _usableCount;
- (NSInteger)usableCount {
    return self.pointerArray.allObjects.count;
}
@synthesize allCount = _allCount;
- (NSInteger)allCount {
    return self.pointerArray.count;
}
@end
