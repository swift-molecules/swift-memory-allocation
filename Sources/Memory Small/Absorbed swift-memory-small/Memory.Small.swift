#if MemorySmall
    public import Memory
    public import Memory_Inline

    extension Memory {

        public struct Small<let inlineCapacity: Int>: ~Copyable {
            @usableFromInline
            var _storage: _Representation

            @inlinable
            public init() {
                _storage = .inline(Memory.Inline<inlineCapacity>())
            }
        }
    }

    extension Memory.Small: Sendable {}
#endif

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
