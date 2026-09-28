#if MemoryAligned
public import Byte
public import Growth
public import Index
public import Memory
import Ordinal

extension Memory.Aligned: Growth.Growable {}

extension Memory.Aligned {

    @inlinable
    public mutating func ensureCapacity(
        minimum: Index<Byte>.Count
    ) throws(Self.Error) {
        guard minimum > count else { return }

        try reallocate(
            to: try growthCapacity(minimum: minimum),
            preserving: true
        )
    }

    @inlinable
    public mutating func ensureCapacity(
        __unchecked: Void = (),
        minimum: Index<Byte>.Count
    ) {
        guard minimum > count else { return }

        do {
            try reallocate(
                to: try growthCapacity(minimum: minimum),
                preserving: true
            )
        } catch {
            preconditionFailure("Aligned region reallocation failed: \(error)")
        }
    }

    @inlinable
    public mutating func reserveDiscardingContents(
        minimum: Index<Byte>.Count
    ) throws(Self.Error) {
        guard minimum > count else { return }

        try reallocate(
            to: try growthCapacity(minimum: minimum),
            preserving: false
        )
    }

    @usableFromInline
    internal func growthCapacity(minimum: Index<Byte>.Count) throws(Self.Error) -> Index<Byte>.Count {
        do throws(Growth.Policy<Byte>.Error) {
            return Index<Byte>.Count.max(try growthPolicy.capacity(from: count), minimum)
        } catch {
            throw .growth(error)
        }
    }

    @usableFromInline
    internal mutating func reallocate(
        to newCapacity: Index<Byte>.Count,
        preserving: Bool
    ) throws(Self.Error) {
        var newRegion = try Memory.Aligned(
            byteCount: newCapacity,
            alignment: alignment,
            growthPolicy: growthPolicy
        )

        if preserving {
            let bytesToCopy = Int(
                bitPattern: Index<Byte>.Count.min(count, newCapacity).underlying.rawValue
            )
            unsafe newRegion.withUnsafeMutableBytes { dest in
                unsafe withUnsafeBytes { src in
                    unsafe dest.copyMemory(
                        from: UnsafeRawBufferPointer(rebasing: src.prefix(bytesToCopy))
                    )
                }
            }
        }

        self = newRegion
    }
}
#endif
