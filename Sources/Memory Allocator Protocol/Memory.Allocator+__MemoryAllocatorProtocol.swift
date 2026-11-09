public import Cardinal
public import Memory
public import Memory_Allocator
public import Tagged

extension Memory.Allocator: __MemoryAllocatorProtocol where Resource: ~Copyable {

    public typealias Error = Never

    @inlinable
    public mutating func allocate(
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) throws(Never) -> Memory.Address {
        precondition(
            count <= capacity,
            "passthrough allocator: requested byte count exceeds the adopted region's capacity"
        )
        precondition(
            alignment.isAligned(base.bitPattern),
            "passthrough allocator: the adopted region's base does not satisfy the requested alignment"
        )
        return base
    }

    @inlinable
    public mutating func deallocate(
        _ address: Memory.Address,
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) {

    }
}
