#if MemoryAllocatorArena
import Memory
import Testing

@testable import Memory_Allocator_Arena

@Suite
struct `Arena allocations preserve absolute alignment and capacity` {
    private struct OwnedSlice: Memory.Region, ~Copyable {
        private let heap: Memory.Heap
        private let offset: Int
        private let length: Int

        init(offset: Int, length: Int) throws {
            self.offset = offset
            self.length = length
            self.heap = Memory.Heap(
                byteCount: Memory.Address.Count(_unchecked: Cardinal(UInt(offset + length))),
                alignment: try Memory.Alignment(64)
            )
        }

        var base: Memory.Address {
            Memory.Address(_unchecked: Ordinal(heap.base.bitPattern + UInt(offset)))
        }

        var capacity: Memory.Address.Count {
            Memory.Address.Count(_unchecked: Cardinal(UInt(length)))
        }
    }

    private struct AddressMetadata: Memory.Region {
        let base: Memory.Address
        let capacity: Memory.Address.Count
    }

    @Test(arguments: [0, 1, 3, 7, 15], [1, 2, 4, 8, 16])
    func `absolute alignment includes padding inside an owned region`(
        offset: Int, alignmentMagnitude: Int
    ) throws {
        let region = try OwnedSlice(offset: offset, length: 64)
        let start = region.base.bitPattern
        let alignment = try Memory.Alignment(alignmentMagnitude)
        var arena = Memory.Allocator<OwnedSlice>.Arena(region)

        let result = try arena.allocate(count: 3, alignment: alignment)
        let remainder = start % UInt(alignmentMagnitude)
        let padding = remainder == 0 ? 0 : UInt(alignmentMagnitude) - remainder

        #expect(result.bitPattern == start + padding)
        #expect(result.bitPattern % UInt(alignmentMagnitude) == 0)
        #expect(arena.allocated.underlying.rawValue == padding + 3)
        #expect(arena.remaining.underlying.rawValue == 64 - padding - 3)
        unsafe result.mutablePointer.initializeMemory(as: UInt8.self, repeating: 0xA5, count: 3)
        #expect(unsafe result.pointer.load(as: UInt8.self) == 0xA5)
        #expect(unsafe result.pointer.load(fromByteOffset: 2, as: UInt8.self) == 0xA5)
    }

    @Test
    func `padding that exceeds the region fails without advancing the cursor`() throws {
        var arena = Memory.Allocator<OwnedSlice>.Arena(try OwnedSlice(offset: 1, length: 6))
        #expect(throws: Memory.Allocator<OwnedSlice>.Arena.Error.insufficientCapacity(
            requested: 1, available: 0
        )) {
            try arena.allocate(count: 1, alignment: .`8`)
        }
        #expect(arena.allocated == .zero)
        #expect(arena.remaining == 6)
    }

    @Test
    func `failed allocation reports capacity after padding and preserves prior allocations`() throws {
        let region = try OwnedSlice(offset: 1, length: 20)
        let start = region.base.bitPattern
        var arena = Memory.Allocator<OwnedSlice>.Arena(region)
        let first = try arena.allocate(count: 3, alignment: .byte)
        unsafe first.mutablePointer.storeBytes(of: UInt8(73), as: UInt8.self)

        #expect(throws: Memory.Allocator<OwnedSlice>.Arena.Error.insufficientCapacity(
            requested: 14, available: 13
        )) {
            try arena.allocate(count: 14, alignment: .`8`)
        }
        #expect(arena.allocated == 3)
        #expect(unsafe first.pointer.load(as: UInt8.self) == 73)

        let next = try arena.allocate(count: 2, alignment: .`2`)
        #expect(next.bitPattern == start + 3)
        #expect(arena.allocated == 5)
    }

    @Test
    func `zero byte allocation still accounts for requested alignment padding`() throws {
        let region = try OwnedSlice(offset: 1, length: 8)
        let start = region.base.bitPattern
        var arena = Memory.Allocator<OwnedSlice>.Arena(region)
        let result = try arena.allocate(count: 0, alignment: .`8`)
        #expect(result.bitPattern == start + 7)
        #expect(arena.allocated == 7)
        #expect(arena.remaining == 1)
    }

    @Test
    func `full width requests fail before pointer work or cursor mutation`() throws {
        var arena = Memory.Allocator<OwnedSlice>.Arena(try OwnedSlice(offset: 0, length: 32))
        let request = Memory.Address.Count(_unchecked: Cardinal(UInt.max))
        #expect(throws: Memory.Allocator<OwnedSlice>.Arena.Error.insufficientCapacity(
            requested: request, available: 32
        )) {
            try arena.allocate(count: request, alignment: .byte)
        }
        #expect(arena.allocated == .zero)
    }

    @Test
    func `unrepresentable rounded addresses fail before constructing a pointer`() {
        let region = AddressMetadata(
            base: Memory.Address(_unchecked: Ordinal(UInt.max - 3)), capacity: 4
        )
        var arena = Memory.Allocator<AddressMetadata>.Arena(region)
        #expect(throws: Memory.Allocator<AddressMetadata>.Arena.Error.insufficientCapacity(
            requested: 1, available: 0
        )) {
            try arena.allocate(count: 1, alignment: .`8`)
        }
        #expect(arena.allocated == .zero)
    }

    @Test
    func `overflow when adding a saved cursor to the base leaves that cursor unchanged`() {
        let region = AddressMetadata(
            base: Memory.Address(_unchecked: Ordinal(UInt.max - 3)), capacity: 16
        )
        var arena = Memory.Allocator<AddressMetadata>.Arena(region)
        arena.cursor = 8
        #expect(throws: Memory.Allocator<AddressMetadata>.Arena.Error.insufficientCapacity(
            requested: 1, available: 0
        )) {
            try arena.allocate(count: 1, alignment: .byte)
        }
        #expect(arena.allocated == 8)
    }

    @Test
    func `an allocation extent that wraps the address space fails before pointer construction`() {
        let region = AddressMetadata(
            base: Memory.Address(_unchecked: Ordinal(UInt.max - 7)), capacity: 16
        )
        var arena = Memory.Allocator<AddressMetadata>.Arena(region)
        #expect(throws: Memory.Allocator<AddressMetadata>.Arena.Error.insufficientCapacity(
            requested: 8, available: 0
        )) {
            try arena.allocate(count: 8, alignment: .byte)
        }
        #expect(arena.allocated == .zero)
    }

    @Test
    func `offsets beyond the signed pointer range fail without narrowing`() {
        let region = AddressMetadata(
            base: Memory.Address(_unchecked: Ordinal(1)),
            capacity: Memory.Address.Count(_unchecked: Cardinal(UInt.max))
        )
        var arena = Memory.Allocator<AddressMetadata>.Arena(region)
        let offset = Memory.Address.Count(_unchecked: Cardinal(UInt(Int.max) + 1))
        arena.cursor = offset
        #expect(throws: Memory.Allocator<AddressMetadata>.Arena.Error.insufficientCapacity(
            requested: 0, available: 0
        )) {
            try arena.allocate(count: 0, alignment: .byte)
        }
        #expect(arena.allocated == offset)
    }
}
#endif
