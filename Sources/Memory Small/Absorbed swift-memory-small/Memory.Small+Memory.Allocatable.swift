#if MemorySmall
    public import Cardinal
    public import Memory
    public import Memory_Allocator_Protocol
    public import Memory_Inline
    public import Tagged

    extension Memory.Small: Memory.Growable {

        @inlinable
        public init(byteCount: Memory.Address.Count, alignment: Memory.Alignment) {
            let inlineBudget = Memory.Address.Count(UInt(inlineCapacity))
            let fitsInline = byteCount.underlying.rawValue <= inlineBudget.underlying.rawValue
            let alignedInline = alignment.shift <= Memory.Inline<inlineCapacity>._alignment.shift
            if fitsInline && alignedInline {
                self.init(_storage: .inline(Memory.Inline<inlineCapacity>()))
            } else {
                self.init(_storage: .heap(Memory.Heap(byteCount: byteCount, alignment: alignment)))
            }
        }
    }

    extension Memory.Small: Memory.Allocatable {}
#endif
