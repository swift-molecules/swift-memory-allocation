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

    extension Memory.Inline {

        // `_storage` is laid out like a byte array, but it follows the pointer-sized
        // `_deinitWorkaround` field, so it sits at a pointer-aligned offset inside a
        // pointer-aligned value: every `base` is aligned to a pointer.
        @inlinable
        package static var _alignment: Memory.Alignment {
            do {
                return try Memory.Alignment(MemoryLayout<AnyObject?>.alignment)
            } catch {
                preconditionFailure("A type's alignment is a power of two")
            }
        }
    }

    extension Memory.Inline: @unchecked Sendable {}
#endif
