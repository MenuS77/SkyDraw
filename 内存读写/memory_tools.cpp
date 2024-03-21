//
//  memory_tools.cpp
//  Dolphins
//
//  Created by 梓星 on 2023/12/26.
//
#include <mach/mach.h>
#include "memory_tools.h"


bool IsValidAddress(uintptr_t addr) {
    return addr > 0x100000000 && addr < 0x2000000000;
}

bool MemoryTools::readMemory(uintptr_t addr, size_t size, void *buffer) {
    if (!IsValidAddress(addr)) return false;
    vm_size_t readSize = 0;
    kern_return_t error = vm_read_overwrite(mach_task_self(), (vm_address_t)addr, size, (vm_address_t)buffer, &readSize);
    if (error != KERN_SUCCESS || readSize != size)
    {
        return false;
    }
    return true;
}

bool MemoryTools::writeMemory(uintptr_t address, size_t size, void *buffer) {
    if (!IsValidAddress(address)) return false;
    kern_return_t error = vm_write(mach_task_self(), (vm_address_t)address, (vm_offset_t)buffer, (mach_msg_type_number_t)size);
    if (error != KERN_SUCCESS)
    {
        return false;
    }
    return true;
}

uintptr_t MemoryTools::readPtr(uintptr_t addr) {
    uintptr_t value = 0;
    readMemory(addr, sizeof(uintptr_t), &value);
    return value;
}

int MemoryTools::readInt(uintptr_t addr) {
    int value = 0;
    readMemory(addr, sizeof(int), &value);
    return value;
}

float MemoryTools::readFloat(uintptr_t addr) {
    float value = 0;
    readMemory(addr, sizeof(float), &value);
    return value;
}

bool MemoryTools::readBool(uintptr_t addr) {
    bool value = 0;
    readMemory(addr, sizeof(bool), &value);
    return value;
}
