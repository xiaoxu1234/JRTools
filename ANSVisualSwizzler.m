//
//  MPSwizzler.m
//  HelloMixpanel
//
//  Created by Alex Hofsteede on 1/5/14.
//  Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "ANSVisualSwizzler.h"

#import "AnalysysLogger.h"

#define MIN_ARGS 2
#define MAX_ARGS 6

@interface ANSVisualSwizzle : NSObject

@property (nonatomic, assign) Class class;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) IMP originalMethod;
@property (nonatomic, assign) uint numArgs;
@property (nonatomic, copy) NSMapTable *blocks;

- (instancetype)initWithBlock:(swizzleBlock)aBlock
              named:(NSString *)aName
           forClass:(Class)aClass
           selector:(SEL)aSelector
     originalMethod:(IMP)aMethod
        withNumArgs:(uint)numArgs;

@end

static NSMapTable *ans_visual_swizzles;

static id cellForRowAtIndexPath(id self, SEL _cmd, id arg, id arg2)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSVisualSwizzle *swizzle = (ANSVisualSwizzle *)[ans_visual_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        id ret = ((id(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(ret, self, _cmd, arg, arg2);
        }
        return ret;
    }
    return nil;
}

static id viewForHeaderInSection(id self, SEL _cmd, id arg, NSInteger arg2)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSVisualSwizzle *swizzle = (ANSVisualSwizzle *)[ans_visual_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        id ret = ((id(*)(id, SEL, id, NSInteger))swizzle.originalMethod)(self, _cmd, arg, arg2);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(ret, self, _cmd, arg, arg2);
        }
        return ret;
    }
    return nil;
}

static id viewForFooterInSection(id self, SEL _cmd, id arg, NSInteger arg2)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSVisualSwizzle *swizzle = (ANSVisualSwizzle *)[ans_visual_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        id ret = ((id(*)(id, SEL, id, NSInteger))swizzle.originalMethod)(self, _cmd, arg, arg2);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(ret, self, _cmd, arg, arg2);
        }
        return ret;
    }
    return nil;
}

static id cellForItemAtIndexPath(id self, SEL _cmd, id arg, id arg2)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSVisualSwizzle *swizzle = (ANSVisualSwizzle *)[ans_visual_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        id ret = ((id(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(ret, self, _cmd, arg, arg2);
        }
        return ret;
    }
    return nil;
}

static id viewForSupplementaryElementOfKind(id self, SEL _cmd, id arg, id arg2, id arg3)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSVisualSwizzle *swizzle = (ANSVisualSwizzle *)[ans_visual_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        id ret = ((id(*)(id, SEL, id, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2, arg3);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(ret, self, _cmd, arg, arg2, arg3);
        }
        return ret;
    }
    return nil;
}

static void didSelectRow(id self, SEL _cmd, id arg, id arg2)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSVisualSwizzle *swizzle = (ANSVisualSwizzle *)[ans_visual_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
        
        ((void(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);
    }
}

static void didDeselectRow(id self, SEL _cmd, id arg, id arg2)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSVisualSwizzle *swizzle = (ANSVisualSwizzle *)[ans_visual_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
        
        ((void(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);
    }
}

static void didSelectItem(id self, SEL _cmd, id arg, id arg2)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSVisualSwizzle *swizzle = (ANSVisualSwizzle *)[ans_visual_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
        
        ((void(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);
    }
}

static void didDeselectItem(id self, SEL _cmd, id arg, id arg2)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSVisualSwizzle *swizzle = (ANSVisualSwizzle *)[ans_visual_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
        
        ((void(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);
    }
}

// Ignore the warning cause we need the paramters to be dynamic and it's only being used internally
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
//static void (*mp_swizzledMethods[MAX_ARGS - MIN_ARGS + 1])() = {mp_swizzledMethod_2, mp_swizzledMethod_3, mp_swizzledMethod_4, mp_swizzledMethod_5};
//
//static BOOL (*mp_swizzledMethods_bool[MAX_ARGS - MIN_ARGS + 1])() = {mp_swizzledMethod_2_bool, mp_swizzledMethod_3_bool, mp_swizzledMethod_4_bool, mp_swizzledMethod_5_bool, mp_swizzledMethod_6_bool};
//
//static id (*mp_swizzledMethods_id[MAX_ARGS - MIN_ARGS + 1])() = {mp_swizzledMethod_2_id, mp_swizzledMethod_3_id, mp_swizzledMethod_4_id, mp_swizzledMethod_5_id};

static id (*ans_cellForRowAtIndexPath)() = cellForRowAtIndexPath;
static id (*ans_viewForHeaderInSection)() = viewForHeaderInSection;
static id (*ans_viewForFooterInSection)() = viewForFooterInSection;
static id (*ans_cellForItemAtIndexPath)() = cellForItemAtIndexPath;
static id (*ans_viewForSupplementaryElementOfKind)() = viewForSupplementaryElementOfKind;
static void (*ans_didSelectRow)() = didSelectRow;
static void (*ans_didDeselectRow)() = didDeselectRow;
static void (*ans_didSelectItem)() = didSelectItem;
static void (*ans_didDeselectItem)() = didDeselectItem;
#pragma clang diagnostic pop

@implementation ANSVisualSwizzler

+ (void)load
{
    ans_visual_swizzles = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality)
                                     valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];
}

+ (void)printSwizzles
{
    NSEnumerator *en = [ans_visual_swizzles objectEnumerator];
    ANSVisualSwizzle *swizzle;
    while ((swizzle = (ANSVisualSwizzle *)[en nextObject])) {
        ANSVisualBriefError(@"%@", swizzle);
    }
}

+ (ANSVisualSwizzle *)swizzleForMethod:(Method)aMethod
{
    return (ANSVisualSwizzle *)[ans_visual_swizzles objectForKey:MAPTABLE_ID(aMethod)];
}

+ (void)removeSwizzleForMethod:(Method)aMethod
{
    [ans_visual_swizzles removeObjectForKey:MAPTABLE_ID(aMethod)];
}

+ (void)setSwizzle:(ANSVisualSwizzle *)swizzle forMethod:(Method)aMethod
{
    [ans_visual_swizzles setObject:swizzle forKey:MAPTABLE_ID(aMethod)];
}

+ (BOOL)isLocallyDefinedMethod:(Method)aMethod onClass:(Class)aClass
{
    uint count;
    BOOL isLocal = NO;
    Method *methods = class_copyMethodList(aClass, &count);
    for (NSUInteger i = 0; i < count; i++) {
        if (aMethod == methods[i]) {
            isLocal = YES;
            break;
        }
    }
    free(methods);
    return isLocal;
}

+ (void)swizzleSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(swizzleBlock)aBlock named:(NSString *)aName
{
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    if (aMethod) {
        uint numArgs = method_getNumberOfArguments(aMethod);
        if (numArgs >= MIN_ARGS && numArgs <= MAX_ARGS) {
                
            BOOL isLocal = [self isLocallyDefinedMethod:aMethod onClass:aClass];
            IMP swizzledMethod;
            
//            char retType[512] = {};
//            method_getReturnType(aMethod, retType, 512);
//            NSString *retTypeStr = [NSString stringWithUTF8String:retType];
//            if ([retTypeStr isEqualToString:@"B"]) {
//                swizzledMethod = (IMP)mp_swizzledMethods_bool[numArgs - 2];
//            } else if ([retTypeStr isEqualToString:@"v"]) {
//                swizzledMethod = (IMP)mp_swizzledMethods[numArgs - 2];
//            } else {
//                swizzledMethod = (IMP)mp_swizzledMethods_id[numArgs - 2];
//            }
            
            if (aSelector == @selector(tableView:cellForRowAtIndexPath:)) {
                swizzledMethod = (IMP)ans_cellForRowAtIndexPath;
            } else if (aSelector == @selector(tableView:viewForHeaderInSection:)) {
                swizzledMethod = (IMP)ans_viewForHeaderInSection;
            } else if (aSelector == @selector(tableView:viewForFooterInSection:)) {
                swizzledMethod = (IMP)ans_viewForFooterInSection;
            } else if (aSelector == @selector(collectionView:cellForItemAtIndexPath:)) {
                swizzledMethod = (IMP)ans_cellForItemAtIndexPath;
            } else if (aSelector == @selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)) {
                swizzledMethod = (IMP)ans_viewForSupplementaryElementOfKind;
            } else if (aSelector == @selector(tableView:didSelectRowAtIndexPath:)) {
                swizzledMethod = (IMP)ans_didSelectRow;
            } else if (aSelector == @selector(tableView:didDeselectRowAtIndexPath:)) {
                swizzledMethod = (IMP)ans_didDeselectRow;
            } else if (aSelector == @selector(collectionView:didSelectItemAtIndexPath:)) {
                swizzledMethod = (IMP)ans_didSelectItem;
            } else if (aSelector == @selector(collectionView:didDeselectItemAtIndexPath:)) {
                swizzledMethod = (IMP)ans_didDeselectItem;
            } else {
                swizzledMethod = nil;
            }
            
            ANSVisualSwizzle *swizzle = [self swizzleForMethod:aMethod];
            if (isLocal) {
                if (!swizzle) {
                    IMP originalMethod = method_getImplementation(aMethod);
                        
                    // Replace the local implementation of this method with the swizzled one
                    method_setImplementation(aMethod,swizzledMethod);
                        
                    // Create and add the swizzle
                    swizzle = [[ANSVisualSwizzle alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod withNumArgs:numArgs];
                    [self setSwizzle:swizzle forMethod:aMethod];
                        
                } else {
                    [swizzle.blocks setObject:aBlock forKey:aName];
                }
            } else {
                IMP originalMethod = swizzle ? swizzle.originalMethod : method_getImplementation(aMethod);
                    
                // Add the swizzle as a new local method on the class.
                if (!class_addMethod(aClass, aSelector, swizzledMethod, method_getTypeEncoding(aMethod))) {
                    ANSVisualBriefLog(@"SwizzlerAssert: Could not add swizzled for %@::%@, even though it didn't already exist locally", NSStringFromClass(aClass), NSStringFromSelector(aSelector));
                    return;
                }
                // Now re-get the Method, it should be the one we just added.
                Method newMethod = class_getInstanceMethod(aClass, aSelector);
                if (aMethod == newMethod) {
                    ANSVisualBriefLog(@"SwizzlerAssert: Newly added method for %@::%@ was the same as the old method", NSStringFromClass(aClass), NSStringFromSelector(aSelector));
                    return;
                }
                    
                ANSVisualSwizzle *newSwizzle = [[ANSVisualSwizzle alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod withNumArgs:numArgs];
                [self setSwizzle:newSwizzle forMethod:newMethod];
            }
        } else {
            ANSVisualBriefLog(@"SwizzlerAssert: Cannot swizzle method with %d args", numArgs);
        }
    } else {
        ANSVisualBriefLog(@"SwizzlerAssert: Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass));
    }
}

+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass
{
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    ANSVisualSwizzle *swizzle = [self swizzleForMethod:aMethod];
    if (swizzle) {
        method_setImplementation(aMethod, swizzle.originalMethod);
        [self removeSwizzleForMethod:aMethod];
    }
}

/*
 Remove the named swizzle from the given class/selector. If aName is nil, remove all
 swizzles for this class/selector
*/
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName
{
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    ANSVisualSwizzle *swizzle = [self swizzleForMethod:aMethod];
    if (swizzle) {
        if (aName) {
            [swizzle.blocks removeObjectForKey:aName];
        }
        if (!aName || swizzle.blocks.count == 0) {
            method_setImplementation(aMethod, swizzle.originalMethod);
            [self removeSwizzleForMethod:aMethod];
        }
    }
}

@end


@implementation ANSVisualSwizzle

- (instancetype)init
{
    if ((self = [super init])) {
        self.blocks = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)
                                            valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];
    }
    return self;
}

- (instancetype)initWithBlock:(swizzleBlock)aBlock
              named:(NSString *)aName
           forClass:(Class)aClass
           selector:(SEL)aSelector
     originalMethod:(IMP)aMethod
        withNumArgs:(uint)numArgs
{
    if ((self = [self init])) {
        self.class = aClass;
        self.selector = aSelector;
        self.numArgs = numArgs;
        self.originalMethod = aMethod;
        [self.blocks setObject:aBlock forKey:aName];
    }
    return self;
}

- (NSString *)description
{
    NSString *descriptors = @"";
    NSString *key;
    NSEnumerator *keys = [self.blocks keyEnumerator];
    while ((key = [keys nextObject])) {
        descriptors = [descriptors stringByAppendingFormat:@"\t%@ : %@\n", key, [self.blocks objectForKey:key]];
    }
    return [NSString stringWithFormat:@"Swizzle on %@::%@ [\n%@]", NSStringFromClass(self.class), NSStringFromSelector(self.selector), descriptors];
}

@end
