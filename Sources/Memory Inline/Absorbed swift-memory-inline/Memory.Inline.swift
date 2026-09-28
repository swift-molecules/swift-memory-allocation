#if MemoryInline
public import Memory

extension Memory {

    public struct Inline<let n: Int>: ~Copyable {

        @usableFromInline
        package var _deinitWorkaround: AnyObject? = nil

        @_rawLayout(likeArrayOf: UInt8, count: n)
        @usableFromInline
        package struct _Raw: ~Copyable {
            @inlinable package init() {}
        }

        @usableFromInline
        package var _storage: _Raw

        @inlinable
        public init() {
            self._deinitWorkaround = nil
            self._storage = _Raw()
        }
    }
}

extension Memory.Inline: @unchecked Sendable {}
#endif
