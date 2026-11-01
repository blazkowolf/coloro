const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const stb = b.dependency("stb", .{});

    const wf = b.addWriteFiles();

    const translate_c = b.addTranslateC(.{
        .root_source_file = wf.add(
            "c.h",
            \\#include "stb_image.h"
            \\#include "stb_image_write.h"
            \\
            ,
        ),
        .target = target,
        .optimize = optimize,
    });

    translate_c.addIncludePath(stb.path("."));

    const stb_mod = b.createModule(.{
        .target = target,
        .optimize = .small,
        .link_libc = true,
    });

    stb_mod.addCSourceFile(.{
        .file = wf.add(
            "stb.h",
            \\#include "stb_image.h"
            \\#include "stb_image_write.h"
            \\
            ,
        ),
        .language = .c,
    });

    stb_mod.addIncludePath(stb.path("."));

    stb_mod.addCMacro("STB_IMAGE_IMPLEMENTATION", "");
    stb_mod.addCMacro("STB_IMAGE_WRITE_IMPLEMENTATION", "");
    
    const stb_lib = b.addLibrary(.{
        .name = "stb",
        .linkage = .static,
        .root_module = stb_mod,
    });

    const exe = b.addExecutable(.{
        .name = "coloro",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "c", .module = translate_c.createModule() },
            },
        }),
    });

    exe.root_module.linkLibrary(stb_lib);

    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    run.addPassthruArgs();
    b.step("run", "Run coloro").dependOn(&run.step);
}
