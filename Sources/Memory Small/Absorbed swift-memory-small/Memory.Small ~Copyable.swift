#if MemorySmall
public import Memory

extension Memory.Small {

    @inlinable
    package init(_storage: consuming _Representation) {
        self._storage = _storage
    }

    @inlinable
    public var isSpilled: Bool {
        switch _storage {
        case .inline: false
        case .heap: true
        }
    }
}
#endif
