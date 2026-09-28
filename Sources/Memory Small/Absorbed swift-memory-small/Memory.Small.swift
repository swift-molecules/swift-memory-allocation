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
