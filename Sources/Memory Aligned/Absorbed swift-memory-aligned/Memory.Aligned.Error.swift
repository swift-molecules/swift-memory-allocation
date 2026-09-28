#if MemoryAligned
public import Byte
public import Growth

extension Memory.Aligned {

    public enum Error: Swift.Error, Sendable, Equatable {

        case allocationFailed

        case growth(Growth.Policy<Byte>.Error)
    }
}
#endif
