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

    // var width: i32, var height: i32, var channels: i32 = .{ undefined, undefined, undefined };
    // _ = c.stbi_info(filename, &width, &height, &channels);

    const img_file = std.Io.Dir.cwd().openFile(init.io, filename, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("File `{s}` not found.\n", .{filename});
            std.process.exit(1);
        },
        else => return err,
    };

    _ = img_file;

    c.stbi_load_from_callbacks(stbi_callbacks, null, &width, &height, &channels, 4);
}

// fn loadImageFromFile(file: std.Io.File) void {}

fn readCallback(user: ?*anyopaque, data: [*c]u8, size: i32) callconv(.c) i32 {
    _ = user;
    _ = data;
    _ = size;
    return 0;
}

fn skipCallback(user: ?*anyopaque, n: i32) callconv(.c) void {
    _ = user;
    _ = n;
}

fn eofCallback(user: ?*anyopaque) callconv(.c) i32 {
    _ = user;
    return 0;
}
