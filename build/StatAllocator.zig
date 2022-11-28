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
    return Allocator.init(self, alloc, resize, free);
}
fn alloc(self: *StatAllocator, byte_count: usize, alignment: u29, len_align: u29, return_address: usize) Allocator.Error![]u8 {
    if (self.backing_allocator.rawAlloc(byte_count, alignment, len_align, return_address)) |ret| {
        self.allocs += 1;
        self.total_bytes += ret.len;
        self.current_bytes += ret.len;
        self.max_bytes = @max(self.max_bytes, self.current_bytes);
        return ret;
    } else |e| return e;
}
pub fn free(self: *StatAllocator, buf: []u8, buf_align: u29, ret_addr: usize) void {
    self.current_bytes -= buf.len;
    self.max_bytes = @max(self.max_bytes, self.current_bytes);
    return self.backing_allocator.rawFree(buf, buf_align, ret_addr);
}
pub fn resize(self: *StatAllocator, buf: []u8, buf_align: u29, new_len: usize, len_align: u29, ret_addr: usize) ?usize {
    if (self.backing_allocator.rawResize(buf, buf_align, new_len, len_align, ret_addr)) |ret| {
        self.resizes += 1;
        switch (std.math.order(ret, buf.len)) {
            .lt => self.current_bytes -= (buf.len - ret),
            .gt => self.current_bytes += (ret - buf.len),
            .eq => {},
        }
        self.max_bytes = @max(self.max_bytes, self.current_bytes);
        return ret;
    } else return null;
}
