#if MemoryAllocatorArena
public import Memory_Allocator_Protocol

extension Memory.Allocator.Arena: Memory.Allocator.`Protocol` where Resource: ~Copyable {

    @inlinable
    public mutating func allocate(
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) throws(Self.Error) -> Memory.Address {
        let capacity = self.capacity
        let start = self.start
        let (currentAddress, addressOverflow) = start.bitPattern.addingReportingOverflow(
            cursor.underlying.rawValue
        )
        guard !addressOverflow else {
            throw .insufficientCapacity(requested: count, available: .zero)
        }

        let (alignedAddress, roundingOverflow) = alignment.alignUpReportingOverflow(currentAddress)
        guard !roundingOverflow,
            let offset = Int(exactly: alignedAddress - start.bitPattern)
        else {
            throw .insufficientCapacity(requested: count, available: .zero)
        }

        let alignedCursor = Memory.Address.Count(_unchecked: Cardinal(UInt(offset)))

        guard let endCursor = try? alignedCursor.add.exact(count),
            endCursor <= capacity
        else {
            throw .insufficientCapacity(
                requested: count,

                available: (try? capacity.subtract.exact(alignedCursor)) ?? .zero
            )
        }

        let (_, extentOverflow) = start.bitPattern.addingReportingOverflow(
            endCursor.underlying.rawValue
        )
        guard !extentOverflow else {
            throw .insufficientCapacity(requested: count, available: .zero)
        }

        cursor = endCursor

        return unsafe Memory.Address(
            start.mutablePointer.advanced(
                by: offset
            )
        )
    }

    @inlinable
    public mutating func deallocate(
        _ address: Memory.Address,
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) {

    }
}
#endif
