#if MemoryInline
public import Cardinal
public import Memory

extension Memory.Inline: Memory.Region {

    @inlinable
    public var capacity: Memory.Address.Count {
        Memory.Address.Count(UInt(n))
    }

    @inlinable
    public var base: Memory.Address {

        withUnsafePointer(to: _storage) { pointer in
            unsafe Memory.Address(UnsafeMutableRawPointer(mutating: pointer))
        }
    }
}
#endif
