const std = @import("std");

pub fn main() !void {
    const heap = std.heap.page_allocator;
    const out = std.io.getStdOut().writer();
    const inp = std.io.getStdIn().reader();

    try out.print("Enter filename (e.g., file.txt) or text to encode:\n> ", .{});

    var buf: [256]u8 = undefined;
    const slice = try inp.readUntilDelimiterOrEof(&buf, '\n') orelse &[_]u8{};
    const raw = std.mem.trimRight(u8, slice, "\r\n");

    var payload: []const u8 = undefined;

    if (std.fs.cwd().openFile(raw, .{ .mode = .read_only })) |f| {
        defer f.close();
        const sz = (try f.stat()).size;
        const tmp = try heap.alloc(u8, sz);
        defer heap.free(tmp);
        _ = try f.readAll(tmp);
        payload = tmp;
    } else |_| {
        payload = raw;
    }

    try out.print("Output filename? (Enter for 'Thanks_Pedct.txt'):\n> ", .{});

    var nb: [256]u8 = undefined;
    const nslice = try inp.readUntilDelimiterOrEof(&nb, '\n') orelse &[_]u8{};
    const outname = if (nslice.len > 0)
        std.mem.trim(u8, nslice, " \r\n")
    else
        "Thanks_Pedct.txt";

    const ff = try std.fs.cwd().createFile(outname, .{});
    defer ff.close();

    const wr = ff.writer();
    for (payload) |x| {
        try wr.print("{x:0>2}", .{x});
    }

    try wr.print("\n\nPowered by Pedct\n", .{});
    try out.print("File '{s}' created ✅\n", .{outname});

    try out.print("Press Enter to exit...", .{});
    _ = try inp.readByte();
}
