#if MemorySmall
import Cardinal
import Memory
import Tagged
import Testing

@testable import Memory_Small

extension Memory {
    @Suite struct Tests {
        @Test func `default storage stays inline`() {
            let small = Memory.Small<8>()
            let isSpilled = small.isSpilled
            let capacity = small.capacity.underlying.rawValue

            #expect(!isSpilled)
            #expect(capacity == 8)
        }

        @Test func `inline budget boundary stays inline`() {
            let small = Memory.Small<8>(
                byteCount: Memory.Address.Count(UInt(8)),
                alignment: .`8`
            )
            let isSpilled = small.isSpilled
            let capacity = small.capacity.underlying.rawValue

            #expect(!isSpilled)
            #expect(capacity == 8)
        }

        @Test func `oversized storage spills to the Memory atom heap`() {
            let small = Memory.Small<8>(
                byteCount: Memory.Address.Count(UInt(32)),
                alignment: .`8`
            )
            let isSpilled = small.isSpilled
            let capacity = small.capacity.underlying.rawValue

            #expect(isSpilled)
            #expect(capacity == 32)
        }
    }
}
#endif
