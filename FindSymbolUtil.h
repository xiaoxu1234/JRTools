//
//  FindSymbolUtil.h
//  MyOCDemo
//
//  Created by 肖旭 on 2026/2/3.
//

#import <Foundation/Foundation.h>
#include <mach/mach.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>

void *FindSymbolFromMachHeader(const struct mach_header *header, intptr_t slide, NSString *symbolName);

@interface FindSymbolUtil : NSObject
- (void)test;
- (BOOL)test2;
@end
