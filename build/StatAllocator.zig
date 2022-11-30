const std = @import("std");
const Allocator = std.mem.Allocator;

const StatAllocator = @This();

backing_allocator: Allocator,
current_bytes: usize = 0,
max_bytes: usize = 0,
total_bytes: usize = 0,
allocs: usize = 0,
resizes: usize = 0,
pub fn init(backing_allocator: Allocator) StatAllocator {
    return StatAllocator{
        .backing_allocator = backing_allocator,
    };
}
pub fn allocator(self: *StatAllocator) Allocator {
    return Allocator{
        .ptr = self,
        .vtable = &.{
            .alloc = alloc,
            .resize = resize,
            .free = free,
        },
    };
}
fn alloc(ctx: *anyopaque, byte_count: usize, alignment: u8, return_address: usize) ?[*]u8 {
    const self = @ptrCast(*StatAllocator, @alignCast(@alignOf(StatAllocator), ctx));
    if (self.backing_allocator.rawAlloc(byte_count, alignment, return_address)) |ret| {
        self.allocs += 1;
        self.total_bytes += byte_count;
        self.current_bytes += byte_count;
        self.max_bytes = @max(self.max_bytes, self.current_bytes);
        return ret;
    } else return null;
}
pub fn resize(ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) bool {
    const self = @ptrCast(*StatAllocator, @alignCast(@alignOf(StatAllocator), ctx));
    if (self.backing_allocator.rawResize(buf, buf_align, new_len, ret_addr)) {
        self.resizes += 1;
        switch (std.math.order(new_len, buf.len)) {
            .lt => self.current_bytes -= (buf.len - new_len),
            .gt => self.current_bytes += (new_len - buf.len),
            .eq => {},
        }
        self.max_bytes = @max(self.max_bytes, self.current_bytes);
        return true;
    } else return false;
}
pub fn free(ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) void {
    const self = @ptrCast(*StatAllocator, @alignCast(@alignOf(StatAllocator), ctx));
    self.current_bytes -= buf.len;
    self.max_bytes = @max(self.max_bytes, self.current_bytes);
    return self.backing_allocator.rawFree(buf, buf_align, ret_addr);
}
