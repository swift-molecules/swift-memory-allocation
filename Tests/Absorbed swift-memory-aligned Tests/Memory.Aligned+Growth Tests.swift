#if MemoryAligned
import Growth
import Index
import Memory_Aligned_Test_Support
import Testing

@Suite
struct `Memory aligned growth honors checked capacity policies` {
    @Test
    func `creates with initial capacity and grows on demand`() throws {
        var region = try Memory.Aligned(byteCount: 8, alignment: try Memory.Alignment(8))
        #expect(region.count >= Index<Byte>.Count(8))
        try region.ensureCapacity(minimum: 64)
        #expect(region.count >= Index<Byte>.Count(64))
    }

    @Test
    func `round-trips bytes through mutable access after growth`() throws {
        var region = try Memory.Aligned(byteCount: 4, alignment: try Memory.Alignment(8))
        try region.ensureCapacity(minimum: 16)
        unsafe region.withUnsafeMutableBytes { bytes in
            unsafe bytes[15] = 0xAB
        }
        unsafe region.withUnsafeBytes { bytes in
            #expect(unsafe bytes[15] == 0xAB)
        }
    }

    @Test
    func `preserves existing bytes across growth`() throws {
        var region = try Memory.Aligned.zeroed(byteCount: 4, alignment: try Memory.Alignment(8))
        unsafe region.withUnsafeMutableBytes { bytes in
            for i in 0..<4 { unsafe bytes[i] = UInt8(i + 1) }
        }
        try region.ensureCapacity(minimum: 32)
        #expect(region.count >= Index<Byte>.Count(32))
        unsafe region.withUnsafeBytes { bytes in
            for i in 0..<4 { #expect(unsafe bytes[i] == UInt8(i + 1)) }
        }
    }

    @Test
    func `discarding reserve grows to the requested minimum`() throws {
        var region = try Memory.Aligned(byteCount: 8, alignment: try Memory.Alignment(8))
        try region.reserveDiscardingContents(minimum: 128)
        #expect(region.count >= Index<Byte>.Count(128))
    }

    @Test(arguments: [false, true])
    func `inexact growth preserves the existing allocation and bytes`(_ discarding: Bool) throws {
        let policy = try Growth.Policy<Byte>.factor(.init(numerator: 3, denominator: 2))
        var region = try Memory.Aligned(
            byteCount: 3,
            alignment: try Memory.Alignment(8),
            growthPolicy: policy
        )
        unsafe region.withUnsafeMutableBytes { bytes in
            for i in 0..<3 { unsafe bytes[i] = UInt8(i + 1) }
        }
        let address = unsafe region.withUnsafeBytes { bytes in
            UInt(bitPattern: bytes.baseAddress)
        }

        do throws(Memory.Aligned.Error) {
            if discarding {
                try region.reserveDiscardingContents(minimum: 4)
            } else {
                try region.ensureCapacity(minimum: 4)
            }
            Issue.record("Inexact growth unexpectedly succeeded")
        } catch {
            #expect(error == .growth(.scaling(.inexact)))
        }

        #expect(region.count == 3)
        unsafe region.withUnsafeBytes { bytes in
            #expect(UInt(bitPattern: bytes.baseAddress) == address)
            for i in 0..<3 { #expect(unsafe bytes[i] == UInt8(i + 1)) }
        }
    }

    @Test(arguments: [false, true])
    func `shrinking custom growth preserves the existing allocation and bytes`(_ discarding: Bool) throws {
        var region = try Memory.Aligned.zeroed(
            byteCount: 4,
            alignment: try Memory.Alignment(8),
            growthPolicy: .custom { _ in .one }
        )
        unsafe region.withUnsafeMutableBytes { bytes in
            for i in 0..<4 { unsafe bytes[i] = UInt8(i + 5) }
        }
        let address = unsafe region.withUnsafeBytes { bytes in
            UInt(bitPattern: bytes.baseAddress)
        }

        do throws(Memory.Aligned.Error) {
            if discarding {
                try region.reserveDiscardingContents(minimum: 5)
            } else {
                try region.ensureCapacity(minimum: 5)
            }
            Issue.record("Shrinking growth unexpectedly succeeded")
        } catch {
            #expect(error == .growth(.wouldShrink(current: 4, proposed: 1)))
        }

        #expect(region.count == 4)
        unsafe region.withUnsafeBytes { bytes in
            #expect(UInt(bitPattern: bytes.baseAddress) == address)
            for i in 0..<4 { #expect(unsafe bytes[i] == UInt8(i + 5)) }
        }
    }

    @Test(arguments: [false, true])
    func `satisfied reservations do not evaluate a failing growth policy`(_ discarding: Bool) throws {
        let policy = Growth.Policy<Byte>.custom { _ throws(Growth.Policy<Byte>.Error) in
            throw .overflow
        }
        var region = try Memory.Aligned.zeroed(
            byteCount: 4,
            alignment: try Memory.Alignment(8),
            growthPolicy: policy
        )
        let address = unsafe region.withUnsafeBytes { bytes in
            UInt(bitPattern: bytes.baseAddress)
        }

        for minimum: Index<Byte>.Count in [0, 3, 4] {
            if discarding {
                try region.reserveDiscardingContents(minimum: minimum)
            } else {
                try region.ensureCapacity(minimum: minimum)
            }
        }

        #expect(region.count == 4)
        unsafe region.withUnsafeBytes { bytes in
            #expect(UInt(bitPattern: bytes.baseAddress) == address)
            for i in 0..<4 { #expect(unsafe bytes[i] == 0) }
        }
    }
}
#endif
