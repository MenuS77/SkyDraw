//
//  memory_tools.hpp
//  Dolphins
//
//  Created by 梓星 on 2023/12/26.
//

#ifndef memory_tools_hpp
#define memory_tools_hpp

#include<dlfcn.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <string.h>

class MemoryTools {
private:
    int pageSize = getpagesize();
public:
    bool readMemory(uintptr_t addr, size_t size, void *buffer);
    
    bool writeMemory(uintptr_t address, size_t size, void *buffer);
    
    uintptr_t readPtr(uintptr_t addr);
    
    int readInt(uintptr_t addr);
    
    float readFloat(uintptr_t addr);
    
    bool readBool(uintptr_t addr);
};

#endif /* memory_tools_hpp */
