public import Cardinal
public import Memory
public import Memory_Allocator_Protocol
public import Memory_Pool
public import Ratio
public import Tagged

extension Memory.Allocator.Pool: Memory.Allocator.`Protocol` where Resource: ~Copyable {

    @inlinable
    public mutating func allocate(
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) throws(Error) -> Memory.Address {

        let slot = Memory.Pool.Count.one * _slotStride
        guard count <= slot else {
            throw .requestExceedsSlot(requested: count, slot: slot)
        }
        guard alignment.isAligned(_slotAlignment.magnitude(as: UInt.self)) else {
            throw .alignmentExceedsSlot(requested: alignment, slot: _slotAlignment)
        }

        let pointer = unsafe try allocate()
        return unsafe Memory.Address(pointer)
    }

    @inlinable
    public mutating func deallocate(
        _ address: Memory.Address,
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) {

        do throws(Error) {
            unsafe try deallocate(UnsafeMutableRawPointer(address))
        } catch {

        }
    }
}
