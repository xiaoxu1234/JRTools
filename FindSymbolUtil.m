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

- (BOOL)test2 {
    const char *functionName = "__ZN5dyld46Loader18expandAtLoaderPathERNS_12RuntimeStateEPKcRKNS0_11LoadOptionsEPKS0_bPc";
    const char *dyldPath = "/usr/lib/dyld";

    // 1. 读取 dyld 文件
    FILE *fp = fopen(dyldPath, "rb");
    if (fp == NULL) {
        NSLog(@"[scam_dyld] 无法打开 %s", dyldPath);
        return NO;
    }

    // 2. 解析 Mach-O 文件头
    struct mach_header_64 header;
    if (fread(&header, sizeof(struct mach_header_64), 1, fp) != 1) {
        fclose(fp);
        NSLog(@"[scam_dyld] 读取文件头失败");
        return NO;
    }

    // 检查魔数
    if (header.magic != MH_MAGIC_64) {
        fclose(fp);
        NSLog(@"[scam_dyld] 不是有效的 Mach-O 文件");
        return NO;
    }

    // 3. 定位符号表和 __TEXT 段
    // 遍历 Mach-O 文件的 load commands，查找以下关键信息：
    // - __TEXT.__text 段：存储代码指令的区域，用于计算函数的文件偏移
    // - LC_SYMTAB 符号表命令：包含符号表和字符串表的位置信息
    uint64_t textSectionOffset = 0;    // __TEXT 段在文件中的偏移
    uint64_t textSectionAddr = 0;      // __TEXT 段的虚拟地址（首选加载地址）
    uint64_t textSize = 0;             // __TEXT 段的大小
    uint64_t symbolTableOffset = 0;    // 符号表在文件中的偏移
    uint64_t stringTableOffset = 0;    // 字符串表在文件中的偏移
    uint32_t nlistCount = 0;           // 符号表中符号的数量
    uint64_t functionFileOffset = 0;   // 目标函数在 dyld 文件中的偏移位置
    uint64_t functionVMAddr = 0;       // 目标函数的虚拟地址
    uint64_t slide = 0;                // ASLR 滑动偏移

    // 读取 load commands
    long currentOffset = sizeof(struct mach_header_64);  // 跳过 mach_header，从 load commands 开始
    for (uint32_t i = 0; i < header.ncmds; i++) {        // 遍历每个 load command
        struct load_command cmd;
        fseek(fp, currentOffset, SEEK_SET);
        if (fread(&cmd, sizeof(struct load_command), 1, fp) != 1) {
            break;
        }

        switch (cmd.cmd) {  // 根据 load command 类型处理
            case LC_SEGMENT_64: {  // 处理 64 位段加载命令
                struct segment_command_64 segment;
                fseek(fp, currentOffset, SEEK_SET);
                if (fread(&segment, sizeof(struct segment_command_64), 1, fp) != 1) {
                    break;
                }

                // 遍历段中的所有 section
                long sectionOffset = currentOffset + sizeof(struct segment_command_64);
                for (uint32_t j = 0; j < segment.nsects; j++) {
                    struct section_64 section;
                    fseek(fp, sectionOffset, SEEK_SET);
                    if (fread(&section, sizeof(struct section_64), 1, fp) != 1) {
                        break;
                    }

                    // 查找 __TEXT.__text 段，这是代码段
                    if (strcmp(section.segname, "__TEXT") == 0 &&
                        strcmp(section.sectname, "__text") == 0) {
                        textSectionOffset = section.offset;  // 文件偏移
                        textSectionAddr = section.addr;      // 虚拟地址
                        textSize = section.size;              // 段大小
                    }

                    sectionOffset += sizeof(struct section_64);
                }
                break;
            }
            case LC_SYMTAB: {  // 处理符号表加载命令
                struct symtab_command symtab;
                fseek(fp, currentOffset, SEEK_SET);
                if (fread(&symtab, sizeof(struct symtab_command), 1, fp) != 1) {
                    break;
                }
                symbolTableOffset = symtab.symoff;  // 符号表的文件偏移
                stringTableOffset = symtab.stroff;  // 字符串表的文件偏移
                nlistCount = symtab.nsyms;          // 符号数量
                break;
            }
        }

        currentOffset += cmd.cmdsize;  // 跳到下一个 load command
    }

    // 验证必要信息是否找到
    if (textSectionOffset == 0 || symbolTableOffset == 0) {
        fclose(fp);
        NSLog(@"[scam_dyld] 未找到必要的段");
        return NO;
    }

    // 4. 将整个符号表读入内存，避免 fseek 问题
    // 一次性读取所有符号到内存数组，因为逐个符号读取和 fseek 到字符串表会导致文件指针位置混乱
    fseek(fp, symbolTableOffset, SEEK_SET);
    struct nlist_64 *nlistArray = (struct nlist_64 *)malloc(sizeof(struct nlist_64) * nlistCount);
    if (nlistArray == NULL) {
        fclose(fp);
        NSLog(@"[scam_dyld] 内存分配失败");
        return NO;
    }

    size_t readCount = fread(nlistArray, sizeof(struct nlist_64), nlistCount, fp);
    if (readCount != nlistCount) {
        free(nlistArray);
        fclose(fp);
        NSLog(@"[scam_dyld] 读取符号表失败");
        return NO;
    }

    // 5. 在内存中查找函数符号
    // 遍历符号表数组，查找目标函数名
    for (uint32_t i = 0; i < nlistCount; i++) {
        struct nlist_64 nlist = nlistArray[i];

        if (nlist.n_un.n_strx > 0) {  // 如果有字符串索引
            // 从字符串表中读取符号名
            fseek(fp, stringTableOffset + nlist.n_un.n_strx, SEEK_SET);
            char symbolName[256];
            if (fgets(symbolName, sizeof(symbolName), fp) != NULL) {
                NSLog(@"symbolName = %s", symbolName);
                if (strcmp(symbolName, functionName) == 0) {
                    // 找到目标符号，记录其位置
                    // 计算函数在文件中的偏移 = __TEXT段偏移 + (函数虚拟地址 - __TEXT段虚拟地址)
                    functionFileOffset = textSectionOffset + (nlist.n_value - textSectionAddr);
                    functionVMAddr = nlist.n_value;  // 记录函数的虚拟地址（相对于 dyld 基址的偏移）

                    NSLog(@"[scam_dyld] 找到函数符号: %s, 地址: 0x%llX", functionName, functionVMAddr);

                    free(nlistArray);  // 释放符号表内存
                    break;
                }
            }
        }
    }

    // 如果没有找到目标函数，搜索包含特定子串的符号用于调试
    if (functionFileOffset == 0) {
        NSLog(@"[scam_dyld] 未在符号表中直接找到函数，尝试搜索所有符号...");

        for (uint32_t i = 0; i < nlistCount; i++) {
            struct nlist_64 nlist = nlistArray[i];

            if (nlist.n_un.n_strx > 0) {
                fseek(fp, stringTableOffset + nlist.n_un.n_strx, SEEK_SET);
                char symbolName[256];
                if (fgets(symbolName, sizeof(symbolName), fp) != NULL) {
                    if (strstr(symbolName, "loadDyldCache")) {
                        NSLog(@"[scam_dyld] 找到相关符号: %s, 值: 0x%llX, 类型: 0x%x", symbolName, nlist.n_value, nlist.n_type);
                    }
                }
            }
        }

        free(nlistArray);
        fclose(fp);
        NSLog(@"[scam_dyld] 未在符号表中找到函数");
        return NO;
    }

    // 6. 读取磁盘上的函数指令
    // 从文件中读取目标函数的第一条机器指令，作为对比基准
    fseek(fp, functionFileOffset, SEEK_SET);
    uint32_t diskInstr;
    if (fread(&diskInstr, sizeof(uint32_t), 1, fp) != 1) {
        fclose(fp);
        NSLog(@"[scam_dyld] 读取磁盘指令失败");
        return NO;
    }

    fclose(fp);  // 关闭 dyld 文件

    // 7. 获取 dyld 在内存中的地址 - 通过指令匹配找到正确的 dyld
    // dyld 不在常规的 dyld 镜像列表中，需要遍历 VM 内存区域查找
    // 策略：在每个找到的 Mach-O 文件的 functionVMAddr 偏移处读取指令，匹配到 diskInstr 的就是 dyld
    void *dyldBase = NULL;
    kern_return_t kr;

    // 从较宽的地址范围搜索，查找包含目标函数的 Mach-O
    // 0x100000000 (4GB) 开始，覆盖共享缓存区域
    vm_address_t address = 0x100000000;
    vm_address_t endAddress = 0x7FFFFFFFF000ULL;  // 内核预留区域边界

    NSLog(@"[scam_dyld] 开始搜索 dyld，目标函数偏移: 0x%llX", functionVMAddr);

    int machoCount = 0;
    while (address < endAddress) {
        struct vm_region_basic_info_64 info;
        mach_msg_type_number_t infoCount = VM_REGION_BASIC_INFO_COUNT_64;
        memory_object_name_t obj = 0;
        vm_size_t regionSize = 0;

        // 查询当前内存区域信息
        kr = vm_region_64(mach_task_self(),
                         &address,
                         &regionSize,
                         VM_REGION_BASIC_INFO_64,
                         (vm_region_info_t)&info,
                         &infoCount,
                         &obj);

        if (kr != KERN_SUCCESS) {
            break;  // 查询失败或到达内存末尾，退出循环
        }

        // 检查区域是否可读且足够大以包含目标函数
        if ((info.protection & VM_PROT_EXECUTE) && regionSize > functionVMAddr) {
            vm_size_t dataSize = sizeof(struct mach_header_64);
            struct mach_header_64 testHeader;

            // 读取内存中的 Mach-O 头部
            kr = vm_read_overwrite(mach_task_self(),
                                  address,
                                  sizeof(struct mach_header_64),
                                  (vm_address_t)&testHeader,
                                  &dataSize);

            if (kr == KERN_SUCCESS && testHeader.magic == MH_MAGIC_64) {
                NSLog(@"address = 0x%lx", address);
                machoCount++;  // 找到一个有效的 Mach-O 文件

                // 在函数偏移处读取指令
                // 函数在内存中的地址 = Mach-O基址 + 函数偏移
                vm_address_t functionAddr = address + functionVMAddr;
                uint32_t memoryInstr;
                vm_size_t instrSize = sizeof(uint32_t);

                kr = vm_read_overwrite(mach_task_self(),
                                      functionAddr,
                                      sizeof(uint32_t),
                                      (vm_address_t)&memoryInstr,
                                      &instrSize);

                if (kr == KERN_SUCCESS && instrSize == sizeof(uint32_t)) {
                    // 对比磁盘指令，如果匹配说明找到了正确的 dyld
                    if (memoryInstr == diskInstr) {
                        // 找到匹配的 dyld！
                        dyldBase = (void *)address;
                        NSLog(@"[scam_dyld] ✓ 找到 dyld！基址: %p, 函数偏移: 0x%llX, 匹配指令: 0x%08X",
                              dyldBase, functionVMAddr, memoryInstr);
                        NSString *ctx = [NSString stringWithFormat:@"[scam_dyld] ✓ 找到 dyld！基址: %p, 函数偏移: 0x%llX, 匹配指令: 0x%08X",
                                         dyldBase, functionVMAddr, memoryInstr];
                        break;
                    }
                }

                // 限制检查数量避免耗时太长
                if (machoCount % 10 == 0) {
                    NSLog(@"[scam_dyld] 已检查 %d 个 Mach-O 文件...", machoCount);
                }

                if (machoCount > 200) {
                    NSLog(@"[scam_dyld] 检查了太多文件，停止搜索");
                    break;
                }
            }
        }

        // 跳到下一个内存区域
        address += regionSize;
    }

    NSLog(@"[scam_dyld] 总共检查了 %d 个 Mach-O 文件", machoCount);

    if (dyldBase == NULL) {
        NSLog(@"[scam_dyld] 未找到 dyld 在内存中的地址");
        fclose(fp);
        return NO;
    }

    // 计算函数在内存中的地址（dyld 在共享缓存中，__TEXT 基址为 0）
    // dyld 位于 dyld shared cache 中，其虚拟地址直接就是相对基址的偏移
    void *functionPtr = (void *)((uint64_t)dyldBase + functionVMAddr);

    // 重新读取内存中的函数指令进行对比，确保读取成功
    uint32_t memoryInstr;
    vm_size_t nsize = sizeof(uint32_t);
    kern_return_t nkr = vm_read_overwrite(mach_task_self(),
                                          (vm_address_t)functionPtr,
                                          nsize,
                                          (vm_address_t)&memoryInstr,
                                          &nsize);

    if (nkr != KERN_SUCCESS || nsize != sizeof(uint32_t)) {
        NSLog(@"[scam_dyld] vm_read_overwrite 失败: %d", nkr);
        fclose(fp);
        return NO;
    }

    NSLog(@"[scam_dyld] dyld 基址: %p, 函数偏移: 0x%llX, 函数地址: %p", dyldBase, functionVMAddr, functionPtr);
    NSLog(@"[scam_dyld] 磁盘指令: 0x%08X, 内存指令: 0x%08X", diskInstr, memoryInstr);

    // 8. 比较内存和磁盘上的指令 - 这是主要的检测方法
    // 如果内存中的指令与磁盘文件中的原始指令不同，说明函数被修改，可能被 HOOK
    if (memoryInstr != diskInstr) {
        NSLog(@"[scam_dyld] ⚠️ 检测到函数 %s 可能被 HOOK！", functionName);
        NSLog(@"[scam_dyld] 指令不匹配，可能被替换或修改");
        return YES;
    }

    // 9. 检测特定 hook 特征指令
    // 除了指令对比外，还可以检测某些特定的常见 hook 模式

    // BRK 指令 (常用于动态 hook 框架插入断点)
    // 0xD4200000 是 ARM64 的 BRK #0 指令，hook 框架常用于触发动态处理
    if (memoryInstr == 0xD4200000) {
        NSLog(@"[scam_dyld] ⚠️ 检测到 BRK 指令，可能被 HOOK");
        return YES;
    }

    // 无条件跳转指令 B (常用于 inline hook 技术跳转到替换代码)
    // 0x14000000 是 B 指令的前缀 (opcode)，后面 26 位是跳转偏移量
    // inline hook 会将函数开头的几条指令替换为 B 指令，跳转到 trampoline 函数
    if ((memoryInstr & 0xFC000000) == 0x14000000) {
        NSLog(@"[scam_dyld] ⚠️ 检测到无条件跳转指令: 0x%08X，可能被 HOOK", memoryInstr);
        return YES;
    }

    // 检查是否是 LDR 指令加载 PC 相对地址 (常用作调用动态生成的 trampoline)
    // 0x58xxxxxx 是 LDR 指令加载字面量到寄存器的格式
    // 某些 hook 框架会使用 LDR 加载函数指针，通过修改字面量池来改变跳转目标
    if ((memoryInstr & 0xFF000000) == 0x58000000) {
        int32_t imm19 = (memoryInstr & 0x7FFFF) << 2;
        if ((imm19 & 0x40000)) {
            imm19 |= 0xFFFFF80000;  // 符号扩展，处理有符号偏移
        }
        // LDR 指令加载到 PC (X16/X17) 的特殊形式
        if ((memoryInstr & 0x0000FC00) == 0x00000000) {
            NSLog(@"[scam_dyld] ⚠️ 检测到 LDR 指令加载函数指针，可能被 HOOK");
            return YES;
        }
    }

    // 所有检测都通过，函数未被 HOOK
    NSLog(@"[scam_dyld] ✓ 函数 %s 未被 HOOK", functionName);
    return NO;
}

@end
