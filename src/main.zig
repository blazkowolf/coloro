const std = @import("std");
const c = @import("c");

pub fn main(init: std.process.Init) !void {
    var args_it = try init.minimal.args.iterateAllocator(init.gpa);
    defer args_it.deinit();

    _ = args_it.next() orelse return error.SomethingWentWrong;

    // while (args_it.next()) |arg| {
    //     std.debug.print("{s}\n", .{arg});
    // }
    const filename = args_it.next() orelse return error.MustIncludeFilename;

    var width: i32, var height: i32, var channels: i32 = .{ undefined, undefined, undefined };
    _ = c.stbi_info(filename, &width, &height, &channels);

    std.debug.print(
        "Image file: {s}\nwidth: {d}\nheight: {d}\nchannels: {d}\n",
        .{ filename, width, height, channels },
    );
}
