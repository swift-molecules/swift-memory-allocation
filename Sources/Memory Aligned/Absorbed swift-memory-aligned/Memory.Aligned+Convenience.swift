#if MemoryAligned
public import Index
import Ordinal

extension Memory.Aligned {

    @inlinable
    public subscript(index: Int) -> Byte {
        get {
            precondition(index >= 0 && index < Int(bitPattern: count), "index out of bounds")
            return unsafe bytePointer[index]
        }
        set {
            precondition(index >= 0 && index < Int(bitPattern: count), "index out of bounds")
            unsafe bytePointer[index] = newValue
        }
    }
}

extension Memory.Aligned {

    @inlinable
    public mutating func copy(
        from source: Swift.Span<Byte>,
        at offset: Int = 0
    ) {
        precondition(offset >= 0 && offset + source.count <= Int(bitPattern: count))
        unsafe withUnsafeMutableBufferPointer { dest in
            source.withUnsafeBufferPointer { src in
                guard let destBase = dest.baseAddress else { return }
                guard let srcBase = src.baseAddress else { return }
                unsafe destBase.advanced(by: offset)
                    .update(from: srcBase, count: src.count)
            }
        }
    }

    @inlinable
    public mutating func copy(
        from source: UnsafeRawBufferPointer,
        at offset: Int = 0
    ) {
        precondition(offset >= 0 && offset + source.count <= Int(bitPattern: count))
        unsafe withUnsafeMutableBytes { dest in
            guard let destBase = dest.baseAddress else { return }
            guard let srcBase = source.baseAddress else { return }
            unsafe destBase.advanced(by: offset)
                .copyMemory(from: srcBase, byteCount: source.count)
        }
    }
}

extension Memory.Aligned {

    @inlinable
    public mutating func zero() {
        unsafe withUnsafeMutableBytes { buffer in
            _ = unsafe buffer.baseAddress?.initializeMemory(
                as: Byte.self,
                repeating: Byte(bitPattern: 0),
                count: buffer.count
            )
        }
    }

    @inlinable
    public mutating func zero(range: Swift.Range<Int>) {
        precondition(range.lowerBound >= 0 && range.upperBound <= Int(bitPattern: count))
        unsafe withUnsafeMutableBytes { buffer in
            guard let base = buffer.baseAddress else { return }
            let start = unsafe base.advanced(by: range.lowerBound)
            unsafe start.initializeMemory(as: Byte.self, repeating: Byte(bitPattern: 0), count: range.count)
        }
    }

    @inlinable
    public mutating func zero(from offset: Int) {
        let size = Int(bitPattern: count)
        precondition(offset >= 0 && offset <= size)
        zero(range: offset..<size)
    }
}
#endif
