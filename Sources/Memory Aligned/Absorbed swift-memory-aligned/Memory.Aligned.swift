#if MemoryAligned
public import Byte
public import Growth
public import Index
public import Memory
import Ordinal
public import Span

extension Memory {

    @safe
    public struct Aligned: ~Copyable, @unsafe @unchecked Sendable {

        @usableFromInline
        var bytePointer: UnsafeMutablePointer<Byte>

        public internal(set) var count: Index<Byte>.Count

        public let alignment: Memory.Alignment

        public let growthPolicy: Growth.Policy<Byte>

        deinit {
            unsafe bytePointer.deallocate()
        }
    }
}

extension Memory.Aligned {

    public init(
        byteCount: Index<Byte>.Count,
        alignment: Memory.Alignment,
        growthPolicy: Growth.Policy<Byte> = .doubling
    ) throws(Self.Error) {
        let alignmentMagnitude: Int = alignment.magnitude()

        if byteCount == .zero {
            let raw = UnsafeMutableRawPointer.allocate(
                byteCount: 1,
                alignment: alignmentMagnitude
            )
            unsafe self.bytePointer = raw.bindMemory(to: Byte.self, capacity: 1)
            self.count = .zero
            self.alignment = alignment
            self.growthPolicy = growthPolicy
            return
        }

        let size = Int(bitPattern: byteCount)

        let raw = UnsafeMutableRawPointer.allocate(
            byteCount: size,
            alignment: alignmentMagnitude
        )
        unsafe self.bytePointer = raw.bindMemory(to: Byte.self, capacity: size)

        self.count = byteCount
        self.alignment = alignment
        self.growthPolicy = growthPolicy
    }

    public static func zeroed(
        byteCount: Index<Byte>.Count,
        alignment: Memory.Alignment,
        growthPolicy: Growth.Policy<Byte> = .doubling
    ) throws(Self.Error) -> Self {
        let buffer = try Self(
            byteCount: byteCount,
            alignment: alignment,
            growthPolicy: growthPolicy
        )
        unsafe buffer.bytePointer.initialize(repeating: Byte(bitPattern: 0), count: Int(bitPattern: byteCount))
        return buffer
    }
}

extension Memory.Aligned {

    @unsafe
    @inlinable
    public func withUnsafeBytes<R, E: Swift.Error>(
        _ body: (UnsafeRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        try unsafe body(UnsafeRawBufferPointer(start: UnsafeRawPointer(bytePointer), count: count))
    }

    @unsafe
    @inlinable
    public mutating func withUnsafeMutableBytes<R, E: Swift.Error>(
        _ body: (UnsafeMutableRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        try unsafe body(
            UnsafeMutableRawBufferPointer(start: UnsafeMutableRawPointer(bytePointer), count: count)
        )
    }
}

extension Memory.Aligned {

    @inlinable
    public func isAligned(to boundary: Memory.Alignment) -> Bool {
        unsafe boundary.isAligned(UnsafeRawPointer(bytePointer))
    }
}

extension Memory.Aligned {

    @inlinable
    public var bytes: Swift.Span<Byte> {
        @_lifetime(borrow self)
        borrowing get {
            unsafe Swift.Span(_unsafeStart: bytePointer, count: count)
        }
    }

    @inlinable
    public var mutableBytes: Swift.MutableSpan<Byte> {
        @_lifetime(&self)
        mutating get {
            unsafe Swift.MutableSpan(_unsafeStart: bytePointer, count: count)
        }
    }
}

extension Memory.Aligned {

    @inlinable
    public func withRawSpan<R, E: Swift.Error>(
        _ body: (RawSpan) throws(E) -> R
    ) throws(E) -> R {
        let span = unsafe RawSpan(_unsafeStart: UnsafeRawPointer(bytePointer), byteCount: count)
        return try body(span)
    }

    @inlinable
    public mutating func withMutableRawSpan<R, E: Swift.Error>(
        _ body: (inout MutableRawSpan) throws(E) -> R
    ) throws(E) -> R {
        var span = unsafe MutableRawSpan(
            _unsafeStart: UnsafeMutableRawPointer(bytePointer),
            byteCount: count
        )
        return try body(&span)
    }
}

extension Memory.Aligned {

    public enum Space {}

    public typealias Scalar = Int
}

extension Memory.Aligned: Span.`Protocol` {

    public typealias Element = Byte

    @inlinable
    public var span: Swift.Span<Byte> {
        @_lifetime(borrow self)
        borrowing get {
            bytes
        }
    }

    @inlinable
    public var mutableSpan: Swift.MutableSpan<Byte> {
        @_lifetime(&self)
        mutating get {
            mutableBytes
        }
    }

    @unsafe
    @inlinable
    public func withUnsafeBufferPointer<R, E: Swift.Error>(
        _ body: (UnsafeBufferPointer<Byte>) throws(E) -> R
    ) throws(E) -> R {
        try unsafe body(UnsafeBufferPointer(start: bytePointer, count: count))
    }

    @unsafe
    @inlinable
    public mutating func withUnsafeMutableBufferPointer<R, E: Swift.Error>(
        _ body: (UnsafeMutableBufferPointer<Byte>) throws(E) -> R
    ) throws(E) -> R {
        try unsafe body(UnsafeMutableBufferPointer(start: bytePointer, count: count))
    }
}
#endif
