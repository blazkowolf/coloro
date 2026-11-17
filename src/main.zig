const std = @import("std");
const c = @import("c");

const stbi_callbacks: c.stbi_io_callbacks = .{
    .read = readCallback,
    .skip = skipCallback,
    .eof = eofCallback,
};

pub fn main(init: std.process.Init) !void {
    var args_it = try init.minimal.args.iterateAllocator(init.gpa);
    defer args_it.deinit();

    _ = args_it.next() orelse return error.SomethingWentWrong;

    const filename = args_it.next() orelse return error.MustIncludeFilename;

    var width: i32, var height: i32, var channels: i32 = .{ undefined, undefined, undefined };
    // _ = c.stbi_info(filename, &width, &height, &channels);

    const img_file = std.Io.Dir.cwd().openFile(init.io, filename, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("File `{s}` not found.\n", .{filename});
            std.process.exit(1);
        },
        else => return err,
    };

    var read_buf: [4096]u8 = undefined;
    var reader = img_file.reader(init.io, &read_buf);

    _ = c.stbi_load_from_callbacks(&stbi_callbacks, &reader.interface, &width, &height, &channels, 4);
}

// fn loadImageFromFile(file: std.Io.File) void {}

fn readCallback(user: ?*anyopaque, data: [*c]u8, size: i32) callconv(.c) i32 {
    var reader: *std.Io.Reader = @alignCast(@ptrCast(user));
    // _ = user;
    _ = data;
    _ = size;
    reader.readSliceAll(data[0..size]);
    std.debug.print("read callback\n", .{});
    return 0;
}

fn skipCallback(user: ?*anyopaque, n: i32) callconv(.c) void {
    var reader: *std.Io.Reader = @alignCast(@ptrCast(user));
    if (n < 0) {
        reader.seek += n;
    } else {
        reader.discardAll(@intCast(n)) catch unreachable;
    }
}

fn eofCallback(user: ?*anyopaque) callconv(.c) i32 {
    const reader: *std.Io.Reader = @alignCast(@ptrCast(user));
    const isEof = if (reader.peekByte()) |_| false else |err| err == error.EndOfStream;
    return @intFromBool(isEof);
}
