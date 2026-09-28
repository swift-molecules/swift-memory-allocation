#if MemoryAllocatorArena
public import Memory

extension Memory.Allocator.Arena where Resource: ~Copyable {

    public enum Error: Swift.Error, Equatable, Sendable {

        case insufficientCapacity(requested: Memory.Address.Count, available: Memory.Address.Count)
    }
}
#endif
