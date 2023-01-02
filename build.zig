const std = @import("std");

pub fn relpath(comptime path: []const u8) []const u8 {
    return comptime std.fs.path.dirname(@src().file).? ++ std.fs.path.sep_str ++ path;
}

const BuildOptions = struct {
    raylib_repo_path: ?[]const u8 = null,
    imgui_repo_path: ?[]const u8 = null,
    disable_obsolete_keyio: bool = false,
    disable_obsolete_functions: bool = false,

    fn calc_raylib_path(opts: @This(), al: std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(al, "{s}" ++ std.fs.path.sep_str ++ "src", .{opts.raylib_repo_path orelse relpath("raylib")}) catch unreachable;
    }
};

pub fn staticLib(b: *std.build.Builder, opts: BuildOptions) *std.build.LibExeObjStep {
    const lib = b.addStaticLibrary("rlImGui", null);
    if (opts.disable_obsolete_keyio) lib.defineCMacro("IMGUI_DISABLE_OBSOLETE_KEYIO", null);
    if (opts.disable_obsolete_functions) lib.defineCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", null);

    lib.linkLibCpp();
    lib.addIncludePath(relpath("."));
    lib.addIncludePath(opts.calc_raylib_path(b.allocator));
    lib.addIncludePath(opts.imgui_repo_path orelse relpath("imgui"));
    lib.addCSourceFile(relpath("rlImGui.cpp"), &.{});
    return lib;
}

/// Add source
pub fn add(b: *std.build.Builder, exe: *std.build.LibExeObjStep, opts: BuildOptions) void {
//     lib.linkLibCpp();
//     lib.addIncludePath(relpath("."));
    if (opts.disable_obsolete_keyio) exe.defineCMacro("IMGUI_DISABLE_OBSOLETE_KEYIO", null);
    if (opts.disable_obsolete_functions) exe.defineCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", null);

    exe.addIncludePath(opts.calc_raylib_path(b.allocator));
    exe.addIncludePath(opts.imgui_repo_path orelse relpath("imgui"));
    exe.addCSourceFile(relpath("rlImGui.cpp"), &.{});
}

pub fn addPackage(b: *std.build.Builder, exe: *std.build.LibExeObjStep, name: []const u8, opts: BuildOptions) void {
    exe.addIncludePath(relpath("."));
    exe.addIncludePath(opts.calc_raylib_path(b.allocator));
    exe.addPackagePath(name, relpath("rlImGui.zig"));
}

pub fn build(b: *std.build.Builder) void {
    const lib = staticLib(b, .{});
    lib.install();
}
