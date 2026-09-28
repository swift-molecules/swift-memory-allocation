#if MemorySmall
public import Memory
public import Memory_Inline

extension Memory.Small {

    @frozen
    @usableFromInline
    package enum _Representation: ~Copyable {

        case inline(Memory.Inline<inlineCapacity>)

        case heap(Memory.Heap)
    }
}
#endif
