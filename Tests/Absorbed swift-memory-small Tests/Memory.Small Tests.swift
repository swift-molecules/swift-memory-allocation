#if MemorySmall
    import Cardinal
    import Memory
    import Tagged
    import Testing

    import Memory_Inline
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

            @Test func `an alignment the inline storage cannot guarantee spills to the heap`() {
                let small = Memory.Small<64>(
                    byteCount: Memory.Address.Count(UInt(16)),
                    alignment: .`4096`
                )
                let isSpilled = small.isSpilled
                let aligned = Memory.Alignment.`4096`.isAligned(small.base.bitPattern)

                #expect(isSpilled)
                #expect(aligned)
            }

            @Test func `inline storage satisfies the alignment it keeps inline`() {
                let small = Memory.Small<64>(
                    byteCount: Memory.Address.Count(UInt(16)),
                    alignment: Memory.Inline<64>._alignment
                )
                let isSpilled = small.isSpilled
                let aligned = Memory.Inline<64>._alignment.isAligned(small.base.bitPattern)

                #expect(!isSpilled)
                #expect(aligned)
            }
        }
    }
#endif
