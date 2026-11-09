import Cardinal
import Memory
import Memory_Allocator_Protocol
import Testing

@Suite(.serialized)
struct `Memory.Allocatable Surface Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @safe
    struct Region: Memory.Growable, Memory.Allocatable, ~Copyable {
        let pointer: UnsafeMutableRawPointer

        let byteCount: Int

        init(byteCount: Memory.Address.Count, alignment: Memory.Alignment) {
            let count = Int(bitPattern: byteCount)
            self.byteCount = count
            unsafe self.pointer = UnsafeMutableRawPointer.allocate(
                byteCount: count,
                alignment: alignment.magnitude(as: Int.self)
            )
        }

        var base: Memory.Address { unsafe Memory.Address(pointer) }
        var capacity: Memory.Address.Count { Memory.Address.Count(UInt(byteCount)) }

        deinit { unsafe pointer.deallocate() }
    }
}

extension `Memory.Allocatable Surface Tests`.Unit {
    @Test func `growable constructs to the requested byte count`() {
        let region = `Memory.Allocatable Surface Tests`.Region(
            byteCount: Memory.Address.Count(UInt(256)),
            alignment: .`8`
        )
        #expect(region.capacity == Memory.Address.Count(UInt(256)))
    }

    @Test func `adopt role vends a passthrough over the whole region`() {
        let region = `Memory.Allocatable Surface Tests`.Region(
            byteCount: Memory.Address.Count(UInt(128)),
            alignment: .`8`
        )
        let allocator = region.makeAllocator()

        #expect(allocator.capacity == Memory.Address.Count(UInt(128)))
        #expect(allocator.base == allocator.base)
    }
}

extension `Memory.Allocatable Surface Tests` {
    @safe
    struct Offset: Memory.Allocatable, ~Copyable {
        let pointer: UnsafeMutableRawPointer

        init() {
            unsafe self.pointer = UnsafeMutableRawPointer.allocate(byteCount: 64, alignment: 16)
        }

        var base: Memory.Address { unsafe Memory.Address(pointer.advanced(by: 1)) }
        var capacity: Memory.Address.Count { Memory.Address.Count(UInt(63)) }

        deinit { unsafe pointer.deallocate() }
    }
}

extension `Memory.Allocatable Surface Tests`.`Edge Case` {
    @Test func `passthrough serves an alignment the base satisfies`() {
        var allocator = `Memory.Allocatable Surface Tests`.Region(
            byteCount: Memory.Address.Count(UInt(64)),
            alignment: .`16`
        ).makeAllocator()
        let address = allocator.allocate(count: Memory.Address.Count(UInt(32)), alignment: .`16`)
        #expect(Memory.Alignment.`16`.isAligned(address.bitPattern))
    }

    @Test func `passthrough traps when the base does not satisfy the requested alignment`() async {
        await #expect(processExitsWith: .failure) {
            var allocator = `Memory.Allocatable Surface Tests`.Offset().makeAllocator()
            _ = allocator.allocate(count: Memory.Address.Count(UInt(8)), alignment: .`8`)
        }
    }
}
