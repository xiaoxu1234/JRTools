//
//  WeakMutableArray.h
//  TestDemo
//
//  Created by xiao xu on 2021/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeakMutableArray : NSObject


/**
 *  获取所有有效的对象
 */
@property (nonatomic, strong, readonly)  NSArray    *allObjects;

/**
 *  数组中有用对象的个数
 */
@property (nonatomic, readonly)          NSInteger   usableCount;


/**
 *  数组中所有对象的个数(包括NULL)
 */
@property (nonatomic, readonly)          NSInteger   allCount;


/**
 *  添加对象
 *
 *  @param object 被添加对象
 */
- (void)addObject:(id)object;


/**
 *  获取数组中的对象(可以获取到NULL对象)
 *
 *  @param index 数组下标
 *
 *  @return 对象
 */
- (id)objectAtWeakMutableArrayIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
