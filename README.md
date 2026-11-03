# swift-memory-allocation

Use this package to hand out addresses from a memory region you already own. Wrap the region in `Memory.Allocator<Resource>.Arena` when allocations are released all at once, or in `Memory.Allocator<Resource>.Pool` when equally sized blocks are freed one by one. Write generic code against `Memory.Allocating` or `Memory.Pooling`. `Memory.Allocator<Resource>` on its own is a passthrough that hands out the whole region. The backing region can be a `Memory.Heap`, a `Memory.Inline<n>` stored in the value itself, or a `Memory.Small<inlineCapacity>` that is stored inline until it is too large and then moves to the heap. Use `Memory.Aligned` instead when you need one owned, growable and aligned byte buffer rather than an allocator. `Memory.Region` and `Memory.Heap` themselves come from swift-memory.

## Laws

**Passthrough.** `Memory.Allocator<Resource>` returns the region's base for every request and does not track what it has handed out. A request larger than the region's capacity traps. Deallocation does nothing.

**Arena.** Each allocation advances a cursor.
- Alignment is measured against the actual address (region base plus cursor), not against the offset into the region. The padding counts towards `allocated`, even for a zero-byte request.
- A failed allocation leaves the cursor and every earlier allocation untouched. The available count it reports is the capacity left after padding. It is zero when the padding alone overruns the region, or when the address arithmetic would overflow the address space.
- Deallocation does nothing. Only `reset()` reclaims memory, and it reclaims all of it: it moves the cursor back to the start without clearing any bytes.

**Pool.**
- The slot stride is the slot size rounded up to the slot alignment. Capacity is the backing capacity divided by the stride, and the remainder is never used. Construction fails when the backing cannot hold one slot.
- A free slot stores the free-list link in its first bytes. That is why the slot size must be at least the size of `Index<Memory.Pool.Slot>`, and why a slot's contents are lost when it is deallocated.
- Freed slots are reused before any never-used slot, the most recently freed first. A slot's address is the base plus the index times the stride, and it does not change while the pool exists.
- Deallocating a slot that is not live fails as a double free. Deallocating a pointer that lies outside the pool or not on a slot boundary fails as a foreign pointer.
- Through `Memory.Allocating`, each served request takes one whole slot. A request is served when its count is at most the stride and the slot alignment is a multiple of its alignment. A rejected request uses up no slot.
- `reset()` forgets every allocation at once and leaves slot contents untouched.

**Small.** `Memory.Small<inlineCapacity>` chooses its storage once, when it is created. It stays inline when the requested byte count is at most `inlineCapacity`. Otherwise it uses a `Memory.Heap` of exactly the requested count. It never switches storage afterwards.

**Inline.** `Memory.Inline<n>` reports the address of its own storage as its base. That address changes when the value is moved, so addresses taken from an allocator over it stay valid only while that allocator stays where it is.

**Aligned.**
- A new `Memory.Aligned` has uninitialized bytes unless it is created with `zeroed`.
- When the requested minimum already fits in `count`, `ensureCapacity` and `reserveDiscardingContents` do nothing and do not consult the growth policy.
- Otherwise the new count is the larger of the minimum and the growth policy's proposal. The buffer is reallocated at a new address with the same alignment and growth policy. `ensureCapacity` copies the old bytes across and `reserveDiscardingContents` does not.
- If the growth policy fails, the buffer, its address and its bytes stay as they were.
