#if MemoryInline
public import Memory_Allocator_Protocol

extension Memory.Inline: Memory.Allocatable {}
#endif
