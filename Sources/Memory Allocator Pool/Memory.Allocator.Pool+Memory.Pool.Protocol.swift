public import Memory
import Memory_Allocator
public import Memory_Pool

extension Memory.Allocator.Pool: Memory.Pool.`Protocol` where Resource: ~Copyable {}
