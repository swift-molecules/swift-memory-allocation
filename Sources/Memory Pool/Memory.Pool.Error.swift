import Cardinal
import Index
public import Memory
public import Tagged

extension Memory.Pool {
    public enum Error: Swift.Error, Equatable, Sendable {
        case exhausted(capacity: Count)

        case slotSizeTooSmall(requested: Memory.Address.Count, minimum: Memory.Address.Count)

        case requestExceedsSlot(requested: Memory.Address.Count, slot: Memory.Address.Count)

        case alignmentExceedsSlot(requested: Memory.Alignment, slot: Memory.Alignment)

        case invalidCapacity

        case foreignPointer

        case doubleFree
    }
}
