#if MemorySmall
public import Memory
public import Memory_Inline

extension Memory.Small: Memory.Region {

    @inlinable
    public var base: Memory.Address {
        switch _storage {
        case .inline(let arm): arm.base
        case .heap(let arm): arm.base
        }
    }

    @inlinable
    public var capacity: Memory.Address.Count {
        switch _storage {
        case .inline(let arm): arm.capacity
        case .heap(let arm): arm.capacity
        }
    }
}
#endif
