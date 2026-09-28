#if MemoryAligned
public import Index
import Ordinal

extension Memory.Aligned {

    @inlinable
    public subscript(range: Swift.Range<Int>) -> Swift.Span<Byte> {
        @_lifetime(borrow self)
        borrowing get {
            bytes.extracting(range)
        }
    }

    @inlinable
    public subscript(range: PartialRangeFrom<Int>) -> Swift.Span<Byte> {
        @_lifetime(borrow self)
        borrowing get {
            bytes.extracting(range.lowerBound..<Int(bitPattern: count))
        }
    }

    @inlinable
    public subscript(range: PartialRangeUpTo<Int>) -> Swift.Span<Byte> {
        @_lifetime(borrow self)
        borrowing get {
            bytes.extracting(0..<range.upperBound)
        }
    }

    @inlinable
    public subscript(range: PartialRangeThrough<Int>) -> Swift.Span<Byte> {
        @_lifetime(borrow self)
        borrowing get {
            bytes.extracting(0...range.upperBound)
        }
    }
}
#endif
