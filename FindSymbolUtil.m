//
//  FindSymbolUtil.m
//  MyOCDemo
//
//  Created by 肖旭 on 2026/2/3.
//

#import "FindSymbolUtil.h"


void *FindSymbolFromMachHeader(const struct mach_header *header, intptr_t slide, NSString *symbolName) {
    if (!header || symbolName.length == 0) return NULL;
    if (header->magic != MH_MAGIC_64) return NULL;
    
    const struct mach_header_64 *mh = (const struct mach_header_64 *)header;
    const uint8_t *cmds = (const uint8_t *)(mh + 1);
    
    const struct symtab_command *symtab = NULL;
    const struct segment_command_64 *linkedit = NULL;
    
    const struct load_command *cmd = (const struct load_command *)cmds;
    
    for (uint32_t i = 0; i < mh->ncmds; i++) {
        if (cmd->cmd == LC_SYMTAB) {
            symtab = (const struct symtab_command *)cmd;
        } else if (cmd->cmd == LC_SEGMENT_64) {
            const struct segment_command_64 *seg = (const struct segment_command_64 *)cmd;
            if (strcmp(seg->segname, SEG_LINKEDIT) == 0) {
                linkedit = seg;
            }
        }
        cmd = (const struct load_command *)((uint8_t *)cmd + cmd->cmdsize);
    }
    
    if (!symtab || !linkedit) return NULL;
    
    // 关键：算 __LINKEDIT 的真实内存基址
    uintptr_t linkeditBase = (uintptr_t)(linkedit->vmaddr + slide - linkedit->fileoff);
    
    const struct nlist_64 *symbols = (const struct nlist_64 *)(linkeditBase + symtab->symoff);
    
    const char *strtab = (const char *)(linkeditBase + symtab->stroff);
    
    const char *target = symbolName.UTF8String;
    
    for (uint32_t i = 0; i < symtab->nsyms; i++) {
        uint32_t strx = symbols[i].n_un.n_strx;
        if (strx == 0) continue;
        
        const char *name = strtab + strx;
        NSLog(@"name = %s", name);
        if (strcmp(name, target) == 0) {
            return (void *)(symbols[i].n_value + slide);
        }
    }
    
    return NULL;
}

@implementation FindSymbolUtil

- (void)test {
    for (int i = 0; i < _dyld_image_count(); i++) {
        char *image_name = (char *)_dyld_get_image_name(i);
        NSLog(@"image_name = %s", image_name);
        if (strstr(image_name, "systemhook")) {
            const struct mach_header *header = _dyld_get_image_header(i);
            intptr_t slide = _dyld_get_image_vmaddr_slide(i);
            void *addr = FindSymbolFromMachHeader(header, slide, @"_JB_RootPath");
            if (addr) {
                
            }
        }
    }
}

@end
