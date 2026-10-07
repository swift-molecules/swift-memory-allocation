import Memory
import Memory_Allocator_Pool
import Memory_Allocator_Protocol
import Memory_Pool
import Tagged
import Testing

extension Memory.Pool {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension Memory.Pool.Test {

    static func pool() throws(Memory.Pool.Error) -> Memory.Allocator<Memory.Heap>.Pool {
        try Memory.Allocator<Memory.Heap>.Pool(
            carving: Memory.Heap(byteCount: Memory.Address.Count(UInt(256)), alignment: .`16`),
            slotSize: Memory.Address.Count(UInt(24)),
            slotAlignment: .`8`
        )
    }
}

extension Memory.Pool.Test.Unit {

    @Test func `a request smaller than the slot is served`() throws {
        var pool = try Memory.Pool.Test.pool()
        let address = try pool.allocate(count: Memory.Address.Count(UInt(16)), alignment: .`8`)
        #expect(pool.allocated == .one)
        #expect(Memory.Alignment.`8`.isAligned(address.mutablePointer))
    }

    @Test func `a request of exactly the slot size is served`() throws {
        var pool = try Memory.Pool.Test.pool()
        _ = try pool.allocate(count: Memory.Address.Count(UInt(24)), alignment: .`8`)
        #expect(pool.allocated == .one)
    }

    @Test func `a smaller alignment than the slot alignment is served`() throws {
        var pool = try Memory.Pool.Test.pool()
        let address = try pool.allocate(count: Memory.Address.Count(UInt(8)), alignment: .`4`)
        #expect(pool.allocated == .one)
        #expect(Memory.Alignment.`4`.isAligned(address.mutablePointer))
    }

    @Test func `served requests stay distinct and return to the pool`() throws {
        var pool = try Memory.Pool.Test.pool()
        let first = try pool.allocate(count: Memory.Address.Count(UInt(24)), alignment: .`8`)
        let second = try pool.allocate(count: Memory.Address.Count(UInt(1)), alignment: .`1`)
        #expect(first != second)
        pool.deallocate(first, count: Memory.Address.Count(UInt(24)), alignment: .`8`)
        pool.deallocate(second, count: Memory.Address.Count(UInt(1)), alignment: .`1`)
        #expect(pool.allocated == .zero)
    }
}

extension Memory.Pool.Test.`Edge Case` {

    @Test func `a request larger than the slot is rejected without consuming a slot`() throws {
        var pool = try Memory.Pool.Test.pool()
        let available = pool.available
        let expected = Memory.Pool.Error.requestExceedsSlot(
            requested: Memory.Address.Count(UInt(25)),
            slot: Memory.Address.Count(UInt(24))
        )
        #expect(throws: expected) {
            _ = try pool.allocate(count: Memory.Address.Count(UInt(25)), alignment: .`8`)
        }
        #expect(pool.allocated == .zero)
        #expect(pool.available == available)
    }

    @Test func `a larger alignment than the slot alignment is rejected without consuming a slot`() throws {
        var pool = try Memory.Pool.Test.pool()
        let available = pool.available
        let expected = Memory.Pool.Error.alignmentExceedsSlot(requested: .`16`, slot: .`8`)
        #expect(throws: expected) {
            _ = try pool.allocate(count: Memory.Address.Count(UInt(8)), alignment: .`16`)
        }
        #expect(pool.allocated == .zero)
        #expect(pool.available == available)
    }

    @Test func `a rejected request leaves the pool able to serve a valid one`() throws {
        var pool = try Memory.Pool.Test.pool()
        let expected = Memory.Pool.Error.requestExceedsSlot(
            requested: Memory.Address.Count(UInt(64)),
            slot: Memory.Address.Count(UInt(24))
        )
        #expect(throws: expected) {
            _ = try pool.allocate(count: Memory.Address.Count(UInt(64)), alignment: .`8`)
        }
        _ = try pool.allocate(count: Memory.Address.Count(UInt(24)), alignment: .`8`)
        #expect(pool.allocated == .one)
    }
}
