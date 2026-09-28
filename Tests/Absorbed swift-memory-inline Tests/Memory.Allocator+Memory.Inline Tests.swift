#if MemoryInline
import Cardinal
import Memory_Allocator_Arena
import Memory_Allocator_Pool
import Memory_Inline
import Tagged
import Testing

@Suite(.serialized)
struct `Memory.Allocator Inline Backed Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Memory.Allocator Inline Backed Tests`.Integration {
    @Test func `arena over inline bumps and tears down`() throws {
        do {
            var arena = Memory.Allocator<Memory.Inline<1024>>.Arena(Memory.Inline<1024>())
            let cap = arena.capacity
            #expect(cap.underlying.rawValue == 1024)
            _ = try arena.allocate(count: Memory.Address.Count(UInt(64)), alignment: .`8`)
            let alloc = arena.allocated
            #expect(alloc.underlying.rawValue >= 64)
        }

    }

    @Test func `pool over inline carves slots allocates and detects double free`() throws {
        do {
            var pool = try Memory.Allocator<Memory.Inline<512>>.Pool(
                carving: Memory.Inline<512>(),
                slotSize: Memory.Address.Count(UInt(16)),
                slotAlignment: .`8`
            )

            let cap = pool.capacity
            #expect(cap.underlying.rawValue == 32)

            let s0 = try pool.allocateSlot()
            let s1 = try pool.allocateSlot()
            unsafe pool.pointer(at: s0).storeBytes(of: 0xABCD, as: Int.self)
            let read = unsafe pool.pointer(at: s0).load(as: Int.self)
            #expect(read == 0xABCD)

            try pool.deallocate(at: s1)
            var doubleFreed = false
            do { try pool.deallocate(at: s1) } catch {
                if case .doubleFree = error { doubleFreed = true }
            }
            #expect(doubleFreed)
        }
    }
}
#endif
